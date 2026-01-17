import Foundation

struct SessionState: Equatable, Identifiable, Sendable {
    let sessionId: String
    let cwd: String
    let projectName: String
    let aiService: AIService
    
    var pid: Int?
    var tty: String?
    var isInTmux: Bool
    var phase: SessionPhase
    var chatItems: [ChatHistoryItem]
    var toolTracker: ToolTracker
    var subagentState: SubagentState
    var conversationInfo: ConversationInfo
    var needsClearReconciliation: Bool
    var lastActivity: Date
    var createdAt: Date
    
    var id: String { sessionId }
    
    nonisolated init(
        sessionId: String,
        cwd: String,
        projectName: String? = nil,
        aiService: AIService = .unknown,
        pid: Int? = nil,
        tty: String? = nil,
        isInTmux: Bool = false,
        phase: SessionPhase = .idle,
        chatItems: [ChatHistoryItem] = [],
        toolTracker: ToolTracker = ToolTracker(),
        subagentState: SubagentState = SubagentState(),
        conversationInfo: ConversationInfo = ConversationInfo(
            summary: nil, lastMessage: nil, lastMessageRole: nil,
            lastToolName: nil, firstUserMessage: nil, lastUserMessageDate: nil
        ),
        needsClearReconciliation: Bool = false,
        lastActivity: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.sessionId = sessionId
        self.cwd = cwd
        self.projectName = projectName ?? URL(fileURLWithPath: cwd).lastPathComponent
        self.aiService = aiService
        self.pid = pid
        self.tty = tty
        self.isInTmux = isInTmux
        self.phase = phase
        self.chatItems = chatItems
        self.toolTracker = toolTracker
        self.subagentState = subagentState
        self.conversationInfo = conversationInfo
        self.needsClearReconciliation = needsClearReconciliation
        self.lastActivity = lastActivity
        self.createdAt = createdAt
    }
    
    var needsAttention: Bool { phase.needsAttention }
    
    var activePermission: PermissionContext? {
        if case .waitingForApproval(let ctx) = phase {
            return ctx
        }
        return nil
    }
    
    var stableId: String {
        if let pid = pid {
            return "\(pid)-\(sessionId)"
        }
        return sessionId
    }
    
    var displayTitle: String {
        conversationInfo.summary ?? conversationInfo.firstUserMessage ?? projectName
    }
    
    var windowHint: String {
        conversationInfo.summary ?? projectName
    }
    
    var pendingToolName: String? { activePermission?.toolName }
    var pendingToolId: String? { activePermission?.toolUseId }
    var pendingToolInput: String? { activePermission?.formattedInput }
    var lastMessage: String? { conversationInfo.lastMessage }
    var lastMessageRole: String? { conversationInfo.lastMessageRole }
    var lastToolName: String? { conversationInfo.lastToolName }
    var summary: String? { conversationInfo.summary }
    var firstUserMessage: String? { conversationInfo.firstUserMessage }
    var lastUserMessageDate: Date? { conversationInfo.lastUserMessageDate }
    var canInteract: Bool { phase.needsAttention }
}

struct ToolTracker: Equatable, Sendable {
    var inProgress: [String: ToolInProgress]
    var seenIds: Set<String>
    var lastSyncOffset: UInt64
    var lastSyncTime: Date?
    
    nonisolated init(
        inProgress: [String: ToolInProgress] = [:],
        seenIds: Set<String> = [],
        lastSyncOffset: UInt64 = 0,
        lastSyncTime: Date? = nil
    ) {
        self.inProgress = inProgress
        self.seenIds = seenIds
        self.lastSyncOffset = lastSyncOffset
        self.lastSyncTime = lastSyncTime
    }
    
    nonisolated mutating func markSeen(_ id: String) -> Bool {
        seenIds.insert(id).inserted
    }
    
    nonisolated func hasSeen(_ id: String) -> Bool {
        seenIds.contains(id)
    }
    
    nonisolated mutating func startTool(id: String, name: String) {
        guard markSeen(id) else { return }
        inProgress[id] = ToolInProgress(
            id: id,
            name: name,
            startTime: Date(),
            phase: .running
        )
    }
    
    nonisolated mutating func completeTool(id: String, success: Bool) {
        inProgress.removeValue(forKey: id)
    }
}

struct ToolInProgress: Equatable, Sendable {
    let id: String
    let name: String
    let startTime: Date
    var phase: ToolInProgressPhase
}

enum ToolInProgressPhase: Equatable, Sendable {
    case starting
    case running
    case pendingApproval
}

struct SubagentState: Equatable, Sendable {
    var activeTasks: [String: TaskContext]
    var taskStack: [String]
    var agentDescriptions: [String: String]
    
    nonisolated init(activeTasks: [String: TaskContext] = [:], taskStack: [String] = [], agentDescriptions: [String: String] = [:]) {
        self.activeTasks = activeTasks
        self.taskStack = taskStack
        self.agentDescriptions = agentDescriptions
    }
    
    nonisolated var hasActiveSubagent: Bool { !activeTasks.isEmpty }
    
    nonisolated mutating func startTask(taskToolId: String, description: String? = nil) {
        activeTasks[taskToolId] = TaskContext(
            taskToolId: taskToolId,
            startTime: Date(),
            agentId: nil,
            description: description,
            subagentTools: []
        )
    }
    
    nonisolated mutating func stopTask(taskToolId: String) {
        activeTasks.removeValue(forKey: taskToolId)
    }
    
    nonisolated mutating func setAgentId(_ agentId: String, for taskToolId: String) {
        activeTasks[taskToolId]?.agentId = agentId
        if let description = activeTasks[taskToolId]?.description {
            agentDescriptions[agentId] = description
        }
    }
    
    nonisolated mutating func addSubagentToolToTask(_ tool: SubagentToolCall, taskId: String) {
        activeTasks[taskId]?.subagentTools.append(tool)
    }
    
    nonisolated mutating func setSubagentTools(_ tools: [SubagentToolCall], for taskId: String) {
        activeTasks[taskId]?.subagentTools = tools
    }
    
    nonisolated mutating func addSubagentTool(_ tool: SubagentToolCall) {
        guard let mostRecentTaskId = activeTasks.keys.max(by: {
            (activeTasks[$0]?.startTime ?? .distantPast) < (activeTasks[$1]?.startTime ?? .distantPast)
        }) else { return }
        
        activeTasks[mostRecentTaskId]?.subagentTools.append(tool)
    }
    
    nonisolated mutating func updateSubagentToolStatus(toolId: String, status: ToolStatus) {
        for taskId in activeTasks.keys {
            if let index = activeTasks[taskId]?.subagentTools.firstIndex(where: { $0.id == toolId }) {
                activeTasks[taskId]?.subagentTools[index].status = status
                return
            }
        }
    }
}

struct TaskContext: Equatable, Sendable {
    let taskToolId: String
    let startTime: Date
    var agentId: String?
    var description: String?
    var subagentTools: [SubagentToolCall]
}

struct ConversationInfo: Equatable, Sendable {
    var summary: String?
    var lastMessage: String?
    var lastMessageRole: String?
    var lastToolName: String?
    var firstUserMessage: String?
    var lastUserMessageDate: Date?
}

struct ChatHistoryItem: Equatable, Sendable, Identifiable {
    let id: String
    let role: String
    let content: String
    let timestamp: Date
}

struct SubagentToolCall: Equatable, Sendable, Identifiable {
    let id: String
    let name: String
    var status: ToolStatus
}

enum ToolStatus: Equatable, Sendable {
    case pending
    case running
    case completed
    case failed
}

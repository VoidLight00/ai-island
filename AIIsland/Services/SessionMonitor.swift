import Foundation
import Combine

@MainActor
class SessionMonitor: ObservableObject {
    static let shared = SessionMonitor()
    
    @Published private(set) var sessions: [SessionState] = []
    @Published private(set) var pendingPermissions: [String: PendingPermission] = [:]
    
    private init() {}
    
    var activeSessions: [SessionState] {
        sessions.filter { $0.phase.isActive || $0.phase.needsAttention }
    }
    
    var hasPendingPermission: Bool {
        sessions.contains { $0.phase.isWaitingForApproval }
    }
    
    var isAnyProcessing: Bool {
        sessions.contains { $0.phase == .processing || $0.phase == .compacting }
    }
    
    func handleEvent(_ event: HookEvent) {
        let sessionId = event.sessionId
        
        if let existingIndex = sessions.firstIndex(where: { $0.sessionId == sessionId }) {
            updateSession(at: existingIndex, with: event)
        } else if event.event == "SessionStart" {
            createSession(from: event)
        }
    }
    
    private func createSession(from event: HookEvent) {
        let session = SessionState(
            sessionId: event.sessionId,
            cwd: event.cwd,
            aiService: event.aiService,
            pid: event.pid,
            tty: event.tty,
            phase: event.sessionPhase
        )
        sessions.append(session)
    }
    
    private func updateSession(at index: Int, with event: HookEvent) {
        var session = sessions[index]
        session.phase = event.sessionPhase
        session.lastActivity = Date()
        
        if let pid = event.pid {
            session.pid = pid
        }
        
        if event.event == "SessionStop" {
            sessions.remove(at: index)
            return
        }
        
        sessions[index] = session
    }
    
    func storePendingPermission(_ permission: PendingPermission) {
        pendingPermissions[permission.toolUseId] = permission
    }
    
    func removePendingPermission(toolUseId: String) {
        pendingPermissions.removeValue(forKey: toolUseId)
    }
    
    func getSession(by id: String) -> SessionState? {
        sessions.first { $0.sessionId == id }
    }
    
    func removeSession(by id: String) {
        sessions.removeAll { $0.sessionId == id }
    }
    
    func clearInactiveSessions() {
        let cutoff = Date().addingTimeInterval(-300)
        sessions.removeAll { session in
            session.phase == .idle && session.lastActivity < cutoff
        }
    }
}

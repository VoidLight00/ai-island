import Foundation

enum SessionPhase: Equatable, Sendable {
    case idle
    case processing
    case waitingForApproval(PermissionContext)
    case waitingForInput
    case compacting
    
    var needsAttention: Bool {
        switch self {
        case .waitingForApproval, .waitingForInput:
            return true
        default:
            return false
        }
    }
    
    var isActive: Bool {
        switch self {
        case .processing, .waitingForApproval, .compacting:
            return true
        default:
            return false
        }
    }
    
    var isWaitingForApproval: Bool {
        if case .waitingForApproval = self {
            return true
        }
        return false
    }
    
    var displayText: String {
        switch self {
        case .idle: return "Idle"
        case .processing: return "Processing..."
        case .waitingForApproval: return "Awaiting approval"
        case .waitingForInput: return "Ready"
        case .compacting: return "Compacting..."
        }
    }
}

struct PermissionContext: Equatable, Sendable {
    let toolUseId: String
    let toolName: String
    let toolInput: [String: AnyCodable]?
    let receivedAt: Date
    
    var formattedInput: String {
        guard let input = toolInput else { return "" }
        
        if let data = try? JSONSerialization.data(
            withJSONObject: input.mapValues { $0.value },
            options: [.prettyPrinted, .sortedKeys]
        ),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return ""
    }
}

import SwiftUI

enum AIService: String, CaseIterable, Codable, Sendable {
    case claude
    case chatgpt
    case gemini
    case grok
    case copilot
    case opencode
    case unknown
    
    var displayName: String {
        switch self {
        case .claude: return "Claude"
        case .chatgpt: return "ChatGPT"
        case .gemini: return "Gemini"
        case .grok: return "Grok"
        case .copilot: return "GitHub Copilot"
        case .opencode: return "OpenCode"
        case .unknown: return "Unknown"
        }
    }
    
    var brandColor: Color {
        switch self {
        case .claude: return Color(hex: 0xDA7756)
        case .chatgpt: return Color(hex: 0x74AA9C)
        case .gemini: return Color(hex: 0x4796E3)
        case .grok: return Color(hex: 0xFFA62E)
        case .copilot: return Color(hex: 0x09AA6C)
        case .opencode: return Color(hex: 0x7C3AED)
        case .unknown: return Color.gray
        }
    }
    
    var characterAsset: String {
        switch self {
        case .claude: return "character_claude"
        case .chatgpt: return "character_chatgpt"
        case .gemini: return "character_gemini"
        case .grok: return "character_grok"
        case .copilot: return "character_copilot"
        case .opencode: return "character_opencode"
        case .unknown: return "character_unknown"
        }
    }
    
    static func from(source: String?) -> AIService {
        guard let source = source?.lowercased() else { return .unknown }
        
        switch source {
        case "claude", "claude-code", "claude_code":
            return .claude
        case "chatgpt", "openai", "gpt":
            return .chatgpt
        case "gemini", "google", "bard":
            return .gemini
        case "grok", "xai", "x":
            return .grok
        case "copilot", "github-copilot", "github_copilot":
            return .copilot
        case "opencode", "open-code", "open_code":
            return .opencode
        default:
            return .unknown
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

# AI Island - Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           AI Island Architecture                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                   │
│  │    Claude    │  │   ChatGPT    │  │    Gemini    │  ... more         │
│  │  (Terminal)  │  │  (Terminal)  │  │  (Terminal)  │                   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                   │
│         │                 │                 │                            │
│         │ Hook Script     │ Plugin          │ Hook                       │
│         ▼                 ▼                 ▼                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Unix Socket Server                            │    │
│  │                  /tmp/ai-island.sock                             │    │
│  │                                                                  │    │
│  │  • Receives events from all AI services                         │    │
│  │  • Routes to appropriate handlers                                │    │
│  │  • Manages permission request/response                           │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                      SessionStore                                │    │
│  │                                                                  │    │
│  │  • Unified state for all sessions                               │    │
│  │  • Service-specific metadata (color, character)                 │    │
│  │  • Phase tracking per session                                   │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                     NotchViewModel                               │    │
│  │                                                                  │    │
│  │  • UI state (open/closed/popping)                               │    │
│  │  • Content type (instances/menu/chat)                           │    │
│  │  • Animation coordination                                        │    │
│  └──────────────────────────┬──────────────────────────────────────┘    │
│                             │                                            │
│                             ▼                                            │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                       NotchView                                  │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐    │    │
│  │  │ Closed State                                             │    │    │
│  │  │ [Character] ──────────────────────────── [Status Dots]  │    │    │
│  │  └─────────────────────────────────────────────────────────┘    │    │
│  │                                                                  │    │
│  │  ┌─────────────────────────────────────────────────────────┐    │    │
│  │  │ Opened State                                             │    │    │
│  │  │ ┌─────────────────────────────────────────────────────┐ │    │    │
│  │  │ │ Header: [Character] ─────────────────── [Menu ≡]    │ │    │    │
│  │  │ └─────────────────────────────────────────────────────┘ │    │    │
│  │  │ ┌─────────────────────────────────────────────────────┐ │    │    │
│  │  │ │ Session List                                        │ │    │    │
│  │  │ │ ● [color] project-name          [chat] [delete]     │ │    │    │
│  │  │ │ ○ [color] another-project       [chat] [delete]     │ │    │    │
│  │  │ └─────────────────────────────────────────────────────┘ │    │    │
│  │  └─────────────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Core Components

### 1. Window Management (`UI/Window/`)

#### NotchPanel (NSPanel subclass)
- Non-activating panel (`nonactivatingPanel`)
- Always on top (`level: .mainMenu + 3`)
- Ignores mouse events by default
- Transparent background
- Stays on all spaces

#### NotchViewController
- Hosts SwiftUI NotchView
- Manages window lifecycle

### 2. State Management (`Core/`)

#### NotchViewModel
```swift
enum NotchStatus { case closed, opened, popping }
enum NotchContentType { case instances, menu, chat(SessionState) }

class NotchViewModel: ObservableObject {
    @Published var status: NotchStatus
    @Published var contentType: NotchContentType
    @Published var isHovering: Bool
    
    // Geometry calculations
    var openedSize: CGSize { ... }
    
    // Actions
    func notchOpen(reason: NotchOpenReason)
    func notchClose()
    func notchPop()
}
```

#### SessionStore
```swift
actor SessionStore {
    private var sessions: [String: SessionState]
    
    func updateSession(_ event: HookEvent)
    func getSession(_ id: String) -> SessionState?
    func getAllSessions() -> [SessionState]
}
```

### 3. Models (`Models/`)

#### SessionState
```swift
struct SessionState: Identifiable {
    let sessionId: String
    let cwd: String
    let source: AIService        // NEW: Which AI service
    var phase: SessionPhase
    var chatItems: [ChatHistoryItem]
    var toolTracker: ToolTracker
}
```

#### AIService (NEW)
```swift
enum AIService: String, CaseIterable {
    case claude
    case chatgpt
    case gemini
    case grok
    case copilot
    case opencode
    
    var brandColor: Color { ... }
    var character: PixelCharacter { ... }
    var displayName: String { ... }
}
```

#### SessionPhase
```swift
enum SessionPhase {
    case idle
    case processing
    case compacting
    case waitingForInput
    case waitingForApproval(PermissionContext)
    case ended
}
```

### 4. Services (`Services/`)

#### HookSocketServer
- Unix domain socket at `/tmp/ai-island.sock`
- Non-blocking I/O with GCD DispatchSource
- JSON event parsing
- Permission request/response handling

#### AISessionMonitor (NEW - replaces ClaudeSessionMonitor)
```swift
class AISessionMonitor: ObservableObject {
    @Published var instances: [SessionState]
    
    func startMonitoring()
    func stopMonitoring()
}
```

### 5. UI Components (`UI/`)

#### Pixel Characters (NEW)
Each AI service has a unique pixel character rendered with Canvas:

```swift
struct AICharacterIcon: View {
    let service: AIService
    let size: CGFloat
    let animateLegs: Bool
    
    var body: some View {
        switch service {
        case .claude: ClaudeCrabIcon(...)
        case .chatgpt: ChatGPTBotIcon(...)
        case .gemini: GeminiStarIcon(...)
        // ...
        }
    }
}
```

#### Status Icons (Pixel Art)
- WaitingForInputIcon - Speech bubble
- WaitingForApprovalIcon - Hand/stop
- RunningIcon - Hourglass (animated)
- IdleIcon - Dash

---

## Event Flow

### 1. Session Start
```
Terminal → Hook Script → Socket Server → SessionStore → UI Update
```

### 2. Permission Request
```
Terminal → Hook Script → Socket Server
                              ↓
                        Keep socket open
                              ↓
                        SessionStore (phase = waitingForApproval)
                              ↓
                        NotchView expands
                              ↓
                        User clicks Allow/Deny
                              ↓
                        Socket Server sends response
                              ↓
                        Close socket, update phase
```

### 3. Status Updates
```
Terminal → Hook Script → Socket Server → SessionStore → NotchView
                                                            ↓
                                              Update character animation
                                              Update status dots
```

---

## File Structure

```
AIIsland/
├── AIIslandApp.swift              # App entry point
├── App/
│   ├── AppDelegate.swift          # Menu bar, lifecycle
│   ├── WindowManager.swift        # Window creation
│   └── ScreenObserver.swift       # Display changes
├── Core/
│   ├── NotchViewModel.swift       # UI state
│   ├── NotchGeometry.swift        # Size calculations
│   ├── Settings.swift             # User preferences
│   ├── AIService.swift            # Service definitions (NEW)
│   └── ScreenSelector.swift       # Multi-display
├── Models/
│   ├── SessionState.swift         # Session model
│   ├── SessionPhase.swift         # Phase enum
│   ├── HookEvent.swift            # Socket events
│   └── PermissionContext.swift    # Permission data
├── Services/
│   ├── Hooks/
│   │   ├── HookSocketServer.swift # Socket server
│   │   └── HookInstaller.swift    # Install hooks
│   ├── Session/
│   │   ├── AISessionMonitor.swift # Session tracking (NEW)
│   │   └── SessionStore.swift     # State storage
│   └── Shared/
│       └── ProcessExecutor.swift  # Shell commands
├── UI/
│   ├── Components/
│   │   ├── AICharacters.swift     # Pixel characters (NEW)
│   │   ├── StatusIcons.swift      # Status indicators
│   │   ├── TerminalColors.swift   # Color palette
│   │   └── ProcessingSpinner.swift
│   ├── Views/
│   │   ├── NotchView.swift        # Main view
│   │   ├── AIInstancesView.swift  # Session list (NEW)
│   │   ├── NotchMenuView.swift    # Settings
│   │   └── ChatView.swift         # Chat history
│   └── Window/
│       ├── NotchWindow.swift      # NSPanel
│       └── NotchViewController.swift
├── Events/
│   └── EventMonitors.swift        # Mouse tracking
└── Utilities/
    └── TerminalVisibilityDetector.swift
```

---

## Key Design Decisions

### 1. Single Window, Global Event Monitors
- Window always ignores mouse events
- Global event monitors detect hover/click
- Re-post clicks to pass through to apps behind

### 2. Service-Agnostic Socket Protocol
- All AI services use same JSON format
- `source` field identifies the service
- UI adapts color/character based on source

### 3. Pixel Art Consistency
- ALL visual indicators are pixel-based
- No SF Symbols or vector icons in notch
- Maintains retro terminal aesthetic

### 4. Reactive State with Combine
- SessionStore publishes changes
- NotchViewModel observes sessions
- SwiftUI views react automatically

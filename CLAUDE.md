# AI Island - Development Guide

> **PRIORITY**: This file must be read FIRST before any development work.

## Project Overview

AI Island is a macOS notch overlay app that provides Dynamic Island-style notifications for multiple AI coding assistants (Claude, ChatGPT, Gemini, Grok, GitHub Copilot, OpenCode, etc.).

**Base**: Forked from [claude-island](https://github.com/farouqaldori/claude-island) with multi-AI service support.

---

## CRITICAL: Before Starting Development

### 1. Read These Files First (in order)
1. `CLAUDE.md` (this file) - Development priorities
2. `ARCHITECTURE.md` - System architecture and code structure
3. `DEVELOPMENT.md` - Setup, build, and contribution guide
4. `AI_SERVICES.md` - AI service configurations (colors, characters, hooks)

### 2. Reference Implementation
The original claude-island code is at: `/tmp/claude-island-ref/ClaudeIsland/`

Key files to reference:
- `Core/NotchViewModel.swift` - State management
- `UI/Window/NotchWindow.swift` - Window configuration (NSPanel)
- `UI/Views/NotchView.swift` - Main SwiftUI view
- `UI/Components/StatusIcons.swift` - Pixel art icons
- `Services/Hooks/HookSocketServer.swift` - Unix socket server

---

## AI Services Configuration

### Brand Colors (Hex)
| Service | Color | Hex |
|---------|-------|-----|
| Claude | Terracotta | #DA7756 |
| ChatGPT | Teal Green | #74AA9C |
| Gemini | Light Blue | #4796E3 |
| Grok | Orange | #FFA62E |
| GitHub Copilot | Green | #09AA6C |
| OpenCode | Violet | #7C3AED |

### Pixel Characters (8x8 or 11x8 grid)
Each AI service has a unique pixel character:
- **Claude**: Crab (existing from claude-island)
- **ChatGPT**: Robot/Bot head
- **Gemini**: Star/Sparkle
- **Grok**: Lightning bolt
- **GitHub Copilot**: Pilot goggles
- **OpenCode**: Terminal cursor

---

## Development Phases

### Phase 1: Core Setup (Current)
- [ ] Create Xcode project structure
- [ ] Copy and adapt claude-island core components
- [ ] Implement multi-service color system
- [ ] Create pixel characters for each service

### Phase 2: Multi-Service Support
- [ ] Abstract hook system for multiple services
- [ ] Service-specific socket handlers
- [ ] Dynamic character/color switching
- [ ] Service detection and routing

### Phase 3: UI/UX
- [ ] Service indicator in notch (color + character)
- [ ] Multi-session management (mixed services)
- [ ] Service-specific status icons (all pixel art)
- [ ] Settings panel for service toggles

### Phase 4: Polish
- [ ] Animations matching Dynamic Island
- [ ] Sound effects per service
- [ ] Auto-update mechanism
- [ ] Documentation and release

---

## Code Standards

### Swift
- Use SwiftUI for all UI components
- Follow MVVM pattern (NotchViewModel)
- Use Combine for reactive state
- Prefer value types (struct) over reference types

### Pixel Art
- All status indicators must be pixel art (dot-based)
- Use Canvas for rendering (see StatusIcons.swift)
- Standard grid: 30x30 with 4px dots (scaled)
- Colors from service brand palette

### File Organization
```
AIIsland/
├── App/                    # App entry, delegates
├── Core/                   # ViewModels, Settings
├── Models/                 # Data models
├── Services/
│   ├── Hooks/              # Socket server, hook installer
│   ├── Session/            # Session monitoring
│   └── Shared/             # Common utilities
├── UI/
│   ├── Components/         # Reusable UI (icons, buttons)
│   ├── Views/              # Main views
│   └── Window/             # Window management
└── Utilities/              # Helpers
```

---

## Quick Commands

```bash
# Build
xcodebuild -scheme AIIsland -configuration Release build

# Run in debug
open AIIsland.xcodeproj

# Clean build
xcodebuild clean -scheme AIIsland
```

---

## Socket Protocol

Events from AI services use JSON over Unix socket `/tmp/ai-island.sock`:

```json
{
  "source": "claude|chatgpt|gemini|grok|copilot|opencode",
  "session_id": "unique-session-id",
  "cwd": "/path/to/project",
  "event": "SessionStart|PreToolUse|PermissionRequest|...",
  "status": "idle|processing|waiting_for_approval|...",
  "tool": "Bash|Edit|...",
  "tool_input": {...}
}
```

Response for permission requests:
```json
{
  "decision": "allow|deny",
  "reason": "optional reason"
}
```

---

## Known Issues / TODOs

- [ ] Window positioning on external displays
- [ ] Permission response timeout handling
- [ ] Service auto-detection from terminal
- [ ] Hook installation for each service

---

## Contact

Repository: https://github.com/VoidLight00/ai-island

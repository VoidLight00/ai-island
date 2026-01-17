# AI Island - Development Guide

> **PRIORITY**: This file must be read FIRST before any development work.
> **AI-ASSISTED DEVELOPMENT**: See `AI_DEVELOPMENT.md` for comprehensive AI tools and workflow guide.

## Project Overview

AI Island is a macOS notch overlay app that provides Dynamic Island-style notifications for multiple AI coding assistants (Claude, ChatGPT, Gemini, Grok, GitHub Copilot, OpenCode, etc.).

**Base**: Forked from [claude-island](https://github.com/farouqaldori/claude-island) with multi-AI service support.

---

## AI-Assisted Development (Quick Reference)

### Agent System
| Agent | Cost | Use Case |
|-------|------|----------|
| **explore** | FREE | 코드베이스 검색, 패턴 찾기 |
| **librarian** | CHEAP | 외부 문서, GitHub 검색 |
| **oracle** | EXPENSIVE | 아키텍처, 복잡한 디버깅 |

### Essential Commands
```bash
# Build
xcodebuild -scheme AIIsland -configuration Debug build

# Run
open ~/Library/Developer/Xcode/DerivedData/AIIsland-*/Build/Products/Debug/AIIsland.app

# Git
git add -A && git commit -m "feat(scope): message" && git push origin main
```

### Workflow
1. **Research** (parallel): `explore` + `librarian` 에이전트 발사
2. **Plan**: `TodoWrite`로 작업 계획
3. **Implement**: 코드 수정 + `lsp_diagnostics` 확인
4. **Verify**: `xcodebuild` 빌드 테스트
5. **Commit**: Git 커밋 & 푸시

> **자세한 가이드**: `AI_DEVELOPMENT.md` 참조

---

## CRITICAL: Before Starting Development

### 1. Read These Files First (in order)
1. `CLAUDE.md` (this file) - Development priorities
2. `AI_DEVELOPMENT.md` - **AI tools, agents, and workflow** (NEW)
3. `ARCHITECTURE.md` - System architecture and code structure
4. `DEVELOPMENT.md` - Setup, build, and contribution guide
5. `AI_SERVICES.md` - AI service configurations (colors, characters, hooks)

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

## AI Development Quick Commands

### MCP Tools (Most Used)
```bash
# File operations
mcp_read(filePath="...")
mcp_edit(filePath="...", oldString="...", newString="...")
mcp_write(filePath="...", content="...")

# Code intelligence
mcp_lsp_diagnostics(filePath="...")
mcp_lsp_goto_definition(filePath="...", line=N, character=N)

# Search
mcp_glob(pattern="**/*.swift")
mcp_grep(pattern="SessionPhase", include="*.swift")

# Background agents (parallel)
mcp_background_task(agent="explore", prompt="...")
mcp_background_task(agent="librarian", prompt="...")
mcp_background_output(task_id="bg_xxx")

# Task management
mcp_todowrite(todos=[...])
mcp_todoread()
```

### Xcode Project File (project.pbxproj)
새 Swift 파일 추가 시:
1. `PBXBuildFile` 섹션에 빌드 참조 추가
2. `PBXFileReference` 섹션에 파일 참조 추가
3. 해당 `PBXGroup`의 children에 파일 추가
4. `PBXSourcesBuildPhase`의 files에 빌드 참조 추가

### Research Prompt Template
```
Search [GitHub/docs] for [topic].

I need:
1. [Specific requirement]
2. [Code examples]
3. [Best practices]

Focus on: [specific repos/libraries]
Return: Code snippets I can use directly.
```

---

## Contact

Repository: https://github.com/VoidLight00/ai-island

---

## Document Maintenance

| Document | Purpose | Update When |
|----------|---------|-------------|
| `CLAUDE.md` | 개발 우선순위, 빠른 참조 | 구조 변경 시 |
| `AI_DEVELOPMENT.md` | AI 도구, 에이전트, 워크플로우 | 새 패턴 발견 시 |
| `ARCHITECTURE.md` | 시스템 설계 | 아키텍처 변경 시 |
| `DEVELOPMENT.md` | 빌드, 테스트 가이드 | 빌드 프로세스 변경 시 |
| `AI_SERVICES.md` | 서비스 설정 | 새 AI 서비스 추가 시 |

**Last Updated**: 2026-01-17

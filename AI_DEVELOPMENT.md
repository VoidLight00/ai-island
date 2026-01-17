# AI Island - AI-Assisted Development Guide

> **이 문서는 AI Island 프로젝트를 AI(Claude/OpenCode)와 함께 개발할 때 사용하는 방법론, 도구, 프롬프트를 정리한 가이드입니다.**

---

## Table of Contents

1. [Development Environment](#development-environment)
2. [AI Agent Architecture](#ai-agent-architecture)
3. [Core Tools & MCP Servers](#core-tools--mcp-servers)
4. [Development Workflow](#development-workflow)
5. [Prompt Engineering](#prompt-engineering)
6. [Background Agent Patterns](#background-agent-patterns)
7. [Code Quality & Verification](#code-quality--verification)
8. [Xcode Project Management](#xcode-project-management)
9. [Git Workflow](#git-workflow)
10. [Troubleshooting](#troubleshooting)

---

## Development Environment

### Primary AI Model
- **Claude Sonnet 4** (via OpenCode CLI)
- Agent Name: **Sisyphus** - OhMyClaude Code orchestration agent

### IDE & Build Tools
| Tool | Purpose |
|------|---------|
| Xcode 15+ | Swift/macOS development |
| `xcodebuild` | CLI build system |
| OpenCode | AI-powered terminal interface |

### Key Directories
```
/Users/voidlight/ai-island/           # Main project
/tmp/claude-island-ref/ClaudeIsland/  # Reference implementation
```

---

## AI Agent Architecture

### Sisyphus Agent Behavior
Sisyphus는 "시니어 엔지니어처럼 작동하는 AI 에이전트"입니다:

```
┌─────────────────────────────────────────────────────────┐
│                    Sisyphus (Main Agent)                │
│  - Intent classification                                │
│  - Task decomposition via TodoWrite                     │
│  - Tool orchestration                                   │
│  - Parallel execution                                   │
└─────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
   ┌──────────┐         ┌──────────┐         ┌──────────┐
   │ Explore  │         │Librarian │         │  Oracle  │
   │  Agent   │         │  Agent   │         │  Agent   │
   │ (FREE)   │         │ (CHEAP)  │         │(EXPENSIVE)│
   └──────────┘         └──────────┘         └──────────┘
   Codebase grep      External docs       Architecture
   Pattern finding    GitHub search       Deep reasoning
```

### Agent Types & Usage

| Agent | Cost | Use Case | Trigger |
|-------|------|----------|---------|
| **explore** | FREE | 코드베이스 검색, 패턴 찾기 | "어디에 있어?", "찾아줘" |
| **librarian** | CHEAP | 외부 문서, OSS 예제, GitHub 검색 | 라이브러리 사용법, best practices |
| **oracle** | EXPENSIVE | 아키텍처 결정, 복잡한 디버깅 | 2회 이상 실패 후, 설계 고민 |
| **frontend-ui-ux-engineer** | CHEAP | UI/UX 시각적 변경 | 스타일, 레이아웃, 애니메이션 |
| **document-writer** | CHEAP | 문서 작성 | README, API docs |

---

## Core Tools & MCP Servers

### File Operations
```bash
# Read file with line numbers
mcp_read(filePath="/path/to/file.swift")

# Edit file (find & replace)
mcp_edit(filePath="...", oldString="...", newString="...")

# Write new file
mcp_write(filePath="...", content="...")

# Search files by pattern
mcp_glob(pattern="**/*.swift", path="/Users/voidlight/ai-island")

# Search file contents
mcp_grep(pattern="SessionPhase", include="*.swift", path="/...")
```

### Code Intelligence (LSP)
```bash
# Get diagnostics (errors, warnings)
mcp_lsp_diagnostics(filePath="/path/to/file.swift")

# Find symbol definition
mcp_lsp_goto_definition(filePath="...", line=10, character=5)

# Find all references
mcp_lsp_find_references(filePath="...", line=10, character=5)

# Get type info on hover
mcp_lsp_hover(filePath="...", line=10, character=5)

# Safe rename across workspace
mcp_lsp_prepare_rename(...)
mcp_lsp_rename(filePath="...", line=10, character=5, newName="newName")
```

### AST-Aware Search & Replace
```bash
# Search Swift patterns
mcp_ast_grep_search(
  pattern="case .$NAME:",
  lang="swift",
  paths=["/Users/voidlight/ai-island"]
)

# Replace patterns (dry run by default)
mcp_ast_grep_replace(
  pattern="Color.gray",
  rewrite="TerminalColors.dim",
  lang="swift",
  dryRun=true
)
```

### Background Agents
```bash
# Fire async explore agent
mcp_background_task(
  agent="explore",
  description="Find auth patterns",
  prompt="Search for authentication implementations..."
)

# Fire async librarian agent
mcp_background_task(
  agent="librarian", 
  description="Find SwiftUI animation docs",
  prompt="Search GitHub and docs for SwiftUI animation patterns..."
)

# Get results (non-blocking)
mcp_background_output(task_id="bg_xxxxx")

# Cancel all background tasks (before final answer)
mcp_background_cancel(all=true)
```

### Todo Management
```bash
# Create/update todos
mcp_todowrite(todos=[
  {"id": "1", "content": "Task description", "status": "in_progress", "priority": "high"}
])

# Read current todos
mcp_todoread()
```

### External Resources
```bash
# Web search
mcp_websearch_web_search_exa(query="SwiftUI notch overlay macOS")

# Fetch URL content
mcp_webfetch(url="https://...", format="markdown")

# GitHub code search
mcp_grep_app_searchGitHub(query="NSPanel level", language=["Swift"])

# Library documentation (Context7)
mcp_context7_resolve-library-id(libraryName="SwiftUI", query="animation spring")
mcp_context7_query-docs(libraryId="/apple/swiftui", query="...")
```

---

## Development Workflow

### Phase 0: Intent Classification
```
사용자 요청 → 분류:
├── Trivial (단일 파일, 명확한 위치) → 직접 도구 사용
├── Explicit (특정 파일/라인) → 직접 실행
├── Exploratory ("어떻게 작동해?") → explore 에이전트 + 도구 병렬
├── Open-ended ("개선해줘", "리팩터링") → 코드베이스 평가 먼저
└── Ambiguous → 명확화 질문 1개
```

### Phase 1: Research (Parallel)
```
┌─────────────────────────────────────────────────────────┐
│ Background Agents (Parallel)                            │
├─────────────────────────────────────────────────────────┤
│ explore: "Find existing patterns in codebase"          │
│ librarian: "Find SwiftUI animation best practices"     │
│ librarian: "Find macOS notch UI implementations"       │
└─────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│ Continue with Direct Tools (Don't wait)                 │
│ - Read relevant files                                   │
│ - Check project structure                               │
│ - Analyze existing code                                 │
└─────────────────────────────────────────────────────────┘
```

### Phase 2: Implementation
```
1. TodoWrite로 작업 계획 생성 (2+ 단계일 때 필수)
2. 현재 작업 in_progress 마킹
3. 코드 수정
4. lsp_diagnostics로 에러 확인
5. 작업 완료 시 즉시 completed 마킹
6. 빌드 테스트
```

### Phase 3: Verification & Commit
```
1. xcodebuild로 빌드 확인
2. 앱 실행 테스트
3. git add → commit → push
4. 모든 background task 취소
```

---

## Prompt Engineering

### Research Prompt Template (librarian/explore)
```
Search [GitHub/docs/codebase] for [specific topic].

I need:
1. [Specific requirement 1]
2. [Specific requirement 2]
3. [Specific requirement 3]

Focus on:
- [Repository/library name]
- [Specific patterns]
- [Code examples]

Return:
- File paths with relevant code
- Key implementation patterns
- Code snippets I can use directly
```

### Example: SwiftUI Animation Research
```
Search GitHub for SwiftUI animation patterns for macOS notch UI.

I need:
1. Spring animation parameters for expand/collapse
2. Matched geometry effect examples
3. Asymmetric transitions

Focus on:
- TheBoredTeam/boring.notch
- farouqaldori/claude-island
- macOS Dynamic Island implementations

Return code examples with animation timing constants.
```

---

## Background Agent Patterns

### Parallel Research Pattern
```swift
// 여러 에이전트를 병렬로 발사
background_task(agent="explore", prompt="Find SessionPhase usages...")
background_task(agent="librarian", prompt="Find Swift enum patterns...")
background_task(agent="librarian", prompt="Find NSPanel configuration...")

// 즉시 다른 작업 계속
read_file("/path/to/main/file.swift")
edit_file(...)

// 필요할 때 결과 수집
background_output(task_id="bg_xxx")
```

### When to Use Each Agent

| Situation | Agent | Example Prompt |
|-----------|-------|----------------|
| "이 코드 어디 있어?" | explore | "Find where SessionPhase is defined and used" |
| "이 라이브러리 어떻게 써?" | librarian | "Find SwiftUI Canvas documentation and examples" |
| "아키텍처 어떻게 해야 해?" | oracle | "Review this socket server design for..." |
| "UI 예쁘게 만들어줘" | frontend-ui-ux-engineer | "Create pixel art character for..." |

---

## Code Quality & Verification

### Build Verification
```bash
# Debug build
xcodebuild -scheme AIIsland -configuration Debug build 2>&1 | grep -E "(error:|warning:|BUILD)"

# Check for errors only
xcodebuild -scheme AIIsland -configuration Debug build 2>&1 | grep "error:"
```

### LSP Diagnostics
```bash
# Always run after editing Swift files
mcp_lsp_diagnostics(filePath="/path/to/edited/file.swift")
```

### Pre-Commit Checklist
1. `lsp_diagnostics` clean on all changed files
2. `xcodebuild` succeeds
3. App launches without crash
4. No `as any`, `@ts-ignore` equivalents

---

## Xcode Project Management

### project.pbxproj Structure
```
┌─────────────────────────────────────────────────────────┐
│ PBXBuildFile section                                    │
│ - References for compilation                            │
│ - Format: A1xxx /* File.swift in Sources */            │
├─────────────────────────────────────────────────────────┤
│ PBXFileReference section                                │
│ - File definitions                                      │
│ - Format: A2xxx /* File.swift */                       │
├─────────────────────────────────────────────────────────┤
│ PBXGroup section                                        │
│ - Folder structure                                      │
│ - children = (A2xxx, A2yyy, ...)                       │
├─────────────────────────────────────────────────────────┤
│ PBXSourcesBuildPhase section                           │
│ - Files to compile                                      │
│ - files = (A1xxx, A1yyy, ...)                          │
└─────────────────────────────────────────────────────────┘
```

### Adding New Swift File
```
1. Create file in correct directory
2. Add PBXBuildFile entry (A1xxx)
3. Add PBXFileReference entry (A2xxx)  
4. Add A2xxx to appropriate PBXGroup children
5. Add A1xxx to PBXSourcesBuildPhase files
```

### Common project.pbxproj Patterns
```
// Build file reference
A10000010000000000000020 /* AICharacters.swift in Sources */ = {
    isa = PBXBuildFile; 
    fileRef = A20000010000000000000021 /* AICharacters.swift */; 
};

// File reference
A20000010000000000000021 /* AICharacters.swift */ = {
    isa = PBXFileReference; 
    lastKnownFileType = sourcecode.swift; 
    path = AICharacters.swift; 
    sourceTree = "<group>"; 
};

// Group (folder)
A50000010000000000000015 /* Components */ = {
    isa = PBXGroup;
    children = (
        A20000010000000000000021 /* AICharacters.swift */,
        A20000010000000000000023 /* TerminalColors.swift */,
    );
    path = Components;
    sourceTree = "<group>";
};
```

---

## Git Workflow

### Commit Message Format
```
<type>(<scope>): <description>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- refactor: Code refactoring
- style: Formatting
- test: Tests
- chore: Maintenance

Examples:
feat(ui): add pixel art characters for all AI services
fix(socket): handle connection timeout gracefully
docs: add AI development methodology guide
```

### Standard Git Commands
```bash
# Stage all changes
git add -A

# Commit with message
git commit -m "feat(ui): add Phase 2 UI components"

# Push to remote
git push origin main

# Check status
git status
```

---

## Troubleshooting

### Build Failures

| Error | Solution |
|-------|----------|
| "Cannot find type 'X' in scope" | Check if file is added to PBXSourcesBuildPhase |
| "has no member 'Y'" | Check type definition, add missing property/method |
| "Multiple matches for 'Z'" | Use more specific type annotation |

### Common Swift Fixes
```swift
// Add missing computed property to enum
enum SessionPhase {
    // ...existing cases...
    
    var isWaitingForApproval: Bool {
        if case .waitingForApproval = self { return true }
        return false
    }
}

// Handle missing enum case
switch phase {
case .idle:  // Remove non-existent cases like .ended
    // ...
}
```

### Xcode Project Issues
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/AIIsland-*

# Rebuild from scratch
xcodebuild clean -scheme AIIsland
xcodebuild -scheme AIIsland -configuration Debug build
```

---

## Quick Reference

### Essential Commands
```bash
# Build
xcodebuild -scheme AIIsland -configuration Debug build

# Run app
open ~/Library/Developer/Xcode/DerivedData/AIIsland-*/Build/Products/Debug/AIIsland.app

# Git workflow
git add -A && git commit -m "message" && git push origin main
```

### Essential MCP Tools
```
mcp_read          # Read file
mcp_edit          # Edit file
mcp_write         # Write new file
mcp_glob          # Find files
mcp_grep          # Search content
mcp_lsp_*         # Code intelligence
mcp_background_*  # Async agents
mcp_todowrite     # Task management
```

### AI Service Colors (Reference)
| Service | Color | Hex |
|---------|-------|-----|
| Claude | Terracotta | #DA7756 |
| ChatGPT | Teal | #74AA9C |
| Gemini | Blue | #4796E3 |
| Grok | Orange | #FFA62E |
| Copilot | Green | #09AA6C |
| OpenCode | Violet | #7C3AED |

---

## Maintenance

이 문서는 AI Island 개발 시 항상 참조되어야 합니다. 새로운 패턴이나 도구가 추가되면 이 문서를 업데이트하세요.

**Last Updated**: 2026-01-17
**Maintainer**: VoidLight

# AI Island - Development Guide

## Prerequisites

- **macOS 14.0+** (Sonoma or later)
- **Xcode 15.0+**
- **Swift 5.9+**

---

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/VoidLight00/ai-island.git
cd ai-island
```

### 2. Open in Xcode
```bash
open AIIsland.xcodeproj
```

### 3. Build & Run
- Select `AIIsland` scheme
- Press `Cmd + R` to run

---

## Project Structure

```
ai-island/
├── CLAUDE.md              # Priority reading for development
├── ARCHITECTURE.md        # System design
├── AI_SERVICES.md         # Service configurations
├── DEVELOPMENT.md         # This file
├── README.md              # User documentation
├── LICENSE                # Apache 2.0
├── AIIsland.xcodeproj/    # Xcode project
├── AIIsland/              # Source code
│   ├── App/
│   ├── Core/
│   ├── Models/
│   ├── Services/
│   ├── UI/
│   ├── Events/
│   └── Utilities/
├── scripts/               # Build & hook scripts
└── assets/                # Icons, sounds
```

---

## Build Commands

### Debug Build
```bash
xcodebuild -scheme AIIsland -configuration Debug build
```

### Release Build
```bash
xcodebuild -scheme AIIsland -configuration Release build
```

### Clean Build
```bash
xcodebuild clean -scheme AIIsland
rm -rf ~/Library/Developer/Xcode/DerivedData/AIIsland-*
```

### Archive for Distribution
```bash
xcodebuild -scheme AIIsland -configuration Release archive \
  -archivePath ./build/AIIsland.xcarchive
```

---

## Development Workflow

### 1. Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### 2. Coding Standards

#### Swift Style
- Use SwiftUI for all views
- Follow MVVM pattern
- Prefer `struct` over `class`
- Use Combine for reactive data flow
- Document public APIs

#### Naming Conventions
- **Files**: PascalCase (e.g., `NotchViewModel.swift`)
- **Types**: PascalCase (e.g., `SessionState`)
- **Functions/Variables**: camelCase (e.g., `handleMouseMove`)
- **Constants**: camelCase with descriptive names

### 3. Testing
```bash
xcodebuild test -scheme AIIsland -destination 'platform=macOS'
```

### 4. Commit & Push
```bash
git add .
git commit -m "feat: description of your change"
git push origin feature/your-feature-name
```

---

## Adding a New AI Service

### Step 1: Update AIService Enum
```swift
// Core/AIService.swift
enum AIService: String, CaseIterable {
    // ... existing cases
    case newservice
    
    var brandColor: Color {
        switch self {
        // ... existing
        case .newservice: return Color(hex: 0xHEXCODE)
        }
    }
}
```

### Step 2: Create Pixel Character
```swift
// UI/Components/AICharacters.swift
struct NewServiceIcon: View {
    let size: CGFloat
    
    var body: some View {
        Canvas { context, canvasSize in
            // Draw pixel character
        }
        .frame(width: size, height: size)
    }
}
```

### Step 3: Add Character to Switch
```swift
// UI/Components/AICharacterIcon.swift
struct AICharacterIcon: View {
    let service: AIService
    
    var body: some View {
        switch service {
        // ... existing
        case .newservice: NewServiceIcon(size: size)
        }
    }
}
```

### Step 4: Create Hook Script
Create `scripts/hooks/newservice-hook.py` following the template in `AI_SERVICES.md`.

### Step 5: Update Documentation
- Add service to `AI_SERVICES.md`
- Update `README.md` if needed

---

## Debugging

### Enable Debug Logging
```swift
// In AppDelegate.swift or relevant file
#if DEBUG
let logger = Logger(subsystem: "com.aiisland", category: "Debug")
logger.debug("Debug message")
#endif
```

### View Socket Communication
```bash
# Monitor socket in terminal
nc -lU /tmp/ai-island.sock
```

### Test Events Manually
```bash
# Send test event
echo '{"source":"claude","session_id":"test","cwd":"/tmp","event":"SessionStart","status":"idle"}' | nc -U /tmp/ai-island.sock
```

---

## Common Issues

### Window Not Appearing
1. Check if another instance is running
2. Verify `level` in NotchPanel is set correctly
3. Check `collectionBehavior` includes `.canJoinAllSpaces`

### Clicks Not Passing Through
1. Ensure `ignoresMouseEvents = true` when notch is closed
2. Verify event monitors are set up correctly
3. Check `repostClickAt` implementation

### Socket Connection Failed
1. Remove stale socket: `rm /tmp/ai-island.sock`
2. Check file permissions
3. Verify no other process is using the socket

---

## Release Checklist

- [ ] Version bump in `Info.plist`
- [ ] Update `CHANGELOG.md`
- [ ] Test on multiple macOS versions
- [ ] Test on notched and non-notched Macs
- [ ] Code signing configured
- [ ] Notarization completed
- [ ] GitHub release created
- [ ] Update README with new version

---

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes with tests
4. Submit pull request
5. Wait for review

### Pull Request Guidelines
- Clear description of changes
- Reference related issues
- Include screenshots for UI changes
- Ensure CI passes

---

## Resources

### Reference Implementation
- Original claude-island: `/tmp/claude-island-ref/ClaudeIsland/`
- Key files listed in `CLAUDE.md`

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Combine Framework](https://developer.apple.com/documentation/combine/)
- [AppKit Window Management](https://developer.apple.com/documentation/appkit/nswindow)

### Design References
- [Dynamic Island HIG](https://developer.apple.com/design/human-interface-guidelines/live-activities)
- [SF Symbols](https://developer.apple.com/sf-symbols/) (for reference, not used in notch)

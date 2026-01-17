# AI Island

<p align="center">
  <img src="assets/icon-256.png" alt="AI Island Logo" width="128" height="128">
</p>

<p align="center">
  <strong>Dynamic Island-style notifications for multiple AI coding assistants on macOS</strong>
</p>

<p align="center">
  <a href="#features">Features</a> |
  <a href="#supported-services">Supported Services</a> |
  <a href="#installation">Installation</a> |
  <a href="#usage">Usage</a> |
  <a href="#development">Development</a>
</p>

---

## Features

- **Notch UI** - Animated overlay that expands from the MacBook notch
- **Multi-Service Support** - Works with Claude, ChatGPT, Gemini, Grok, Copilot, OpenCode
- **Live Session Monitoring** - Track multiple AI sessions in real-time
- **Permission Approvals** - Approve or deny tool executions directly from the notch
- **Unique Characters** - Each AI service has its own pixel art character
- **Service Colors** - Color-coded indicators for each service
- **Auto-Setup** - Hooks install automatically on first launch

---

## Supported Services

| Service | Color | Character |
|---------|-------|-----------|
| **Claude** (Anthropic) | Terracotta (#DA7756) | Crab |
| **ChatGPT** (OpenAI) | Teal (#74AA9C) | Robot |
| **Gemini** (Google) | Blue (#4796E3) | Star |
| **Grok** (xAI) | Orange (#FFA62E) | Lightning |
| **GitHub Copilot** | Green (#09AA6C) | Goggles |
| **OpenCode** | Violet (#7C3AED) | Terminal |

---

## Requirements

- macOS 14.0+ (Sonoma or later)
- AI CLI tool installed (Claude Code, etc.)

---

## Installation

### Option 1: Download Release
Download the latest `.dmg` from [Releases](https://github.com/VoidLight00/ai-island/releases).

### Option 2: Build from Source
```bash
git clone https://github.com/VoidLight00/ai-island.git
cd ai-island
xcodebuild -scheme AIIsland -configuration Release build
```

---

## Usage

### Starting the App
1. Launch AI Island from Applications
2. The notch indicator appears at the top of your screen
3. Hooks are automatically installed for supported services

### Interacting with the Notch
- **Hover** over the notch to see activity
- **Click** to expand and view sessions
- **Approve/Deny** permission requests directly

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| `Cmd + Y` | Approve permission |
| `Cmd + Shift + N` | Deny permission |
| `Esc` | Close expanded view |

---

## How It Works

AI Island installs hooks for each AI service that communicate session state via a Unix socket (`/tmp/ai-island.sock`). The app listens for events and displays them in the notch overlay.

```
AI Terminal → Hook Script → Unix Socket → AI Island UI
```

When an AI needs permission to run a tool, the notch expands with approve/deny buttons - no need to switch to the terminal.

---

## Configuration

### Hook Locations
- **Claude**: `~/.claude/hooks/`
- **OpenCode**: `~/.config/opencode/plugin/`
- Others: Configured on first use

### Settings
Access settings by clicking the menu icon (≡) in the expanded notch:
- Enable/disable services
- Notification sounds
- Launch at login

---

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for setup and contribution guide.

### Quick Links
- [Architecture](ARCHITECTURE.md)
- [AI Services Config](AI_SERVICES.md)
- [Claude Guide](CLAUDE.md)

---

## Credits

- Based on [claude-island](https://github.com/farouqaldori/claude-island) by Farouq Aldori
- Pixel art characters inspired by retro terminal aesthetics

---

## License

Apache 2.0 - See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with pixel love by <a href="https://github.com/VoidLight00">VoidLight</a>
</p>

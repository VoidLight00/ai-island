# AI Services Configuration

## Supported Services

### 1. Claude (Anthropic)
| Property | Value |
|----------|-------|
| Brand Color | #DA7756 (Terracotta) |
| Character | Crab (existing) |
| Hook Location | `~/.claude/hooks/` |
| Config File | `~/.claude/settings.json` |

**Pixel Character (11x8):**
```
   ●     ●   
    ●   ●    
   ●●●●●●●   
  ●● ●●● ●●  
 ●●●●●●●●●●● 
 ● ●●●●●●● ● 
 ● ●     ● ● 
    ●●  ●●   
```

---

### 2. ChatGPT (OpenAI)
| Property | Value |
|----------|-------|
| Brand Color | #74AA9C (Teal Green) |
| Character | Robot Head |
| Hook Location | TBD |
| Config File | TBD |

**Pixel Character (8x8):**
```
  ●●●●  
 ●    ● 
 ● ●● ● 
 ●    ● 
 ●●●●●● 
  ●  ●  
  ●●●●  
   ●●   
```

---

### 3. Gemini (Google)
| Property | Value |
|----------|-------|
| Brand Color | #4796E3 (Light Blue) |
| Character | Star/Sparkle |
| Hook Location | TBD |
| Config File | TBD |

**Pixel Character (8x8):**
```
    ●   
   ●●●  
  ● ● ● 
 ●● ● ●●
  ● ● ● 
   ●●●  
    ●   
        
```

---

### 4. Grok (xAI)
| Property | Value |
|----------|-------|
| Brand Color | #FFA62E (Orange) |
| Character | Lightning Bolt |
| Hook Location | TBD |
| Config File | TBD |

**Pixel Character (8x8):**
```
    ●●  
   ●●   
  ●●    
 ●●●●●  
   ●●   
  ●●    
 ●●     
●●      
```

---

### 5. GitHub Copilot
| Property | Value |
|----------|-------|
| Brand Color | #09AA6C (Copilot Green) |
| Character | Pilot Goggles |
| Hook Location | TBD |
| Config File | TBD |

**Pixel Character (8x8):**
```
        
 ●●  ●● 
●  ●●  ●
● ●●●● ●
●  ●●  ●
 ●●  ●● 
        
   ●●   
```

---

### 6. OpenCode
| Property | Value |
|----------|-------|
| Brand Color | #7C3AED (Violet) |
| Character | Terminal Cursor |
| Hook Location | `~/.config/opencode/plugin/` |
| Config File | `~/.config/opencode/config.json` |

**Pixel Character (8x8):**
```
●●●●●●●●
●      ●
● ●●   ●
● ●●   ●
● ●●   ●
●      ●
●●●●●●●●
        
```

---

## Hook Script Template

Each service needs a hook script that sends events to the socket:

```python
#!/usr/bin/env python3
import json
import socket
import os
import sys

SOCKET_PATH = "/tmp/ai-island.sock"

def send_event(event_data):
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(SOCKET_PATH)
        sock.send(json.dumps(event_data).encode())
        
        # For permission requests, wait for response
        if event_data.get("status") == "waiting_for_approval":
            response = sock.recv(1024)
            return json.loads(response.decode())
        
        sock.close()
    except Exception as e:
        pass  # Socket not available
    return None

# Event structure
event = {
    "source": "SERVICE_NAME",  # claude, chatgpt, gemini, etc.
    "session_id": os.environ.get("SESSION_ID", "unknown"),
    "cwd": os.getcwd(),
    "event": "EventType",  # SessionStart, PreToolUse, PermissionRequest, etc.
    "status": "status",    # idle, processing, waiting_for_approval, etc.
    "tool": None,          # Tool name if applicable
    "tool_input": None,    # Tool arguments if applicable
    "tool_use_id": None,   # Unique ID for permission correlation
}

result = send_event(event)
if result:
    print(json.dumps(result))
```

---

## Status Indicators (All Pixel Art)

### Processing (Animated Hourglass)
```
    ●    
  ● ● ●  
    ●    
● ● ● ● ●
    ●    
  ● ● ●  
    ●    
```

### Waiting for Input (Speech Bubble)
```
 ●●●●●●● 
●       ●
● ●●●   ●
●       ●
 ●●●●●●● 
  ●      
 ●       
```

### Waiting for Approval (Hand)
```
  ● ● ●  
 ● ● ● ● 
 ● ● ● ● 
  ●●●●●  
   ●●●   
   ●●●   
    ●    
```

### Idle (Dash)
```
        
        
        
  ●●●   
        
        
        
```

---

## Color Utilities

```swift
import SwiftUI

enum AIService: String, CaseIterable, Identifiable {
    case claude
    case chatgpt
    case gemini
    case grok
    case copilot
    case opencode
    
    var id: String { rawValue }
    
    var brandColor: Color {
        switch self {
        case .claude:   return Color(hex: 0xDA7756)
        case .chatgpt:  return Color(hex: 0x74AA9C)
        case .gemini:   return Color(hex: 0x4796E3)
        case .grok:     return Color(hex: 0xFFA62E)
        case .copilot:  return Color(hex: 0x09AA6C)
        case .opencode: return Color(hex: 0x7C3AED)
        }
    }
    
    var displayName: String {
        switch self {
        case .claude:   return "Claude"
        case .chatgpt:  return "ChatGPT"
        case .gemini:   return "Gemini"
        case .grok:     return "Grok"
        case .copilot:  return "Copilot"
        case .opencode: return "OpenCode"
        }
    }
}

extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}
```

---

## Socket Event Types

| Event | Description | Fields |
|-------|-------------|--------|
| `SessionStart` | New session started | source, session_id, cwd, pid |
| `SessionEnd` | Session ended | source, session_id |
| `PreToolUse` | Tool about to run | source, session_id, tool, tool_input, tool_use_id |
| `PostToolUse` | Tool completed | source, session_id, tool, tool_use_id |
| `PermissionRequest` | Needs user approval | source, session_id, tool, tool_input, tool_use_id |
| `Notification` | General notification | source, session_id, message, notification_type |
| `PreCompact` | Context compacting | source, session_id |

---

## Permission Response

```json
{
  "decision": "allow",  // or "deny"
  "reason": "optional reason for denial"
}
```

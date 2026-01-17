#!/usr/bin/env python3
"""
AI Island Hook Script
Sends session state updates to AI Island via Unix socket.
Supports multiple AI services: Claude, ChatGPT, Gemini, Grok, Copilot, OpenCode
"""

import json
import os
import socket
import sys

SOCKET_PATH = "/tmp/ai-island.sock"


def send_to_socket(data: dict) -> dict | None:
    """Send JSON data to AI Island socket and optionally receive response."""
    if not os.path.exists(SOCKET_PATH):
        return None

    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.settimeout(86400)
        sock.connect(SOCKET_PATH)

        payload = json.dumps(data).encode("utf-8")
        sock.sendall(payload)

        expects_response = (
            data.get("event") == "PermissionRequest"
            and data.get("status") == "waiting_for_approval"
        )

        if expects_response:
            sock.settimeout(86400)
            response_data = b""
            while True:
                chunk = sock.recv(4096)
                if not chunk:
                    break
                response_data += chunk
                try:
                    return json.loads(response_data.decode("utf-8"))
                except json.JSONDecodeError:
                    continue

        sock.close()
        return None

    except Exception as e:
        print(f"Socket error: {e}", file=sys.stderr)
        return None


def get_session_info() -> dict:
    """Extract session info from environment variables."""
    return {
        "session_id": os.environ.get("CLAUDE_SESSION_ID", ""),
        "cwd": os.environ.get("CLAUDE_CWD", os.getcwd()),
        "source": os.environ.get("AI_SOURCE", "claude"),
    }


def get_process_info() -> dict:
    """Get process information."""
    pid = None
    tty = None

    try:
        pid = os.getppid()
    except:
        pass

    try:
        tty = os.ttyname(sys.stdin.fileno())
    except:
        pass

    return {"pid": pid, "tty": tty}


def main():
    hook_input = json.load(sys.stdin)

    session = get_session_info()
    process = get_process_info()

    event_name = os.environ.get("CLAUDE_HOOK_EVENT", "Unknown")

    status = "idle"
    tool = None
    tool_input = None
    tool_use_id = None

    if event_name == "PermissionRequest":
        status = "waiting_for_approval"
        tool = hook_input.get("tool_name")
        tool_input = hook_input.get("tool_input")
        tool_use_id = hook_input.get("tool_use_id")
    elif event_name == "PreToolUse":
        status = "running_tool"
        tool = hook_input.get("tool_name")
        tool_input = hook_input.get("tool_input")
        tool_use_id = hook_input.get("tool_use_id")
    elif event_name == "PostToolUse":
        status = "processing"
        tool = hook_input.get("tool_name")
        tool_use_id = hook_input.get("tool_use_id")
    elif event_name == "UserPromptSubmit":
        status = "processing"
    elif event_name == "Stop":
        status = "waiting_for_input"
    elif event_name == "SessionStart":
        status = "starting"
    elif event_name == "SessionEnd":
        status = "idle"
    elif event_name == "PreCompact":
        status = "compacting"
    elif event_name == "Notification":
        status = "notification"

    payload = {
        "session_id": session["session_id"],
        "cwd": session["cwd"],
        "source": session["source"],
        "event": event_name,
        "status": status,
        "pid": process["pid"],
        "tty": process["tty"],
        "tool": tool,
        "tool_input": tool_input,
        "tool_use_id": tool_use_id,
        "notification_type": hook_input.get("type")
        if event_name == "Notification"
        else None,
        "message": hook_input.get("message") if event_name == "Notification" else None,
    }

    response = send_to_socket(payload)

    if response and event_name == "PermissionRequest":
        decision = response.get("decision", "ask")
        reason = response.get("reason")

        output = {"decision": decision}
        if reason:
            output["reason"] = reason

        print(json.dumps(output))
        return

    print(json.dumps({}))


if __name__ == "__main__":
    main()

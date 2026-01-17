//
//  AIIslandApp.swift
//  AIIsland
//
//  Dynamic Island for monitoring multiple AI coding assistants
//  Supports: Claude, ChatGPT, Gemini, Grok, GitHub Copilot, OpenCode
//

import SwiftUI

@main
struct AIIslandApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We use a completely custom window, so no default scene needed
        Settings {
            EmptyView()
        }
    }
}

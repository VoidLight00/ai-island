//
//  NotchView.swift
//  AIIsland
//
//  Main notch UI view with Dynamic Island-style animations
//

import SwiftUI

struct NotchView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    private let openAnimation = Animation.spring(response: 0.42, dampingFraction: 0.8, blendDuration: 0)
    private let closeAnimation = Animation.spring(response: 0.45, dampingFraction: 1.0, blendDuration: 0)
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                notchLayout
            }
        }
        .animation(viewModel.status == .opened ? openAnimation : closeAnimation, value: viewModel.status)
    }
    
    @ViewBuilder
    private var notchLayout: some View {
        if viewModel.status == .opened {
            openedContent
        } else {
            closedContent
        }
    }
    
    private var closedContent: some View {
        NotchShape(cornerRadius: 8)
            .fill(Color.black)
            .frame(
                width: viewModel.deviceNotchRect.width,
                height: viewModel.deviceNotchRect.height
            )
            .overlay {
                HStack(spacing: 4) {
                    Circle()
                        .fill(TerminalColors.green)
                        .frame(width: 6, height: 6)
                    Text("AI Island")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(viewModel.status == .popping ? 1 : 0)
            }
    }
    
    private var openedContent: some View {
        NotchShape(cornerRadius: 20)
            .fill(Color.black.opacity(0.95))
            .frame(
                width: viewModel.openedSize.width,
                height: viewModel.openedSize.height
            )
            .overlay(alignment: .top) {
                VStack(spacing: 12) {
                    headerView
                    contentView
                }
                .padding(16)
                .frame(width: viewModel.openedSize.width, height: viewModel.openedSize.height, alignment: .top)
            }
    }
    
    private var headerView: some View {
        HStack {
            // AI Characters showcase
            HStack(spacing: -4) {
                ForEach(AIService.allCases.prefix(4), id: \.self) { service in
                    if service != .unknown {
                        Circle()
                            .fill(service.brandColor.opacity(0.8))
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
            }
            
            Text("AI Island")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { viewModel.toggleMenu() }) {
                Image(systemName: viewModel.contentType == .menu ? "xmark" : "gear")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.contentType {
        case .instances:
            AIInstancesView()
        case .menu:
            AIMenuView()
        case .chat(let session):
            AIChatView(session: session)
        }
    }
}

// MARK: - Notch Shape

struct NotchShape: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }
}

// MARK: - AI Instances View

struct AIInstancesView: View {
    @ObservedObject private var sessionMonitor = SessionMonitor.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if sessionMonitor.sessions.isEmpty {
                emptyState
                supportedServicesGrid
            } else {
                sessionsList
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No active AI sessions")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Run an AI coding assistant in terminal")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.3))
        }
    }
    
    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(sessionMonitor.sessions) { session in
                    SessionRow(session: session)
                }
            }
        }
    }
    
    private var supportedServicesGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Supported Services")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(AIService.allCases, id: \.self) { service in
                    if service != .unknown {
                        ServiceBadge(service: service)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

struct SessionRow: View {
    let session: SessionState
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            AICharacterIcon(service: session.aiService, size: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.projectName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text(session.aiService.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(session.aiService.brandColor)
                    
                    Text(session.phase.displayText)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            sessionStatusIndicator
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered ? session.aiService.brandColor.opacity(0.15) : Color.white.opacity(0.05))
        )
        .onHover { isHovered = $0 }
    }
    
    @ViewBuilder
    private var sessionStatusIndicator: some View {
        switch session.phase {
        case .processing, .compacting:
            ProcessingSpinner(color: session.aiService.brandColor)
        case .waitingForApproval:
            Circle()
                .fill(TerminalColors.amber)
                .frame(width: 8, height: 8)
        case .waitingForInput:
            Circle()
                .fill(TerminalColors.green)
                .frame(width: 8, height: 8)
        case .idle:
            Circle()
                .fill(TerminalColors.dim)
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Service Badge

struct ServiceBadge: View {
    let service: AIService
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 4) {
            AICharacterIcon(service: service, size: 28)
            
            Text(service.displayName)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(service.brandColor.opacity(isHovered ? 1 : 0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? service.brandColor.opacity(0.15) : Color.white.opacity(0.05))
        )
        .onHover { isHovered = $0 }
    }
}

// MARK: - AI Menu View

struct AIMenuView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 2) {
                MenuItem(title: "About AI Island", icon: "info.circle", action: {})
                MenuItem(title: "Check for Updates", icon: "arrow.clockwise", action: {})
                MenuItem(title: "Install Hooks", icon: "link.badge.plus", action: {})
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 4)
                
                MenuItem(title: "Quit", icon: "power", color: TerminalColors.red, action: {
                    NSApplication.shared.terminate(nil)
                })
            }
            
            Spacer()
        }
    }
}

// MARK: - Menu Item

struct MenuItem: View {
    let title: String
    let icon: String
    var color: Color = .white
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(title)
                Spacer()
            }
            .font(.system(size: 12))
            .foregroundColor(color.opacity(isHovered ? 1 : 0.8))
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.white.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

// MARK: - AI Chat View

struct AIChatView: View {
    let session: SessionState
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with AI character
            HStack {
                AICharacterIcon(service: session.aiService, size: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.displayTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(session.aiService.displayName)
                        .font(.system(size: 10))
                        .foregroundColor(session.aiService.brandColor)
                }
                
                Spacer()
                
                // Status indicator
                sessionStatusView
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            // Chat content or permission request
            if session.phase.isWaitingForApproval {
                permissionRequestView
            } else {
                chatHistoryView
            }
        }
    }
    
    @ViewBuilder
    private var sessionStatusView: some View {
        switch session.phase {
        case .processing, .compacting:
            ProcessingSpinner(color: session.aiService.brandColor)
        case .waitingForApproval:
            ProcessingSpinner(color: TerminalColors.amber)
        case .waitingForInput:
            Circle()
                .fill(TerminalColors.green)
                .frame(width: 8, height: 8)
        case .idle:
            Circle()
                .fill(TerminalColors.dim)
                .frame(width: 8, height: 8)
        }
    }
    
    private var permissionRequestView: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Permission Required")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(TerminalColors.amber)
                
                if let toolName = session.pendingToolName {
                    Text(toolName)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                if let toolInput = session.pendingToolInput {
                    Text(toolInput)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(TerminalColors.amber.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(TerminalColors.amber.opacity(0.3), lineWidth: 1)
                    )
            )
            
            HStack(spacing: 12) {
                Button {
                    denyPermission()
                } label: {
                    Text("Deny")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Button {
                    approvePermission()
                } label: {
                    Text("Allow")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.9))
                        )
                }
                .buttonStyle(.plain)
                .keyboardShortcut("y", modifiers: .command)
            }
            
            Spacer()
        }
    }
    
    private var chatHistoryView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(session.chatItems) { item in
                    chatBubble(item)
                }
            }
        }
    }
    
    private func chatBubble(_ item: ChatHistoryItem) -> some View {
        HStack {
            if item.role == "user" { Spacer() }
            
            Text(item.content)
                .font(.system(size: 11))
                .foregroundColor(.white)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(item.role == "user" 
                            ? session.aiService.brandColor.opacity(0.3) 
                            : Color.white.opacity(0.1))
                )
            
            if item.role != "user" { Spacer() }
        }
    }
    
    private func approvePermission() {
        HookSocketServer.shared.respondToPermissionBySession(
            sessionId: session.sessionId,
            decision: "allow"
        )
    }
    
    private func denyPermission() {
        HookSocketServer.shared.respondToPermissionBySession(
            sessionId: session.sessionId,
            decision: "deny"
        )
    }
}

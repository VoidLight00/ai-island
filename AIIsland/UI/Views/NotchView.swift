import SwiftUI

struct NotchView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                if viewModel.status == .opened {
                    openedContent
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    closedContent
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .animation(viewModel.animation, value: viewModel.status)
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
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 6, height: 6)
                    Text("AI Island")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(viewModel.status == .popping ? 1 : 0)
            }
    }
    
    private var openedContent: some View {
        VStack(spacing: 0) {
            NotchShape(cornerRadius: 20)
                .fill(Color.black.opacity(0.95))
                .frame(
                    width: viewModel.openedSize.width,
                    height: viewModel.openedSize.height
                )
                .overlay {
                    VStack(spacing: 12) {
                        headerView
                        contentView
                    }
                    .padding(16)
                }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("AI Island")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { viewModel.toggleMenu() }) {
                Image(systemName: viewModel.contentType == .menu ? "xmark" : "gear")
                    .foregroundColor(.white.opacity(0.7))
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

struct NotchShape: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }
}

struct AIInstancesView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("No active AI sessions")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Start a Claude, ChatGPT, Gemini, or other AI coding assistant")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AIMenuView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(spacing: 8) {
                menuItem(title: "About AI Island", icon: "info.circle")
                menuItem(title: "Check for Updates", icon: "arrow.clockwise")
                Divider().background(Color.white.opacity(0.2))
                menuItem(title: "Quit", icon: "power")
            }
            
            Spacer()
        }
    }
    
    private func menuItem(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
            Text(title)
            Spacer()
        }
        .font(.system(size: 12))
        .foregroundColor(.white.opacity(0.8))
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

struct AIChatView: View {
    let session: SessionState
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(session.aiService.brandColor)
                    .frame(width: 8, height: 8)
                
                Text(session.displayTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(session.aiService.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(session.aiService.brandColor)
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(session.chatItems) { item in
                        chatBubble(item)
                    }
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
                        .fill(item.role == "user" ? Color.blue.opacity(0.3) : Color.white.opacity(0.1))
                )
            
            if item.role != "user" { Spacer() }
        }
    }
}

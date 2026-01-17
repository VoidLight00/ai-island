//
//  AICharacters.swift
//  AIIsland
//
//  Pixel-art characters for each AI service
//

import SwiftUI

// MARK: - Color Extension for Hex (local to avoid conflicts)
private extension Color {
    init(hexValue: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hexValue >> 16) & 0xFF) / 255.0,
            green: Double((hexValue >> 8) & 0xFF) / 255.0,
            blue: Double(hexValue & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Claude Character (Crab)
struct ClaudeCharacter: View {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Color(hexValue: 0xDA7756)) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 11.0
            let dotSize = scale
            
            // 11x8 crab pattern
            let dots: [(Int, Int)] = [
                // Eyes row
                (2, 0), (8, 0),
                // Head row
                (3, 1), (4, 1), (5, 1), (6, 1), (7, 1),
                // Body top
                (2, 2), (3, 2), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),
                // Body middle with claws
                (0, 3), (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3), (8, 3), (9, 3), (10, 3),
                // Claw tips
                (0, 4), (10, 4),
                // Body lower
                (2, 4), (3, 4), (4, 4), (5, 4), (6, 4), (7, 4), (8, 4),
                // Legs row 1
                (1, 5), (3, 5), (5, 5), (7, 5), (9, 5),
                // Legs row 2
                (0, 6), (2, 6), (4, 6), (6, 6), (8, 6), (10, 6),
                // Leg tips
                (0, 7), (10, 7),
            ]
            
            for (x, y) in dots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: size, height: size * 8/11)
    }
}

// MARK: - ChatGPT Character (Robot Head)
struct ChatGPTCharacter: View {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Color(hexValue: 0x74AA9C)) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 8.0
            let dotSize = scale
            
            // 8x8 robot head
            let dots: [(Int, Int)] = [
                // Antenna
                (3, 0), (4, 0),
                // Top of head
                (2, 1), (3, 1), (4, 1), (5, 1),
                // Head sides
                (1, 2), (2, 2), (5, 2), (6, 2),
                // Eyes row
                (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3),
                // Eye pupils
                (2, 4), (5, 4),
                // Mouth row
                (1, 5), (2, 5), (3, 5), (4, 5), (5, 5), (6, 5),
                // Mouth
                (2, 6), (3, 6), (4, 6), (5, 6),
                // Chin
                (3, 7), (4, 7),
            ]
            
            for (x, y) in dots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Gemini Character (Star/Sparkle)
struct GeminiCharacter: View {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Color(hexValue: 0x4796E3)) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 8.0
            let dotSize = scale
            
            // 8x8 star pattern
            let dots: [(Int, Int)] = [
                // Top point
                (3, 0), (4, 0),
                (3, 1), (4, 1),
                // Upper spread
                (2, 2), (3, 2), (4, 2), (5, 2),
                // Middle row (widest)
                (0, 3), (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3), (7, 3),
                (0, 4), (1, 4), (2, 4), (3, 4), (4, 4), (5, 4), (6, 4), (7, 4),
                // Lower spread
                (2, 5), (3, 5), (4, 5), (5, 5),
                // Bottom point
                (3, 6), (4, 6),
                (3, 7), (4, 7),
            ]
            
            for (x, y) in dots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Grok Character (Lightning Bolt)
struct GrokCharacter: View {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Color(hexValue: 0xFFA62E)) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 8.0
            let dotSize = scale
            
            // 8x8 lightning bolt
            let dots: [(Int, Int)] = [
                // Top
                (4, 0), (5, 0), (6, 0),
                (3, 1), (4, 1), (5, 1),
                (2, 2), (3, 2), (4, 2),
                // Middle bar
                (1, 3), (2, 3), (3, 3), (4, 3), (5, 3), (6, 3),
                (3, 4), (4, 4), (5, 4),
                // Bottom
                (3, 5), (4, 5),
                (2, 6), (3, 6),
                (1, 7), (2, 7),
            ]
            
            for (x, y) in dots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - GitHub Copilot Character (Pilot Goggles)
struct CopilotCharacter: View {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = Color(hexValue: 0x09AA6C)) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 8.0
            let dotSize = scale
            
            // 8x8 goggles
            let dots: [(Int, Int)] = [
                // Top strap
                (0, 1), (1, 1), (2, 1), (5, 1), (6, 1), (7, 1),
                // Goggle frames
                (0, 2), (1, 2), (2, 2), (3, 2), (4, 2), (5, 2), (6, 2), (7, 2),
                // Lenses outer
                (0, 3), (3, 3), (4, 3), (7, 3),
                // Lenses (empty center for glass effect)
                (0, 4), (3, 4), (4, 4), (7, 4),
                // Bottom of goggles
                (0, 5), (1, 5), (2, 5), (3, 5), (4, 5), (5, 5), (6, 5), (7, 5),
                // Nose bridge
                (3, 6), (4, 6),
            ]
            
            for (x, y) in dots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - OpenCode Character (Terminal Cursor)
struct OpenCodeCharacter: View {
    let size: CGFloat
    let color: Color
    @State private var isBlinking = false
    
    init(size: CGFloat = 24, color: Color = Color(hexValue: 0x7C3AED)) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 8.0
            let dotSize = scale
            
            // 8x8 terminal with cursor
            let frameDots: [(Int, Int)] = [
                // Top bar
                (0, 0), (1, 0), (2, 0), (3, 0), (4, 0), (5, 0), (6, 0), (7, 0),
                // Sides
                (0, 1), (7, 1),
                (0, 2), (7, 2),
                (0, 3), (7, 3),
                (0, 4), (7, 4),
                (0, 5), (7, 5),
                (0, 6), (7, 6),
                // Bottom bar
                (0, 7), (1, 7), (2, 7), (3, 7), (4, 7), (5, 7), (6, 7), (7, 7),
            ]
            
            // Draw frame
            for (x, y) in frameDots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
            
            // Cursor (inside terminal)
            let cursorDots: [(Int, Int)] = [
                (2, 3), (3, 3),
                (2, 4), (3, 4),
            ]
            
            for (x, y) in cursorDots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color.opacity(isBlinking ? 1.0 : 0.3)))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        }
    }
}

// MARK: - Unknown Service Character (Question Mark)
struct UnknownCharacter: View {
    let size: CGFloat
    let color: Color
    
    init(size: CGFloat = 24, color: Color = .gray) {
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Canvas { context, canvasSize in
            let scale = size / 8.0
            let dotSize = scale
            
            // 8x8 question mark
            let dots: [(Int, Int)] = [
                // Top curve
                (2, 0), (3, 0), (4, 0), (5, 0),
                (1, 1), (2, 1), (5, 1), (6, 1),
                (1, 2), (5, 2), (6, 2),
                // Middle curve
                (4, 3), (5, 3),
                (3, 4), (4, 4),
                (3, 5),
                // Dot
                (3, 7),
            ]
            
            for (x, y) in dots {
                let rect = CGRect(
                    x: CGFloat(x) * scale,
                    y: CGFloat(y) * scale,
                    width: dotSize,
                    height: dotSize
                )
                context.fill(Path(rect), with: .color(color))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - AI Character Icon (Service Switcher)
struct AICharacterIcon: View {
    let service: AIService
    let size: CGFloat
    
    init(service: AIService, size: CGFloat = 24) {
        self.service = service
        self.size = size
    }
    
    var body: some View {
        Group {
            switch service {
            case .claude:
                ClaudeCharacter(size: size, color: service.brandColor)
            case .chatgpt:
                ChatGPTCharacter(size: size, color: service.brandColor)
            case .gemini:
                GeminiCharacter(size: size, color: service.brandColor)
            case .grok:
                GrokCharacter(size: size, color: service.brandColor)
            case .copilot:
                CopilotCharacter(size: size, color: service.brandColor)
            case .opencode:
                OpenCodeCharacter(size: size, color: service.brandColor)
            case .unknown:
                UnknownCharacter(size: size, color: service.brandColor)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 16) {
        ForEach(AIService.allCases, id: \.self) { service in
            VStack {
                AICharacterIcon(service: service, size: 32)
                Text(service.displayName)
                    .font(.caption2)
            }
        }
    }
    .padding()
    .background(Color.black)
}

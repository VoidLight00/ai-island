import AppKit
import SwiftUI

class WindowManager {
    var windowController: NotchWindowController?
    
    func setupNotchWindow() -> NotchWindowController? {
        windowController?.close()
        windowController = nil
        
        guard let screen = NSScreen.main else { return nil }
        
        let hasPhysicalNotch = screen.hasPhysicalNotch
        let deviceNotchRect = screen.notchRect ?? CGRect(
            x: screen.frame.width / 2 - 100,
            y: screen.frame.height - 32,
            width: 200,
            height: 32
        )
        
        let windowHeight: CGFloat = 600
        let windowFrame = CGRect(
            x: screen.frame.origin.x,
            y: screen.frame.origin.y + screen.frame.height - windowHeight,
            width: screen.frame.width,
            height: windowHeight
        )
        
        let panel = NotchPanel(
            contentRect: windowFrame,
            styleMask: [],
            backing: .buffered,
            defer: false
        )
        
        let controller = NotchWindowController(
            window: panel,
            deviceNotchRect: deviceNotchRect,
            screenRect: screen.frame,
            windowHeight: windowHeight,
            hasPhysicalNotch: hasPhysicalNotch
        )
        
        windowController = controller
        controller.showWindow(nil)
        
        return controller
    }
}

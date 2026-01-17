import AppKit
import SwiftUI

class NotchWindowController: NSWindowController {
    private var viewModel: NotchViewModel
    
    init(
        window: NSPanel,
        deviceNotchRect: CGRect,
        screenRect: CGRect,
        windowHeight: CGFloat,
        hasPhysicalNotch: Bool
    ) {
        self.viewModel = NotchViewModel(
            deviceNotchRect: deviceNotchRect,
            screenRect: screenRect,
            windowHeight: windowHeight,
            hasPhysicalNotch: hasPhysicalNotch
        )
        
        super.init(window: window)
        
        let hostingView = NSHostingView(
            rootView: NotchView()
                .environmentObject(viewModel)
        )
        
        hostingView.frame = window.contentView?.bounds ?? .zero
        hostingView.autoresizingMask = [.width, .height]
        window.contentView = hostingView
        
        viewModel.performBootAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMouseInteraction(enabled: Bool) {
        (window as? NotchPanel)?.ignoresMouseEvents = !enabled
    }
}

import AppKit

struct NotchGeometry {
    let deviceNotchRect: CGRect
    let screenRect: CGRect
    let windowHeight: CGFloat
    
    var notchScreenRect: CGRect {
        CGRect(
            x: deviceNotchRect.minX,
            y: screenRect.height - deviceNotchRect.height,
            width: deviceNotchRect.width,
            height: deviceNotchRect.height
        )
    }
    
    func isPointInNotch(_ point: CGPoint) -> Bool {
        let expandedRect = notchScreenRect.insetBy(dx: -20, dy: -10)
        return expandedRect.contains(point)
    }
    
    func isPointInOpenedPanel(_ point: CGPoint, size: CGSize) -> Bool {
        let panelRect = CGRect(
            x: screenRect.midX - size.width / 2,
            y: screenRect.height - size.height,
            width: size.width,
            height: size.height
        )
        return panelRect.contains(point)
    }
    
    func isPointOutsidePanel(_ point: CGPoint, size: CGSize) -> Bool {
        !isPointInNotch(point) && !isPointInOpenedPanel(point, size: size)
    }
}

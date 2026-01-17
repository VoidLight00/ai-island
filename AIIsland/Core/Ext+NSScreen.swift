import AppKit

extension NSScreen {
    var hasPhysicalNotch: Bool {
        guard let auxiliaryTopLeftArea = auxiliaryTopLeftArea,
              let auxiliaryTopRightArea = auxiliaryTopRightArea else {
            return false
        }
        return auxiliaryTopLeftArea.width > 0 && auxiliaryTopRightArea.width > 0
    }
    
    var notchRect: CGRect? {
        guard hasPhysicalNotch,
              let topLeft = auxiliaryTopLeftArea,
              let topRight = auxiliaryTopRightArea else {
            return nil
        }
        
        let notchX = topLeft.maxX
        let notchWidth = topRight.minX - topLeft.maxX
        let notchHeight: CGFloat = 32
        
        return CGRect(
            x: notchX,
            y: frame.height - notchHeight,
            width: notchWidth,
            height: notchHeight
        )
    }
}

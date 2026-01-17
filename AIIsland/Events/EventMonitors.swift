import AppKit
import Combine

class EventMonitors {
    static let shared = EventMonitors()
    
    let mouseLocation = PassthroughSubject<CGPoint, Never>()
    let mouseDown = PassthroughSubject<Void, Never>()
    
    private var mouseMoveMonitor: Any?
    private var mouseDownMonitor: Any?
    
    private init() {
        setupMonitors()
    }
    
    private func setupMonitors() {
        mouseMoveMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved, .mouseEntered, .mouseExited]
        ) { [weak self] event in
            self?.mouseLocation.send(NSEvent.mouseLocation)
        }
        
        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: .leftMouseDown
        ) { [weak self] event in
            self?.mouseDown.send()
        }
    }
    
    deinit {
        if let monitor = mouseMoveMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = mouseDownMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}

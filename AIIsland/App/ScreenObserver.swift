import AppKit

class ScreenObserver {
    private var observer: NSObjectProtocol?
    private let onChange: () -> Void
    
    init(onChange: @escaping () -> Void) {
        self.onChange = onChange
        
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onChange()
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

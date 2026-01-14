import Cocoa
import SwiftUI

final class SettingsWindowController: NSWindowController {
    init() {
        let viewController = NSHostingController(rootView: SettingsView())
        let window = NSWindow(contentViewController: viewController)
        window.title = "Tactile"
        window.setContentSize(NSSize(width: 900, height: 600))
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        return nil
    }
}

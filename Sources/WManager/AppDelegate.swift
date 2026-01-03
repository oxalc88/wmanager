import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let windowManager = WindowManager()
    private let overlayController = OverlayController()
    private var hotkeyManager: HotkeyManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AccessibilityHelper.ensureTrusted()
        hotkeyManager = HotkeyManager(
            windowManager: windowManager,
            overlayController: overlayController
        )
        hotkeyManager?.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.stop()
    }
}

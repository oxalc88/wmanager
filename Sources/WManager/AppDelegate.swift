import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate, StatusBarControllerDelegate {
    private let windowManager = WindowManager()
    private let overlayController = OverlayController()
    private var hotkeyManager: HotkeyManager?
    private var statusBarController: StatusBarController?
    private var settingsWindowController: SettingsWindowController?
    private var isRunning = true

    func applicationDidFinishLaunching(_ notification: Notification) {
        AccessibilityHelper.ensureTrusted()
        hotkeyManager = HotkeyManager(
            windowManager: windowManager,
            overlayController: overlayController
        )
        hotkeyManager?.start()
        statusBarController = StatusBarController(isRunning: isRunning)
        statusBarController?.delegate = self
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.stop()
    }

    func statusBarControllerDidToggle(_ controller: StatusBarController, shouldRun: Bool) {
        isRunning = shouldRun
        if shouldRun {
            hotkeyManager?.start()
        } else {
            hotkeyManager?.stop()
        }
        statusBarController?.updateRunningState(shouldRun)
    }

    func statusBarControllerDidRequestQuit(_ controller: StatusBarController) {
        NSApp.terminate(nil)
    }

    func statusBarControllerDidRequestSettings(_ controller: StatusBarController) {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

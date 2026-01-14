import Cocoa

protocol StatusBarControllerDelegate: AnyObject {
    func statusBarControllerDidToggle(_ controller: StatusBarController, shouldRun: Bool)
    func statusBarControllerDidRequestSettings(_ controller: StatusBarController)
    func statusBarControllerDidRequestQuit(_ controller: StatusBarController)
}

final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let menu: NSMenu
    private let toggleItem: NSMenuItem
    private let settingsItem: NSMenuItem
    private let quitItem: NSMenuItem
    private var isRunning: Bool

    weak var delegate: StatusBarControllerDelegate?

    init(isRunning: Bool) {
        self.isRunning = isRunning
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        menu = NSMenu()
        toggleItem = NSMenuItem(title: "", action: #selector(toggleRunning), keyEquivalent: "")
        settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        super.init()
        toggleItem.target = self
        settingsItem.target = self
        quitItem.target = self

        if let button = statusItem.button {
            button.toolTip = "WManager"
            if let image = StatusBarController.statusBarImage() {
                button.image = image
                button.imagePosition = .imageOnly
                button.imageScaling = .scaleProportionallyDown
                button.title = ""
            } else {
                button.title = "🪟"
            }
        }
        statusItem.length = NSStatusItem.squareLength

        menu.addItem(toggleItem)
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        statusItem.menu = menu
        updateToggleTitle()
    }

    func updateRunningState(_ running: Bool) {
        isRunning = running
        updateToggleTitle()
    }

    @objc private func toggleRunning() {
        isRunning.toggle()
        updateToggleTitle()
        delegate?.statusBarControllerDidToggle(self, shouldRun: isRunning)
    }

    @objc private func quitApp() {
        delegate?.statusBarControllerDidRequestQuit(self)
    }

    @objc private func openSettings() {
        delegate?.statusBarControllerDidRequestSettings(self)
    }

    private func updateToggleTitle() {
        toggleItem.title = isRunning ? "Stop WManager" : "Start WManager"
    }

    private static func statusBarImage() -> NSImage? {
        guard let image = loadStatusBarAsset() else { return nil }
        let targetSize = NSSize(width: 22, height: 22)
        let inset: CGFloat = 1
        let available = NSSize(width: targetSize.width - inset * 2, height: targetSize.height - inset * 2)
        let scale = min(available.width / image.size.width, available.height / image.size.height)
        let scaledSize = NSSize(width: image.size.width * scale, height: image.size.height * scale)
        let origin = NSPoint(
            x: (targetSize.width - scaledSize.width) / 2,
            y: (targetSize.height - scaledSize.height) / 2
        )

        let rendered = NSImage(size: targetSize)
        rendered.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(
            in: NSRect(origin: origin, size: scaledSize),
            from: NSRect(origin: .zero, size: image.size),
            operation: .sourceOver,
            fraction: 1.0
        )
        rendered.unlockFocus()
        rendered.isTemplate = true
        return rendered
    }

    private static func loadStatusBarAsset() -> NSImage? {
        let bundle = Bundle.module
        let candidates = [
            ("menubar_icon", "pdf"),
            ("logo", "pdf"),
            ("logo", "png")
        ]
        for (name, ext) in candidates {
            if let url = bundle.url(forResource: name, withExtension: ext),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}

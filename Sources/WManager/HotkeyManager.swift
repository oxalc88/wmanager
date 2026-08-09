import Cocoa

final class HotkeyManager {
    private let windowManager: WindowManager
    private let overlayController: OverlayController
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var overlaySelection = OverlaySelectionState()
    private var overlayLayout: LayoutPreset?
    private var shortcutsState: ShortcutsState
    private var shortcutsObserver: NSObjectProtocol?

    init(
        windowManager: WindowManager,
        overlayController: OverlayController
    ) {
        self.windowManager = windowManager
        self.overlayController = overlayController
        self.shortcutsState = ShortcutsStore.load()
        self.shortcutsObserver = NotificationCenter.default.addObserver(
            forName: .shortcutsDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.shortcutsState = ShortcutsStore.load()
        }
    }

    deinit {
        if let observer = shortcutsObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func start() {
        guard eventTap == nil else { return }

        let mask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.leftMouseDown.rawValue)
            | (1 << CGEventType.rightMouseDown.rawValue)
        let callback: CGEventTapCallBack = { proxy, type, event, userInfo in
            guard let userInfo = userInfo else { return Unmanaged.passUnretained(event) }
            let manager = Unmanaged<HotkeyManager>.fromOpaque(userInfo).takeUnretainedValue()
            return manager.handleEvent(proxy: proxy, type: type, event: event)
        }

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )

        guard let eventTap = eventTap else {
            NSLog("Failed to create event tap. Check Accessibility permission.")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if let runLoopSource = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func stop() {
        clearOverlaySelection()
        hideOverlay()
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
        runLoopSource = nil
        eventTap = nil
    }

    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap = eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return Unmanaged.passUnretained(event)
        }

        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        if let desktopAction = DesktopHotkeyMapping.match(keyCode: keyCode, flags: flags) {
            handleDesktopAction(desktopAction)
            return nil
        }

        if let layoutIndex = shortcutsState.layoutIndex(
            for: keyCode,
            flags: flags,
            allowAdditional: Settings.allowAdditionalModifiers
        ) {
            setActiveLayout(index: layoutIndex)
            clearOverlaySelection()
            hideOverlay()
            return nil
        }

        if overlayController.isVisible {
            if matchesShortcut(.toggleOverlay, keyCode: keyCode, flags: flags) {
                clearOverlaySelection()
                hideOverlay()
                return nil
            }
            return handleOverlayKey(event: event, keyCode: keyCode)
        }

        if matchesShortcut(.toggleOverlay, keyCode: keyCode, flags: flags) {
            clearOverlaySelection()
            if let screen = windowManager.focusedScreen() ?? NSScreen.main {
                let layout = currentLayout(for: screen)
                let selection = overlaySelection.selection.intersection(LayoutEngine.activeCells(for: layout))
                overlayLayout = layout
                overlayController.show(on: screen, selection: selection, layout: layout)
            }
            return nil
        }

        if matchesShortcut(.tileLeft, keyCode: keyCode, flags: flags) {
            windowManager.tileLeft()
            return nil
        }
        if matchesShortcut(.tileRight, keyCode: keyCode, flags: flags) {
            windowManager.tileRight()
            return nil
        }
        if matchesShortcut(.maximize, keyCode: keyCode, flags: flags) {
            windowManager.maximize()
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func handleDesktopAction(_ action: DesktopHotkeyMapping.Action) {
        let screen = windowManager.focusedScreen() ?? NSScreen.main
        switch action {
        case .switchToDesktop(let index):
            DesktopManager.switchToSpace(at: index, for: screen)
        case .moveToDesktop(let index):
            guard let windowID = windowManager.focusedWindowID() else { return }
            DesktopManager.moveWindow(windowID, toSpaceAt: index, for: screen)
            DesktopManager.switchToSpace(at: index, for: screen)
        }
    }

    private func handleOverlayKey(event: CGEvent, keyCode: CGKeyCode) -> Unmanaged<CGEvent>? {
        switch OverlayKeyAction.action(for: keyCode) {
        case .dismiss:
            clearOverlaySelection()
            hideOverlay()
            return nil
        case .cell(let cell):
            let layout = overlayLayout ?? currentLayout(for: windowManager.focusedScreen())
            guard LayoutEngine.activeCells(for: layout).contains(cell) else {
                return Unmanaged.passUnretained(event)
            }
            let result = overlaySelection.select(cell, maxSelectionCount: Settings.overlaySelectionMaxCount)
            overlayController.updateSelection(result.selection)
            windowManager.applyCells(result.selection, layout: layout)
            if result.reachedLimit {
                hideOverlay()
                overlaySelection.clear()
            }
            return nil
        case .passthrough:
            clearOverlaySelection()
            return Unmanaged.passUnretained(event)
        }
    }

    private func clearOverlaySelection() {
        overlaySelection.clear()
        if overlayController.isVisible {
            overlayController.updateSelection([])
        }
    }

    private func matchesShortcut(_ action: ShortcutAction, keyCode: CGKeyCode, flags: CGEventFlags) -> Bool {
        guard let shortcut = shortcutsState.shortcuts[action] else { return false }
        return shortcut.matches(keyCode: keyCode, flags: flags, allowAdditional: Settings.allowAdditionalModifiers)
    }

    private func currentLayout(for screen: NSScreen?) -> LayoutPreset {
        return LayoutStore.currentLayoutPreset(for: screen)
    }

    private func setActiveLayout(index: Int) {
        let screen = windowManager.focusedScreen() ?? NSScreen.main ?? NSScreen.screens.first
        LayoutStore.setActiveLayoutIndex(index, for: screen)
    }

    private func hideOverlay() {
        overlayController.hide()
        overlayLayout = nil
    }
}

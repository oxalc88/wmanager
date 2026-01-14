import Cocoa

final class HotkeyManager {
    private let windowManager: WindowManager
    private let overlayController: OverlayController
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var overlaySelection = OverlaySelectionState()
    private var overlayLayout: LayoutPreset?

    init(
        windowManager: WindowManager,
        overlayController: OverlayController
    ) {
        self.windowManager = windowManager
        self.overlayController = overlayController
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

        if matchesLayoutSelectionModifiers(event.flags),
           let layoutIndex = LayoutHotkeyMapping.layoutIndex(
                for: keyCode,
                layoutCount: Settings.layoutPresetCount
           ) {
            setActiveLayout(index: layoutIndex)
            clearOverlaySelection()
            hideOverlay()
            return nil
        }

        if overlayController.isVisible {
            if type == .leftMouseDown || type == .rightMouseDown {
                clearOverlaySelection()
                return Unmanaged.passUnretained(event)
            }
            if type == .keyDown {
                if matchesHotkeyModifiers(event.flags), keyCode == KeyCode.t {
                    clearOverlaySelection()
                    hideOverlay()
                    return nil
                }
                return handleOverlayKey(event: event, keyCode: keyCode)
            }
            return Unmanaged.passUnretained(event)
        }

        guard matchesHotkeyModifiers(event.flags) else {
            return Unmanaged.passUnretained(event)
        }

        switch keyCode {
        case KeyCode.leftArrow:
            windowManager.tileLeft()
            return nil
        case KeyCode.rightArrow:
            windowManager.tileRight()
            return nil
        case KeyCode.upArrow:
            windowManager.maximize()
            return nil
        case KeyCode.t:
            clearOverlaySelection()
            if let screen = windowManager.focusedScreen() ?? NSScreen.main {
                let layout = currentLayout(for: screen)
                let selection = overlaySelection.selection.intersection(LayoutEngine.activeCells(for: layout))
                overlayLayout = layout
                overlayController.show(on: screen, selection: selection, layout: layout)
            }
            return nil
        default:
            return Unmanaged.passUnretained(event)
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

    private func matchesHotkeyModifiers(_ flags: CGEventFlags) -> Bool {
        return matchesModifiers(flags, required: Settings.hotkeyModifiers)
    }

    private func matchesLayoutSelectionModifiers(_ flags: CGEventFlags) -> Bool {
        return matchesModifiers(flags, required: Settings.layoutSelectionModifiers)
    }

    private func matchesModifiers(_ flags: CGEventFlags, required: CGEventFlags) -> Bool {
        let relevant: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl, .maskShift]
        let filtered = flags.intersection(relevant)
        if Settings.allowAdditionalModifiers {
            return filtered.contains(required)
        }
        return filtered == required
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

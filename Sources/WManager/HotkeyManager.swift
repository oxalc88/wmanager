import Cocoa

final class HotkeyManager {
    private let windowManager: WindowManager
    private let overlayController: OverlayController
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var overlaySelection = OverlaySelectionState()

    init(windowManager: WindowManager, overlayController: OverlayController) {
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

        if overlayController.isVisible {
            if type == .leftMouseDown || type == .rightMouseDown {
                clearOverlaySelection()
                return Unmanaged.passUnretained(event)
            }
            if type == .keyDown {
                let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
                if matchesHotkeyModifiers(event.flags), keyCode == KeyCode.t {
                    clearOverlaySelection()
                    overlayController.hide()
                    return nil
                }
                return handleOverlayKey(event: event, keyCode: keyCode)
            }
            return Unmanaged.passUnretained(event)
        }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

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
                overlayController.show(on: screen, selection: overlaySelection.selection)
            }
            return nil
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleOverlayKey(event: CGEvent, keyCode: CGKeyCode) -> Unmanaged<CGEvent>? {
        if keyCode == KeyCode.escape {
            clearOverlaySelection()
            overlayController.hide()
            return nil
        }

        if let slot = Slot.fromKeyCode(keyCode) {
            let result = overlaySelection.select(slot, maxSelectionCount: Settings.overlaySelectionMaxCount)
            overlayController.updateSelection(result.selection)
            windowManager.applySlots(result.selection)
            if result.reachedLimit {
                overlayController.hide()
                overlaySelection.clear()
            }
            return nil
        }

        clearOverlaySelection()
        return Unmanaged.passUnretained(event)
    }

    private func clearOverlaySelection() {
        overlaySelection.clear()
        if overlayController.isVisible {
            overlayController.updateSelection([])
        }
    }

    private func matchesHotkeyModifiers(_ flags: CGEventFlags) -> Bool {
        let relevant: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl, .maskShift]
        let filtered = flags.intersection(relevant)
        if Settings.allowAdditionalModifiers {
            return filtered.contains(Settings.hotkeyModifiers)
        }
        return filtered == Settings.hotkeyModifiers
    }
}

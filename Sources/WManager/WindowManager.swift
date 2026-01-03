import Cocoa

final class WindowManager {
    func focusedScreen() -> NSScreen? {
        guard let window = focusedWindow() else { return nil }
        guard let frame = windowFrame(window) else { return nil }
        return screenForWindow(frame)
    }

    func tileLeft() {
        guard let target = focusedWindowTarget() else { return }
        applyFrame(TileFrames.halfLeft(in: target.screenFrame), to: target.window)
    }

    func tileRight() {
        guard let target = focusedWindowTarget() else { return }
        applyFrame(TileFrames.halfRight(in: target.screenFrame), to: target.window)
    }

    func maximize() {
        guard let target = focusedWindowTarget() else { return }
        applyFrame(TileFrames.maximized(in: target.screenFrame), to: target.window)
    }

    func applySlots(_ slots: Set<Slot>) {
        guard !slots.isEmpty else { return }
        guard let target = focusedWindowTarget() else { return }

        let frames = Slot.frames(in: target.screenFrame)
        var union = CGRect.null
        for slot in slots {
            guard let slotFrame = frames[slot] else { continue }
            union = union.union(slotFrame)
        }

        if !union.isNull {
            applyFrame(union, to: target.window)
        }
    }

    private func focusedWindowTarget() -> (window: AXUIElement, screenFrame: CGRect)? {
        guard let window = focusedWindow() else { return nil }
        guard let windowFrame = windowFrame(window) else { return nil }
        guard let screen = screenForWindow(windowFrame) else { return nil }
        return (window, screen.visibleFrame)
    }

    private func focusedWindow() -> AXUIElement? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(app.processIdentifier)

        var window: CFTypeRef?
        let focusedResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedWindowAttribute as CFString,
            &window
        )
        if focusedResult == .success, let window = window {
            return (window as! AXUIElement)
        }

        let mainResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXMainWindowAttribute as CFString,
            &window
        )
        if mainResult == .success, let window = window {
            return (window as! AXUIElement)
        }

        return nil
    }

    private func windowFrame(_ window: AXUIElement) -> CGRect? {
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?

        let positionResult = AXUIElementCopyAttributeValue(
            window,
            kAXPositionAttribute as CFString,
            &positionValue
        )
        let sizeResult = AXUIElementCopyAttributeValue(
            window,
            kAXSizeAttribute as CFString,
            &sizeValue
        )

        guard positionResult == .success, sizeResult == .success else { return nil }
        guard let positionValue = positionValue, let sizeValue = sizeValue else { return nil }

        var position = CGPoint.zero
        var size = CGSize.zero
        AXValueGetValue(positionValue as! AXValue, .cgPoint, &position)
        AXValueGetValue(sizeValue as! AXValue, .cgSize, &size)

        return CGRect(origin: position, size: size)
    }

    private func applyFrame(_ frame: CGRect, to window: AXUIElement) {
        var position = frame.origin
        var size = frame.size

        if let positionValue = AXValueCreate(.cgPoint, &position) {
            AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        }
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }

    private func screenForWindow(_ frame: CGRect) -> NSScreen? {
        let center = CGPoint(x: frame.midX, y: frame.midY)
        return NSScreen.screens.first { $0.frame.contains(center) } ?? NSScreen.main
    }
}

enum TileFrames {
    static func maximized(in frame: CGRect) -> CGRect {
        return frame.insetBy(dx: Settings.outerPadding, dy: Settings.outerPadding)
    }

    static func halfLeft(in frame: CGRect) -> CGRect {
        let content = frame.insetBy(dx: Settings.outerPadding, dy: Settings.outerPadding)
        let width = (content.width - Settings.innerGap) / 2
        return CGRect(
            x: content.minX,
            y: content.minY,
            width: width,
            height: content.height
        )
    }

    static func halfRight(in frame: CGRect) -> CGRect {
        let content = frame.insetBy(dx: Settings.outerPadding, dy: Settings.outerPadding)
        let width = (content.width - Settings.innerGap) / 2
        return CGRect(
            x: content.minX + width + Settings.innerGap,
            y: content.minY,
            width: width,
            height: content.height
        )
    }
}

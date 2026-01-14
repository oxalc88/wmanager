import Cocoa
import ApplicationServices

final class WindowManager {
    func focusedScreen() -> NSScreen? {
        guard let window = focusedWindow() else { return nil }
        guard let frame = windowFrame(window) else { return nil }
        return screenForWindow(frame)
    }

    func focusedWindowID() -> CGWindowID? {
        guard let window = focusedWindow() else { return nil }
        if let windowID = axWindowNumber(from: window) {
            return windowID
        }
        return matchingWindowID(from: window)
    }

    func tileLeft() {
        guard let target = focusedWindowTarget() else { return }
        let frame = TileFrames.halfLeft(in: target.visibleFrame)
        applyFrame(frame, to: target.window, screenFrame: target.screen.frame)
    }

    func tileRight() {
        guard let target = focusedWindowTarget() else { return }
        let frame = TileFrames.halfRight(in: target.visibleFrame)
        applyFrame(frame, to: target.window, screenFrame: target.screen.frame)
    }

    func maximize() {
        guard let target = focusedWindowTarget() else { return }
        let frame = TileFrames.maximized(in: target.visibleFrame)
        applyFrame(frame, to: target.window, screenFrame: target.screen.frame)
    }

    func applyCells(_ cells: Set<GridCell>, layout: LayoutPreset) {
        guard !cells.isEmpty else { return }
        guard let target = focusedWindowTarget() else { return }

        let frames = LayoutEngine.frames(in: target.visibleFrame, layout: layout)
        var union = CGRect.null
        for cell in cells {
            guard let cellFrame = frames[cell] else { continue }
            union = union.union(cellFrame)
        }

        if !union.isNull {
            applyFrame(union, to: target.window, screenFrame: target.screen.frame)
        }
    }

    private func focusedWindowTarget() -> (window: AXUIElement, screen: NSScreen, visibleFrame: CGRect)? {
        guard let window = focusedWindow() else { return nil }
        guard let windowFrame = windowFrame(window) else { return nil }
        guard let screen = screenForWindow(windowFrame) else { return nil }
        return (window, screen, screen.visibleFrame)
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

    private func axWindowNumber(from window: AXUIElement) -> CGWindowID? {
        var windowNumber: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(
            window,
            "AXWindowNumber" as CFString,
            &windowNumber
        )
        guard result == .success, let number = windowNumber as? NSNumber else { return nil }
        return CGWindowID(number.uint32Value)
    }

    private func matchingWindowID(from window: AXUIElement) -> CGWindowID? {
        var pid: pid_t = 0
        AXUIElementGetPid(window, &pid)
        guard pid != 0 else { return nil }
        guard let axFrame = windowFrame(window) else { return nil }
        guard let screen = screenForWindow(axFrame) else { return nil }
        let cocoaFrame = cocoaFrame(fromAX: axFrame, in: screen.frame)

        guard let infoList = CGWindowListCopyWindowInfo(
            [.excludeDesktopElements, .optionOnScreenOnly],
            kCGNullWindowID
        ) as? [[String: Any]] else {
            return nil
        }

        let tolerance: CGFloat = 8
        var bestMatch: (id: CGWindowID, score: CGFloat)?
        for info in infoList {
            guard let ownerPID = info[kCGWindowOwnerPID as String] as? NSNumber,
                  ownerPID.intValue == pid else {
                continue
            }
            if let layer = info[kCGWindowLayer as String] as? NSNumber,
               layer.intValue != 0 {
                continue
            }
            guard let bounds = cgRect(from: info[kCGWindowBounds as String]) else {
                continue
            }
            guard let number = info[kCGWindowNumber as String] as? NSNumber else { continue }

            let sizeDelta = abs(bounds.width - cocoaFrame.width) + abs(bounds.height - cocoaFrame.height)
            let originDelta = abs(bounds.minX - cocoaFrame.minX) + abs(bounds.minY - cocoaFrame.minY)
            let score = (sizeDelta * 2) + originDelta
            if sizeDelta <= tolerance * 2 {
                if bestMatch == nil || score < bestMatch!.score {
                    bestMatch = (CGWindowID(number.uint32Value), score)
                }
            }
        }

        return bestMatch?.id
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

    private func cocoaFrame(fromAX frame: CGRect, in screenFrame: CGRect) -> CGRect {
        let flippedY = screenFrame.maxY - frame.maxY
        return CGRect(x: frame.minX, y: flippedY, width: frame.width, height: frame.height)
    }

    private func applyFrame(_ frame: CGRect, to window: AXUIElement, screenFrame: CGRect) {
        let axFrame = WindowCoordinateConverter.axFrame(fromCocoa: frame, in: screenFrame)
        var position = axFrame.origin
        var size = axFrame.size

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

    private func cgRect(from value: Any?) -> CGRect? {
        guard let dict = value as? [String: Any] else { return nil }
        guard let x = cgFloat(dict["X"]),
              let y = cgFloat(dict["Y"]),
              let width = cgFloat(dict["Width"]),
              let height = cgFloat(dict["Height"]) else {
            return nil
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }

    private func cgFloat(_ value: Any?) -> CGFloat? {
        if let number = value as? NSNumber {
            return CGFloat(truncating: number)
        }
        if let value = value as? CGFloat {
            return value
        }
        if let value = value as? Double {
            return CGFloat(value)
        }
        if let value = value as? Int {
            return CGFloat(value)
        }
        return nil
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

import Cocoa

final class OverlayWindow: NSWindow {
    private let overlayView = OverlayView(frame: .zero)

    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        isReleasedWhenClosed = false
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        level = .statusBar
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .transient, .fullScreenAuxiliary]
        contentView = overlayView
    }

    func show(on screen: NSScreen, selection: Set<Slot>) {
        let frame = screen.visibleFrame
        let localFrame = CGRect(origin: .zero, size: frame.size)
        let slots = Slot.frames(in: localFrame)

        setFrame(frame, display: true)
        overlayView.slots = slots
        overlayView.selection = selection
        orderFrontRegardless()
    }

    func updateSelection(_ selection: Set<Slot>) {
        overlayView.selection = selection
    }
}

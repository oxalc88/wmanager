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

    func show(on screen: NSScreen, selection: Set<GridCell>, layout: LayoutPreset) {
        let frame = screen.visibleFrame
        let localFrame = CGRect(origin: .zero, size: frame.size)
        let frames = LayoutEngine.frames(in: localFrame, layout: layout)

        setFrame(frame, display: true)
        overlayView.cellFrames = frames
        overlayView.selection = selection
        orderFrontRegardless()
    }

    func updateSelection(_ selection: Set<GridCell>) {
        overlayView.selection = selection
    }
}

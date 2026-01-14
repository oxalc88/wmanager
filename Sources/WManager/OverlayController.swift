import Cocoa

final class OverlayController {
    private var overlayWindow = OverlayWindow()
    private var hideWorkItem: DispatchWorkItem?

    var isVisible: Bool {
        overlayWindow.isVisible
    }

    func show(on screen: NSScreen, selection: Set<GridCell>, layout: LayoutPreset) {
        overlayWindow.show(on: screen, selection: selection, layout: layout)
        scheduleHide()
    }

    func updateSelection(_ selection: Set<GridCell>) {
        overlayWindow.updateSelection(selection)
        scheduleHide()
    }

    func hide() {
        hideWorkItem?.cancel()
        overlayWindow.orderOut(nil)
    }

    private func scheduleHide() {
        guard let delay = Settings.overlayAutoHideSeconds, delay > 0 else { return }
        hideWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.hide()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}

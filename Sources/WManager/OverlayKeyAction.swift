import CoreGraphics

enum OverlayKeyAction: Equatable {
    case dismiss
    case slot(Slot)
    case passthrough

    static func action(for keyCode: CGKeyCode) -> OverlayKeyAction {
        if keyCode == KeyCode.escape || keyCode == KeyCode.returnKey {
            return .dismiss
        }

        if let slot = Slot.fromKeyCode(keyCode) {
            return .slot(slot)
        }

        return .passthrough
    }
}

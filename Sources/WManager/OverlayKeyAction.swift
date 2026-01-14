import CoreGraphics

enum OverlayKeyAction: Equatable {
    case dismiss
    case cell(GridCell)
    case passthrough

    static func action(for keyCode: CGKeyCode) -> OverlayKeyAction {
        if keyCode == KeyCode.escape || keyCode == KeyCode.returnKey {
            return .dismiss
        }

        if let cell = GridCell.cell(for: keyCode) {
            return .cell(cell)
        }

        return .passthrough
    }
}

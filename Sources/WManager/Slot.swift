import CoreGraphics

enum Slot: CaseIterable, Hashable {
    case topLeft
    case topCenter
    case topRight
    case bottomLeft
    case bottomCenter
    case bottomRight

    var keyCode: CGKeyCode {
        switch self {
        case .topLeft: return KeyCode.q
        case .topCenter: return KeyCode.w
        case .topRight: return KeyCode.e
        case .bottomLeft: return KeyCode.a
        case .bottomCenter: return KeyCode.s
        case .bottomRight: return KeyCode.d
        }
    }

    var label: String {
        switch self {
        case .topLeft: return "Q"
        case .topCenter: return "W"
        case .topRight: return "E"
        case .bottomLeft: return "A"
        case .bottomCenter: return "S"
        case .bottomRight: return "D"
        }
    }

    static func fromKeyCode(_ code: CGKeyCode) -> Slot? {
        return Slot.allCases.first { $0.keyCode == code }
    }

    static func frames(in frame: CGRect) -> [Slot: CGRect] {
        let content = frame.insetBy(dx: Settings.outerPadding, dy: Settings.outerPadding)
        let totalWidth = content.width - (Settings.innerGap * 2)
        let totalHeight = content.height - Settings.innerGap

        let leftWidth = totalWidth * 0.25
        let centerWidth = totalWidth * 0.5
        let rightWidth = totalWidth * 0.25
        let rowHeight = totalHeight * 0.5

        let x0 = content.minX
        let x1 = x0 + leftWidth + Settings.innerGap
        let x2 = x1 + centerWidth + Settings.innerGap
        let y0 = content.minY
        let y1 = y0 + rowHeight + Settings.innerGap

        return [
            .topLeft: CGRect(x: x0, y: y1, width: leftWidth, height: rowHeight),
            .topCenter: CGRect(x: x1, y: y1, width: centerWidth, height: rowHeight),
            .topRight: CGRect(x: x2, y: y1, width: rightWidth, height: rowHeight),
            .bottomLeft: CGRect(x: x0, y: y0, width: leftWidth, height: rowHeight),
            .bottomCenter: CGRect(x: x1, y: y0, width: centerWidth, height: rowHeight),
            .bottomRight: CGRect(x: x2, y: y0, width: rightWidth, height: rowHeight)
        ]
    }
}

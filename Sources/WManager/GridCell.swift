import CoreGraphics

struct GridCell: Hashable {
    let row: Int
    let column: Int
    let keyCode: CGKeyCode
    let label: String

    static let maxColumns = 4
    static let maxRows = 3

    static let all: [GridCell] = [
        GridCell(row: 0, column: 0, keyCode: KeyCode.q, label: "Q"),
        GridCell(row: 0, column: 1, keyCode: KeyCode.w, label: "W"),
        GridCell(row: 0, column: 2, keyCode: KeyCode.e, label: "E"),
        GridCell(row: 0, column: 3, keyCode: KeyCode.r, label: "R"),
        GridCell(row: 1, column: 0, keyCode: KeyCode.a, label: "A"),
        GridCell(row: 1, column: 1, keyCode: KeyCode.s, label: "S"),
        GridCell(row: 1, column: 2, keyCode: KeyCode.d, label: "D"),
        GridCell(row: 1, column: 3, keyCode: KeyCode.f, label: "F"),
        GridCell(row: 2, column: 0, keyCode: KeyCode.z, label: "Z"),
        GridCell(row: 2, column: 1, keyCode: KeyCode.x, label: "X"),
        GridCell(row: 2, column: 2, keyCode: KeyCode.c, label: "C"),
        GridCell(row: 2, column: 3, keyCode: KeyCode.v, label: "V")
    ]

    static func cell(for keyCode: CGKeyCode) -> GridCell? {
        return all.first { $0.keyCode == keyCode }
    }

    static func cell(row: Int, column: Int) -> GridCell? {
        return all.first { $0.row == row && $0.column == column }
    }
}

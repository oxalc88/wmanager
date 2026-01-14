import CoreGraphics

struct GridWeight: Equatable, Codable {
    private(set) var columns: [Int]
    private(set) var rows: [Int]

    static let minWeight = 0
    static let maxWeight = 5

    init(columns: [Int], rows: [Int]) {
        self.columns = GridWeight.clamp(weights: columns)
        self.rows = GridWeight.clamp(weights: rows)
    }

    static func `default`() -> GridWeight {
        return GridWeight(columns: [1, 1, 1], rows: [1, 1])
    }

    mutating func incrementColumn(at index: Int) {
        guard columns.indices.contains(index) else { return }
        columns[index] = min(columns[index] + 1, GridWeight.maxWeight)
    }

    mutating func setColumn(at index: Int, to value: Int) {
        guard columns.indices.contains(index) else { return }
        columns[index] = min(max(value, GridWeight.minWeight), GridWeight.maxWeight)
    }

    mutating func decrementColumn(at index: Int) {
        guard columns.indices.contains(index) else { return }
        columns[index] = max(columns[index] - 1, GridWeight.minWeight)
    }

    mutating func incrementRow(at index: Int) {
        guard rows.indices.contains(index) else { return }
        rows[index] = min(rows[index] + 1, GridWeight.maxWeight)
    }

    mutating func setRow(at index: Int, to value: Int) {
        guard rows.indices.contains(index) else { return }
        rows[index] = min(max(value, GridWeight.minWeight), GridWeight.maxWeight)
    }

    mutating func decrementRow(at index: Int) {
        guard rows.indices.contains(index) else { return }
        rows[index] = max(rows[index] - 1, GridWeight.minWeight)
    }

    var activeColumnCount: Int {
        columns.filter { $0 > 0 }.count
    }

    var activeRowCount: Int {
        rows.filter { $0 > 0 }.count
    }

    var columnProportions: [CGFloat] {
        proportions(for: columns)
    }

    var rowProportions: [CGFloat] {
        proportions(for: rows)
    }

    func asLayoutPreset(maxColumns: Int = GridCell.maxColumns, maxRows: Int = GridCell.maxRows) -> LayoutPreset {
        let normalizedColumns = normalizedWeights(columns, maxCount: maxColumns)
        let normalizedRows = normalizedWeights(rows, maxCount: maxRows)
        return LayoutPreset(columnWeights: normalizedColumns, rowWeights: normalizedRows)
    }

    func normalized(maxColumns: Int = GridCell.maxColumns, maxRows: Int = GridCell.maxRows) -> GridWeight {
        let normalizedColumns = normalizedWeights(columns, maxCount: maxColumns)
        let normalizedRows = normalizedWeights(rows, maxCount: maxRows)
        return GridWeight(columns: normalizedColumns, rows: normalizedRows)
    }

    private static func clamp(weights: [Int]) -> [Int] {
        return weights.map { min(max($0, GridWeight.minWeight), GridWeight.maxWeight) }
    }

    private func normalizedWeights(_ weights: [Int], maxCount: Int) -> [Int] {
        let clamped = weights.map { min(max($0, GridWeight.minWeight), GridWeight.maxWeight) }
        if clamped.count == maxCount {
            return clamped
        }
        if clamped.count > maxCount {
            return Array(clamped.prefix(maxCount))
        }
        return clamped + Array(repeating: GridWeight.minWeight, count: maxCount - clamped.count)
    }

    private func proportions(for weights: [Int]) -> [CGFloat] {
        let active = weights.filter { $0 > 0 }
        let total = CGFloat(active.reduce(0, +))
        guard total > 0 else { return [] }
        return active.map { CGFloat($0) / total }
    }
}

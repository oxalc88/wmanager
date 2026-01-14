import CoreGraphics

struct LayoutPreset: Codable, Equatable {
    var columnWeights: [Int]
    var rowWeights: [Int]

    init(columnWeights: [Int], rowWeights: [Int]) {
        self.columnWeights = LayoutPreset.normalize(columnWeights, maxCount: GridCell.maxColumns)
        self.rowWeights = LayoutPreset.normalize(rowWeights, maxCount: GridCell.maxRows)
    }

    static func defaultPreset() -> LayoutPreset {
        return LayoutPreset(columnWeights: [1, 1, 1, 0], rowWeights: [1, 1, 0])
    }

    static func normalize(_ weights: [Int], maxCount: Int) -> [Int] {
        let clamped = weights.map { min(max($0, GridWeight.minWeight), GridWeight.maxWeight) }
        if clamped.count == maxCount {
            return clamped
        }
        if clamped.count > maxCount {
            return Array(clamped.prefix(maxCount))
        }
        return clamped + Array(repeating: 0, count: maxCount - clamped.count)
    }
}

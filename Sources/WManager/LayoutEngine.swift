import CoreGraphics

enum LayoutEngine {
    static func frames(in frame: CGRect, layout: LayoutPreset) -> [GridCell: CGRect] {
        let columns = layout.columnWeights
        let rows = layout.rowWeights

        let activeColumns = columns.enumerated().filter { $0.element > 0 }
        let activeRows = rows.enumerated().filter { $0.element > 0 }
        guard !activeColumns.isEmpty, !activeRows.isEmpty else {
            return [:]
        }

        let content = frame.insetBy(dx: Settings.outerPadding, dy: Settings.outerPadding)
        let totalGapX = Settings.innerGap * CGFloat(activeColumns.count - 1)
        let totalGapY = Settings.innerGap * CGFloat(activeRows.count - 1)
        let usableWidth = max(0, content.width - totalGapX)
        let usableHeight = max(0, content.height - totalGapY)

        let totalColumnWeight = CGFloat(activeColumns.reduce(0) { $0 + $1.element })
        let totalRowWeight = CGFloat(activeRows.reduce(0) { $0 + $1.element })
        guard totalColumnWeight > 0, totalRowWeight > 0 else {
            return [:]
        }

        var columnFrames: [Int: (x: CGFloat, width: CGFloat)] = [:]
        var currentX = content.minX
        for (index, element) in activeColumns.enumerated() {
            let width = usableWidth * (CGFloat(element.element) / totalColumnWeight)
            columnFrames[element.offset] = (currentX, width)
            currentX += width
            if index < activeColumns.count - 1 {
                currentX += Settings.innerGap
            }
        }

        var rowFrames: [Int: (y: CGFloat, height: CGFloat)] = [:]
        var currentY = content.maxY
        for (index, element) in activeRows.enumerated() {
            let height = usableHeight * (CGFloat(element.element) / totalRowWeight)
            let y = currentY - height
            rowFrames[element.offset] = (y, height)
            currentY = y
            if index < activeRows.count - 1 {
                currentY -= Settings.innerGap
            }
        }

        var frames: [GridCell: CGRect] = [:]
        for cell in GridCell.all {
            guard let col = columnFrames[cell.column],
                  let row = rowFrames[cell.row] else { continue }
            frames[cell] = CGRect(x: col.x, y: row.y, width: col.width, height: row.height)
        }

        return frames
    }

    static func activeCells(for layout: LayoutPreset) -> Set<GridCell> {
        let activeColumns = Set(layout.columnWeights.enumerated().filter { $0.element > 0 }.map { $0.offset })
        let activeRows = Set(layout.rowWeights.enumerated().filter { $0.element > 0 }.map { $0.offset })
        let cells = GridCell.all.filter { activeColumns.contains($0.column) && activeRows.contains($0.row) }
        return Set(cells)
    }
}

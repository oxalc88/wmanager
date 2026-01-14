import SwiftUI

struct GridEditorView: View {
    @Binding var weights: GridWeight
    @Binding var isEditing: Bool

    private let controlSpacing: CGFloat = 10
    private let gridGap: CGFloat = 8
    private let gridSize = CGSize(width: 320, height: 220)
    private let rowControlSize = CGSize(width: 36, height: 86)
    private let columnControlHeight: CGFloat = 28

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: controlSpacing) {
                rowControls
                VStack(spacing: controlSpacing) {
                    columnControls
                    gridPreview
                }
            }
        }
    }

    private var columnControls: some View {
        let controlWidth = (gridSize.width - (controlSpacing * CGFloat(GridCell.maxColumns - 1))) / CGFloat(GridCell.maxColumns)
        return HStack(spacing: controlSpacing) {
            ForEach(0..<GridCell.maxColumns, id: \.self) { index in
                WeightControlView(
                    axis: .column,
                    index: index,
                    isEditing: $isEditing,
                    value: bindingForColumn(index)
                )
                .frame(width: controlWidth, height: columnControlHeight)
            }
        }
    }

    private var rowControls: some View {
        VStack(spacing: controlSpacing) {
            ForEach(0..<GridCell.maxRows, id: \.self) { index in
                WeightControlView(
                    axis: .row,
                    index: index,
                    isEditing: $isEditing,
                    value: bindingForRow(index)
                )
                .frame(width: rowControlSize.width, height: rowControlSize.height)
            }
        }
    }

    private var gridPreview: some View {
        GeometryReader { proxy in
            let layout = weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows)
            let columns = layout.columns
            let rows = layout.rows
            let activeColumns = columns.enumerated().filter { $0.element > 0 }
            let activeRows = rows.enumerated().filter { $0.element > 0 }
            let totalColumnWeight = CGFloat(activeColumns.reduce(0) { $0 + $1.element })
            let totalRowWeight = CGFloat(activeRows.reduce(0) { $0 + $1.element })
            let totalGapX = gridGap * CGFloat(max(activeColumns.count - 1, 0))
            let totalGapY = gridGap * CGFloat(max(activeRows.count - 1, 0))
            let usableWidth = max(0, proxy.size.width - totalGapX)
            let usableHeight = max(0, proxy.size.height - totalGapY)

            let columnFrames = weightedFrames(
                items: activeColumns.map { (index: $0.offset, weight: $0.element) },
                totalWeight: totalColumnWeight,
                length: usableWidth,
                gap: gridGap
            )
            let rowFrames = weightedFrames(
                items: activeRows.map { (index: $0.offset, weight: $0.element) },
                totalWeight: totalRowWeight,
                length: usableHeight,
                gap: gridGap
            )

            ZStack(alignment: .topLeading) {
                if activeColumns.isEmpty || activeRows.isEmpty {
                    Text("Set a row and column to at least 1")
                        .foregroundColor(SettingsPalette.textSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ForEach(GridCell.all, id: \.self) { cell in
                        if let column = columnFrames[cell.column],
                           let row = rowFrames[cell.row] {
                            GridCellPreview(
                                label: cell.label,
                                size: CGSize(width: column.length, height: row.length)
                            )
                            .position(x: column.origin + column.length / 2, y: row.origin + row.length / 2)
                        }
                    }
                }
            }
        }
        .padding(8)
        .frame(width: gridSize.width, height: gridSize.height)
        .background(SettingsPalette.gridBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(SettingsPalette.gridBorder, lineWidth: 1)
        )
        .cornerRadius(16)
    }

    private func bindingForColumn(_ index: Int) -> Binding<Int> {
        Binding(
            get: {
                weights.columns.indices.contains(index) ? weights.columns[index] : GridWeight.minWeight
            },
            set: { newValue in
                var updated = weights
                updated.setColumn(at: index, to: newValue)
                weights = updated
            }
        )
    }

    private func bindingForRow(_ index: Int) -> Binding<Int> {
        Binding(
            get: {
                weights.rows.indices.contains(index) ? weights.rows[index] : GridWeight.minWeight
            },
            set: { newValue in
                var updated = weights
                updated.setRow(at: index, to: newValue)
                weights = updated
            }
        )
    }

    private func weightedFrames(
        items: [(index: Int, weight: Int)],
        totalWeight: CGFloat,
        length: CGFloat,
        gap: CGFloat
    ) -> [Int: (origin: CGFloat, length: CGFloat)] {
        guard totalWeight > 0 else { return [:] }
        var frames: [Int: (origin: CGFloat, length: CGFloat)] = [:]
        var current: CGFloat = 0
        for (offset, item) in items.enumerated() {
            let fraction = CGFloat(item.weight) / totalWeight
            let size = length * fraction
            frames[item.index] = (origin: current, length: size)
            current += size
            if offset < items.count - 1 {
                current += gap
            }
        }
        return frames
    }
}

private struct GridCellPreview: View {
    let label: String
    let size: CGSize

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(SettingsPalette.cellBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(SettingsPalette.cellBorder, lineWidth: 1)
                )
            Text(label)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(SettingsPalette.cellText)
        }
        .frame(width: size.width, height: size.height)
    }
}

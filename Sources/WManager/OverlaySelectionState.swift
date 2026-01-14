import Foundation

struct OverlaySelectionState {
    private(set) var selection: Set<GridCell> = []

    mutating func select(_ cell: GridCell) -> Set<GridCell> {
        selection.insert(cell)
        return selection
    }

    mutating func select(_ cell: GridCell, maxSelectionCount: Int?) -> (selection: Set<GridCell>, reachedLimit: Bool) {
        selection.insert(cell)
        let reachedLimit: Bool
        if let maxSelectionCount, maxSelectionCount > 0 {
            reachedLimit = selection.count >= maxSelectionCount
        } else {
            reachedLimit = false
        }
        return (selection, reachedLimit)
    }

    mutating func clear() {
        selection.removeAll()
    }
}

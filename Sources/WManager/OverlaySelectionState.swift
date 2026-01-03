import Foundation

struct OverlaySelectionState {
    private(set) var selection: Set<Slot> = []

    mutating func select(_ slot: Slot) -> Set<Slot> {
        selection.insert(slot)
        return selection
    }

    mutating func select(_ slot: Slot, maxSelectionCount: Int?) -> (selection: Set<Slot>, reachedLimit: Bool) {
        selection.insert(slot)
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

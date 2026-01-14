import Cocoa
import Foundation

enum LayoutScope: String, Codable, CaseIterable {
    case allDesktops
    case thisDesktop

    var title: String {
        switch self {
        case .allDesktops:
            return "All Desktops"
        case .thisDesktop:
            return "This Desktop"
        }
    }
}

struct LayoutConfig: Codable, Equatable {
    var weights: GridWeight
    var scope: LayoutScope

    static func `default`(scope: LayoutScope) -> LayoutConfig {
        let normalized = GridWeight.default().normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows)
        return LayoutConfig(weights: normalized, scope: scope)
    }
}

struct LayoutStoreState: Codable, Equatable {
    var globalLayouts: [LayoutConfig]
    var desktopLayouts: [String: [LayoutConfig]]
    var globalActiveIndex: Int
    var desktopActiveIndex: [String: Int]
}

enum LayoutStore {
    private static let storageKey = "layout.store"

    static func load(userDefaults: UserDefaults = .standard) -> LayoutStoreState {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(LayoutStoreState.self, from: data) {
            return normalizeState(decoded)
        }
        return defaultState()
    }

    static func save(_ state: LayoutStoreState, userDefaults: UserDefaults = .standard) {
        let normalized = normalizeState(state)
        guard let data = try? JSONEncoder().encode(normalized) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    static func defaultState() -> LayoutStoreState {
        let layouts = Array(repeating: LayoutConfig.default(scope: .allDesktops), count: Settings.layoutPresetCount)
        return LayoutStoreState(
            globalLayouts: layouts,
            desktopLayouts: [:],
            globalActiveIndex: 0,
            desktopActiveIndex: [:]
        )
    }

    static func activeLayoutIndex(_ state: LayoutStoreState, scope: LayoutScope, spaceID: CGSSpaceID?) -> Int {
        switch scope {
        case .allDesktops:
            return clampIndex(state.globalActiveIndex)
        case .thisDesktop:
            if let key = spaceKey(spaceID),
               let index = state.desktopActiveIndex[key] {
                return clampIndex(index)
            }
            return clampIndex(state.globalActiveIndex)
        }
    }

    static func setActiveLayoutIndex(
        _ index: Int,
        scope: LayoutScope,
        spaceID: CGSSpaceID?,
        in state: inout LayoutStoreState
    ) {
        let clampedIndex = clampIndex(index)
        switch scope {
        case .allDesktops:
            state.globalActiveIndex = clampedIndex
        case .thisDesktop:
            guard let key = spaceKey(spaceID) else { return }
            state.desktopActiveIndex[key] = clampedIndex
        }
    }

    static func layoutConfig(
        _ state: LayoutStoreState,
        index: Int,
        scope: LayoutScope,
        spaceID: CGSSpaceID?
    ) -> LayoutConfig {
        let clampedIndex = clampIndex(index)
        switch scope {
        case .allDesktops:
            let layouts = normalizedLayouts(state.globalLayouts, scope: .allDesktops)
            return layouts[clampedIndex]
        case .thisDesktop:
            guard let key = spaceKey(spaceID),
                  let layouts = state.desktopLayouts[key] else {
                var fallback = normalizedLayouts(state.globalLayouts, scope: .allDesktops)[clampedIndex]
                fallback.scope = .thisDesktop
                return fallback
            }
            let normalized = normalizedLayouts(layouts, scope: .thisDesktop)
            return normalized[clampedIndex]
        }
    }

    static func updateLayoutConfig(
        _ config: LayoutConfig,
        index: Int,
        scope: LayoutScope,
        spaceID: CGSSpaceID?,
        in state: inout LayoutStoreState
    ) {
        let clampedIndex = clampIndex(index)
        let normalizedConfig = LayoutConfig(
            weights: config.weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows),
            scope: scope
        )
        switch scope {
        case .allDesktops:
            var layouts = normalizedLayouts(state.globalLayouts, scope: .allDesktops)
            layouts[clampedIndex] = normalizedConfig
            state.globalLayouts = layouts
        case .thisDesktop:
            guard let key = spaceKey(spaceID) else { return }
            var layouts = normalizedLayouts(state.desktopLayouts[key] ?? [], scope: .thisDesktop)
            layouts[clampedIndex] = normalizedConfig
            state.desktopLayouts[key] = layouts
        }
    }

    static func currentLayoutPreset(for screen: NSScreen?) -> LayoutPreset {
        let state = load()
        let spaceID = DesktopManager.currentSpaceID(for: screen)
        let key = spaceKey(spaceID)
        let scope: LayoutScope
        if let key, state.desktopLayouts[key] != nil {
            scope = .thisDesktop
        } else {
            scope = .allDesktops
        }
        let index = activeLayoutIndex(state, scope: scope, spaceID: spaceID)
        let config = layoutConfig(state, index: index, scope: scope, spaceID: spaceID)
        return config.weights.asLayoutPreset()
    }

    static func setActiveLayoutIndex(_ index: Int, for screen: NSScreen?) {
        let spaceID = DesktopManager.currentSpaceID(for: screen)
        var state = load()
        let key = spaceKey(spaceID)
        let scope: LayoutScope
        if let key, state.desktopLayouts[key] != nil {
            scope = .thisDesktop
        } else {
            scope = .allDesktops
        }
        setActiveLayoutIndex(index, scope: scope, spaceID: spaceID, in: &state)
        save(state)
    }

    private static func clampIndex(_ index: Int) -> Int {
        let maxIndex = max(Settings.layoutPresetCount - 1, 0)
        return min(max(index, 0), maxIndex)
    }

    private static func normalizedLayouts(_ layouts: [LayoutConfig], scope: LayoutScope) -> [LayoutConfig] {
        var normalized = layouts.map { LayoutConfig(weights: $0.weights.normalized(), scope: scope) }
        if normalized.count > Settings.layoutPresetCount {
            normalized = Array(normalized.prefix(Settings.layoutPresetCount))
        }
        while normalized.count < Settings.layoutPresetCount {
            normalized.append(LayoutConfig.default(scope: scope))
        }
        return normalized
    }

    private static func normalizeState(_ state: LayoutStoreState) -> LayoutStoreState {
        var normalized = state
        normalized.globalLayouts = normalizedLayouts(state.globalLayouts, scope: .allDesktops)
        normalized.globalActiveIndex = clampIndex(state.globalActiveIndex)
        normalized.desktopLayouts = state.desktopLayouts.mapValues { normalizedLayouts($0, scope: .thisDesktop) }
        normalized.desktopActiveIndex = state.desktopActiveIndex.mapValues { clampIndex($0) }
        return normalized
    }

    private static func spaceKey(_ spaceID: CGSSpaceID?) -> String? {
        guard let spaceID else { return nil }
        return String(spaceID)
    }
}

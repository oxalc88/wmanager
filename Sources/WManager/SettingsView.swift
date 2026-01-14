import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeState: LayoutStoreState
    @State private var selectedLayoutIndex: Int
    @State private var scope: LayoutScope
    @State private var draftWeights: GridWeight
    @State private var isEditing: Bool

    init() {
        let state = LayoutStore.load()
        let spaceID = DesktopManager.currentSpaceID(for: nil)
        let spaceKey = spaceID.map { String($0) }
        let initialScope: LayoutScope
        if let spaceKey, state.desktopLayouts[spaceKey] != nil {
            initialScope = .thisDesktop
        } else {
            initialScope = .allDesktops
        }
        let selectedIndex = LayoutStore.activeLayoutIndex(state, scope: initialScope, spaceID: spaceID)
        let config = LayoutStore.layoutConfig(state, index: selectedIndex, scope: initialScope, spaceID: spaceID)

        _storeState = State(initialValue: state)
        _scope = State(initialValue: initialScope)
        _selectedLayoutIndex = State(initialValue: selectedIndex)
        _draftWeights = State(initialValue: config.weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows))
        _isEditing = State(initialValue: false)
    }

    var body: some View {
        ZStack {
            SettingsPalette.canvas
                .ignoresSafeArea()

            HStack(spacing: 0) {
                sidebar
                Divider()
                    .background(SettingsPalette.divider)
                content
            }
            .background(SettingsPalette.windowBackground)
        }
        .onChange(of: selectedLayoutIndex) { _ in
            isEditing = false
            syncDraftFromStore()
            persistActiveLayoutSelection()
        }
        .onChange(of: scope) { _ in
            isEditing = false
            let newIndex = LayoutStore.activeLayoutIndex(storeState, scope: scope, spaceID: currentSpaceID())
            if newIndex != selectedLayoutIndex {
                selectedLayoutIndex = newIndex
            }
            syncDraftFromStore()
        }
        .onExitCommand {
            cancelAndClose()
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(red: 1.0, green: 0.37, blue: 0.35))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Color(red: 1.0, green: 0.74, blue: 0.18))
                    .frame(width: 10, height: 10)
                Circle()
                    .fill(Color(red: 0.16, green: 0.78, blue: 0.29))
                    .frame(width: 10, height: 10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            VStack(alignment: .leading, spacing: 6) {
                SidebarItem(title: "Grid", systemImage: "square.grid.2x2", isSelected: true)
            }
            .padding(.horizontal, 10)

            Spacer()

            HStack(spacing: 8) {
                Circle()
                    .fill(Color(red: 0.26, green: 0.86, blue: 0.43))
                    .frame(width: 8, height: 8)
                Text("Tactile Engine Active")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SettingsPalette.textSecondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SettingsPalette.sidebarFooter)
        }
        .frame(width: 220)
        .padding(.vertical, 12)
        .background(SettingsPalette.sidebarBackground)
    }

    private var content: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Configuration")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(SettingsPalette.textSecondary)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "circle.lefthalf.filled")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(SettingsPalette.textSecondary)
                        .frame(width: 24, height: 24)
                        .background(SettingsPalette.segmentBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(SettingsPalette.headerBackground)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(SettingsPalette.divider),
                alignment: .bottom
            )

            ScrollView {
                HStack(alignment: .top, spacing: 44) {
                    gridSection
                    controlPanel
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 28)
            }
        }
    }

    private var gridSection: some View {
        VStack(spacing: 16) {
            Text("Column/row weights")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(SettingsPalette.textPrimary)

            GridEditorView(weights: $draftWeights, isEditing: $isEditing)
                .disabled(!isEditing)
                .opacity(isEditing ? 1 : 0.7)
                .padding(18)
                .background(SettingsPalette.panelBackground)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(SettingsPalette.panelBorder, lineWidth: 1)
                )

            Text("Tip: Set weight to 0 to remove any column/row from this layout")
                .font(.system(size: 11))
                .foregroundColor(SettingsPalette.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity)
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Layout Preset")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SettingsPalette.textSecondary)

                SegmentedPicker(
                    items: Array(0..<Settings.layoutPresetCount),
                    selection: $selectedLayoutIndex,
                    label: { "Layout \($0 + 1)" },
                    identifier: { "layout-tab-\($0)" }
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Scope")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SettingsPalette.textSecondary)

                SegmentedPicker(
                    items: LayoutScope.allCases,
                    selection: $scope,
                    label: { $0.title },
                    identifier: { "scope-\($0.rawValue)" }
                )
            }

            if isEditing {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(SettingsPalette.accent)
                    Text("Editing layout")
                        .font(.system(size: 11))
                        .foregroundColor(SettingsPalette.textSecondary)
                }
            }

            Spacer()

            Divider()

            VStack(spacing: 12) {
                Button(action: applyChanges) {
                    Text("Apply Changes")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isEditing ? SettingsPalette.accent : SettingsPalette.segmentBackground)
                        .foregroundColor(isEditing ? .white : SettingsPalette.textDisabled)
                        .cornerRadius(8)
                }
                .disabled(!isEditing)
                .opacity(isEditing ? 1 : 0.6)
                .accessibilityIdentifier("apply-button")

                Button(action: {
                    if isEditing {
                        cancelChanges()
                    } else {
                        isEditing = true
                    }
                }) {
                    Text(isEditing ? "Cancel" : "Edit Layout")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isEditing ? SettingsPalette.destructive : SettingsPalette.accent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .accessibilityIdentifier("change-cancel-button")
            }
        }
        .frame(width: 240)
        .padding(.top, 8)
    }

    private func syncDraftFromStore() {
        let config = LayoutStore.layoutConfig(
            storeState,
            index: selectedLayoutIndex,
            scope: scope,
            spaceID: currentSpaceID()
        )
        draftWeights = config.weights.normalized(maxColumns: GridCell.maxColumns, maxRows: GridCell.maxRows)
    }

    private func persistActiveLayoutSelection() {
        var updated = storeState
        LayoutStore.setActiveLayoutIndex(
            selectedLayoutIndex,
            scope: scope,
            spaceID: currentSpaceID(),
            in: &updated
        )
        storeState = updated
        LayoutStore.save(updated)
    }

    private func applyChanges() {
        var updated = storeState
        let config = LayoutConfig(weights: draftWeights, scope: scope)
        LayoutStore.updateLayoutConfig(
            config,
            index: selectedLayoutIndex,
            scope: scope,
            spaceID: currentSpaceID(),
            in: &updated
        )
        LayoutStore.setActiveLayoutIndex(
            selectedLayoutIndex,
            scope: scope,
            spaceID: currentSpaceID(),
            in: &updated
        )
        storeState = updated
        LayoutStore.save(updated)
        isEditing = false
    }

    private func cancelChanges() {
        syncDraftFromStore()
        isEditing = false
    }

    private func cancelAndClose() {
        cancelChanges()
        if let window = NSApp.keyWindow {
            window.close()
        } else {
            dismiss()
        }
    }

    private func currentSpaceID() -> CGSSpaceID? {
        DesktopManager.currentSpaceID(for: nil)
    }
}

private struct SidebarItem: View {
    let title: String
    let systemImage: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 16)
            Text(title)
                .font(.system(size: 13, weight: .medium))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .foregroundColor(isSelected ? .white : SettingsPalette.textSecondary)
        .background(isSelected ? SettingsPalette.accent : Color.clear)
        .cornerRadius(8)
    }
}

private struct SegmentedPicker<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let label: (Item) -> String
    let identifier: (Item) -> String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.self) { item in
                let isSelected = selection == item
                Button(action: {
                    selection = item
                }) {
                    Text(label(item))
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundColor(isSelected ? SettingsPalette.segmentTextSelected : SettingsPalette.segmentText)
                        .background(isSelected ? SettingsPalette.segmentSelected : Color.clear)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(identifier(item))
            }
        }
        .padding(2)
        .background(SettingsPalette.segmentBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SettingsPalette.segmentBorder, lineWidth: 1)
        )
    }
}

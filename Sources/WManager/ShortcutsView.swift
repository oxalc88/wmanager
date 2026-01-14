import SwiftUI

struct ShortcutsView: View {
    @Binding var shortcuts: [ShortcutAction: ShortcutDefinition]
    @Binding var isEditing: Bool
    @Binding var recordingAction: ShortcutAction?
    let validation: ShortcutsValidationResult
    let onApply: () -> Void
    let onCancel: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 44) {
            shortcutsList
            shortcutsControlPanel
        }
    }

    private var shortcutsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ShortcutSection(title: "Window Actions") {
                ShortcutRow(
                    title: ShortcutAction.toggleOverlay.title,
                    shortcut: binding(for: .toggleOverlay),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .toggleOverlay),
                    highlight: rowHighlight(for: .toggleOverlay)
                )
                ShortcutRow(
                    title: ShortcutAction.tileLeft.title,
                    shortcut: binding(for: .tileLeft),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .tileLeft),
                    highlight: rowHighlight(for: .tileLeft)
                )
                ShortcutRow(
                    title: ShortcutAction.tileRight.title,
                    shortcut: binding(for: .tileRight),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .tileRight),
                    highlight: rowHighlight(for: .tileRight)
                )
                ShortcutRow(
                    title: ShortcutAction.maximize.title,
                    shortcut: binding(for: .maximize),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .maximize),
                    highlight: rowHighlight(for: .maximize)
                )
            }

            ShortcutSection(title: "Layout Presets") {
                ShortcutRow(
                    title: ShortcutAction.layout1.title,
                    shortcut: binding(for: .layout1),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .layout1),
                    highlight: rowHighlight(for: .layout1)
                )
                ShortcutRow(
                    title: ShortcutAction.layout2.title,
                    shortcut: binding(for: .layout2),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .layout2),
                    highlight: rowHighlight(for: .layout2)
                )
                ShortcutRow(
                    title: ShortcutAction.layout3.title,
                    shortcut: binding(for: .layout3),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .layout3),
                    highlight: rowHighlight(for: .layout3)
                )
                ShortcutRow(
                    title: ShortcutAction.layout4.title,
                    shortcut: binding(for: .layout4),
                    isEditing: $isEditing,
                    isRecording: recordingBinding(for: .layout4),
                    highlight: rowHighlight(for: .layout4)
                )
            }

            ShortcutSection(title: "Overlay Grid (Fixed)") {
                ShortcutReadOnlyRow(
                    title: "Grid Cells",
                    value: "Q W E R / A S D F / Z X C V"
                )
                ShortcutReadOnlyRow(
                    title: "Dismiss",
                    value: "Esc or Return"
                )
            }

            if let message = validation.message {
                Text(message)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SettingsPalette.destructive)
            }
        }
        .padding(18)
        .background(SettingsPalette.panelBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(SettingsPalette.panelBorder, lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var shortcutsControlPanel: some View {
        VStack(alignment: .leading, spacing: 24) {
            if isEditing {
                HStack(spacing: 6) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(SettingsPalette.accent)
                    Text("Editing shortcuts")
                        .font(.system(size: 11))
                        .foregroundColor(SettingsPalette.textSecondary)
                }
            }

            Spacer()

            Divider()

            VStack(spacing: 12) {
                Button(action: onApply) {
                    Text("Apply Changes")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isEditing && validation.isValid ? SettingsPalette.accent : SettingsPalette.segmentBackground)
                        .foregroundColor(isEditing && validation.isValid ? .white : SettingsPalette.textDisabled)
                        .cornerRadius(8)
                }
                .disabled(!isEditing || !validation.isValid)

                Button(action: {
                    if isEditing {
                        onCancel()
                    } else {
                        isEditing = true
                    }
                }) {
                    Text(isEditing ? "Cancel" : "Edit Shortcuts")
                        .font(.system(size: 13, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isEditing ? SettingsPalette.destructive : SettingsPalette.accent)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .frame(width: 240)
        .padding(.top, 8)
    }

    private func binding(for action: ShortcutAction) -> Binding<ShortcutDefinition> {
        Binding(
            get: {
                shortcuts[action] ?? ShortcutsStore.defaultShortcut(for: action)
            },
            set: { newValue in
                shortcuts[action] = newValue
            }
        )
    }

    private func recordingBinding(for action: ShortcutAction) -> Binding<Bool> {
        Binding(
            get: { recordingAction == action },
            set: { isRecording in
                recordingAction = isRecording ? action : nil
            }
        )
    }

    private func rowHighlight(for action: ShortcutAction) -> Color {
        if validation.conflicts.contains(action) || validation.invalidKeys.contains(action) || validation.missingModifiers.contains(action) {
            return SettingsPalette.destructive
        }
        return SettingsPalette.controlBorder
    }
}

private struct ShortcutSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SettingsPalette.textSecondary)

            VStack(spacing: 8) {
                content
            }
        }
    }
}

private struct ShortcutRow: View {
    let title: String
    @Binding var shortcut: ShortcutDefinition
    @Binding var isEditing: Bool
    @Binding var isRecording: Bool
    let highlight: Color

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(SettingsPalette.textPrimary)
            Spacer()
            ShortcutRecorderView(
                shortcut: $shortcut,
                isRecording: $isRecording,
                isEnabled: isEditing,
                borderColor: highlight
            )
            .frame(width: 160)
        }
        .padding(.vertical, 2)
    }
}

private struct ShortcutReadOnlyRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(SettingsPalette.textPrimary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SettingsPalette.textSecondary)
        }
        .padding(.vertical, 2)
    }
}

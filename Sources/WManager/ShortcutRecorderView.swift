import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: ShortcutDefinition
    @Binding var isRecording: Bool
    let isEnabled: Bool
    let borderColor: Color

    var body: some View {
        Button(action: {
            guard isEnabled else { return }
            isRecording = true
        }) {
            Text(isRecording ? "Press keys..." : shortcut.displayString)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isEnabled ? SettingsPalette.textPrimary : SettingsPalette.textDisabled)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .padding(.horizontal, 10)
                .background(isRecording ? SettingsPalette.accent.opacity(0.12) : SettingsPalette.controlBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isRecording ? 1.5 : 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .background(
            KeyCaptureView(isRecording: $isRecording) { event in
                handleKeyDown(event)
            }
            .frame(width: 0, height: 0)
        )
    }

    private func handleKeyDown(_ event: NSEvent) {
        let keyCode = CGKeyCode(event.keyCode)
        if keyCode == KeyCode.escape {
            isRecording = false
            return
        }
        if KeyCode.isModifierKey(keyCode) {
            return
        }
        let modifiers = ShortcutModifiers.from(event.modifierFlags)
        shortcut = ShortcutDefinition(keyCode: Int(keyCode), modifiers: modifiers)
        isRecording = false
    }
}

struct KeyCaptureView: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onKeyDown: (NSEvent) -> Void

    func makeNSView(context: Context) -> KeyCaptureNSView {
        let view = KeyCaptureNSView()
        view.onKeyDown = onKeyDown
        return view
    }

    func updateNSView(_ nsView: KeyCaptureNSView, context: Context) {
        nsView.onKeyDown = onKeyDown
        if isRecording, let window = nsView.window {
            window.makeFirstResponder(nsView)
        }
    }
}

final class KeyCaptureNSView: NSView {
    var onKeyDown: ((NSEvent) -> Void)?

    override var acceptsFirstResponder: Bool {
        return true
    }

    override func keyDown(with event: NSEvent) {
        onKeyDown?(event)
    }
}

import SwiftUI

struct WeightControlView: View {
    enum Axis {
        case column
        case row
    }

    let axis: Axis
    let index: Int
    @Binding var isEditing: Bool
    @Binding var value: Int

    private var valueText: Binding<String> {
        Binding(
            get: { String(value) },
            set: { newValue in
                guard let parsed = Int(newValue.filter { $0.isNumber }) else { return }
                value = min(max(parsed, GridWeight.minWeight), GridWeight.maxWeight)
            }
        )
    }

    private var decreaseIdentifier: String {
        identifierSuffix("minus")
    }

    private var increaseIdentifier: String {
        identifierSuffix("plus")
    }

    private var valueIdentifier: String {
        identifierSuffix("value")
    }

    var body: some View {
        let canDecrease = value > GridWeight.minWeight
        let canIncrease = value < GridWeight.maxWeight

        Group {
            switch axis {
            case .column:
                columnControl(canDecrease: canDecrease, canIncrease: canIncrease)
            case .row:
                rowControl(canDecrease: canDecrease, canIncrease: canIncrease)
            }
        }
    }

    private func identifierSuffix(_ kind: String) -> String {
        switch axis {
        case .column:
            return "column-weight-\(kind)-\(index)"
        case .row:
            return "row-weight-\(kind)-\(index)"
        }
    }

    private func columnControl(canDecrease: Bool, canIncrease: Bool) -> some View {
        let arrowHeight: CGFloat = 13
        return HStack(spacing: 0) {
            TextField("", text: valueText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SettingsPalette.textPrimary)
                .accessibilityIdentifier(valueIdentifier)

            Divider()
                .background(SettingsPalette.stepperBorder)

            VStack(spacing: 0) {
                stepperButton(
                    symbol: "chevron.up",
                    enabled: canIncrease,
                    identifier: increaseIdentifier,
                    action: { value = min(value + 1, GridWeight.maxWeight) }
                )
                .frame(height: arrowHeight)

                Divider()
                    .background(SettingsPalette.stepperBorder)

                stepperButton(
                    symbol: "chevron.down",
                    enabled: canDecrease,
                    identifier: decreaseIdentifier,
                    action: { value = max(value - 1, GridWeight.minWeight) }
                )
                .frame(height: arrowHeight)
            }
            .frame(width: 18)
        }
        .frame(height: 28)
        .background(SettingsPalette.stepperBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(SettingsPalette.stepperBorder, lineWidth: 1)
        )
        .cornerRadius(6)
        .opacity(isEditing ? 1 : 0.7)
    }

    private func rowControl(canDecrease: Bool, canIncrease: Bool) -> some View {
        let arrowHeight: CGFloat = 18
        return VStack(spacing: 0) {
            stepperButton(
                symbol: "chevron.up",
                enabled: canIncrease,
                identifier: increaseIdentifier,
                action: { value = min(value + 1, GridWeight.maxWeight) }
            )
            .frame(height: arrowHeight)

            Divider()
                .background(SettingsPalette.stepperBorder)

            TextField("", text: valueText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(SettingsPalette.textPrimary)
                .accessibilityIdentifier(valueIdentifier)

            Divider()
                .background(SettingsPalette.stepperBorder)

            stepperButton(
                symbol: "chevron.down",
                enabled: canDecrease,
                identifier: decreaseIdentifier,
                action: { value = max(value - 1, GridWeight.minWeight) }
            )
            .frame(height: arrowHeight)
        }
        .frame(width: 34)
        .background(SettingsPalette.stepperBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(SettingsPalette.stepperBorder, lineWidth: 1)
        )
        .cornerRadius(6)
        .foregroundColor(SettingsPalette.textSecondary)
        .opacity(isEditing ? 1 : 0.7)
    }

    private func stepperButton(
        symbol: String,
        enabled: Bool,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(SettingsPalette.stepperButtonBackground)
                Image(systemName: symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(SettingsPalette.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .disabled(!enabled)
        .accessibilityIdentifier(identifier)
    }
}

import Cocoa

enum ShortcutAction: String, CaseIterable, Codable, Hashable {
    case toggleOverlay
    case tileLeft
    case tileRight
    case maximize
    case layout1
    case layout2
    case layout3
    case layout4

    var title: String {
        switch self {
        case .toggleOverlay:
            return "Toggle Overlay"
        case .tileLeft:
            return "Tile Left"
        case .tileRight:
            return "Tile Right"
        case .maximize:
            return "Maximize"
        case .layout1:
            return "Layout 1"
        case .layout2:
            return "Layout 2"
        case .layout3:
            return "Layout 3"
        case .layout4:
            return "Layout 4"
        }
    }

    var layoutIndex: Int? {
        switch self {
        case .layout1:
            return 0
        case .layout2:
            return 1
        case .layout3:
            return 2
        case .layout4:
            return 3
        default:
            return nil
        }
    }
}

struct ShortcutModifiers: OptionSet, Codable, Hashable {
    let rawValue: Int

    static let command = ShortcutModifiers(rawValue: 1 << 0)
    static let option = ShortcutModifiers(rawValue: 1 << 1)
    static let control = ShortcutModifiers(rawValue: 1 << 2)
    static let shift = ShortcutModifiers(rawValue: 1 << 3)

    static func from(_ flags: CGEventFlags) -> ShortcutModifiers {
        var result: ShortcutModifiers = []
        if flags.contains(.maskCommand) {
            result.insert(.command)
        }
        if flags.contains(.maskAlternate) {
            result.insert(.option)
        }
        if flags.contains(.maskControl) {
            result.insert(.control)
        }
        if flags.contains(.maskShift) {
            result.insert(.shift)
        }
        return result
    }

    static func from(_ flags: NSEvent.ModifierFlags) -> ShortcutModifiers {
        var result: ShortcutModifiers = []
        if flags.contains(.command) {
            result.insert(.command)
        }
        if flags.contains(.option) {
            result.insert(.option)
        }
        if flags.contains(.control) {
            result.insert(.control)
        }
        if flags.contains(.shift) {
            result.insert(.shift)
        }
        return result
    }

    func matches(flags: CGEventFlags, allowAdditional: Bool) -> Bool {
        let pressed = ShortcutModifiers.from(flags)
        if allowAdditional {
            return pressed.isSuperset(of: self)
        }
        return pressed == self
    }

    var displayParts: [String] {
        var parts: [String] = []
        if contains(.command) {
            parts.append("Cmd")
        }
        if contains(.option) {
            parts.append("Opt")
        }
        if contains(.control) {
            parts.append("Ctrl")
        }
        if contains(.shift) {
            parts.append("Shift")
        }
        return parts
    }
}

struct ShortcutDefinition: Codable, Hashable {
    var keyCode: Int
    var modifiers: ShortcutModifiers

    func matches(keyCode: CGKeyCode, flags: CGEventFlags, allowAdditional: Bool) -> Bool {
        return self.keyCode == Int(keyCode) && modifiers.matches(flags: flags, allowAdditional: allowAdditional)
    }

    var displayString: String {
        let keyLabel = KeyCode.label(for: CGKeyCode(keyCode))
        let parts = modifiers.displayParts + [keyLabel]
        return parts.joined(separator: "+")
    }
}

struct ShortcutsState: Codable, Equatable {
    var shortcuts: [ShortcutAction: ShortcutDefinition]

    init(shortcuts: [ShortcutAction: ShortcutDefinition]) {
        self.shortcuts = shortcuts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var values: [ShortcutAction: ShortcutDefinition] = [:]
        for key in container.allKeys {
            if let action = ShortcutAction(rawValue: key.stringValue) {
                values[action] = try container.decode(ShortcutDefinition.self, forKey: key)
            }
        }
        shortcuts = values
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)
        for (action, shortcut) in shortcuts {
            let key = DynamicCodingKey(stringValue: action.rawValue)
            try container.encode(shortcut, forKey: key)
        }
    }

    func layoutIndex(for keyCode: CGKeyCode, flags: CGEventFlags, allowAdditional: Bool) -> Int? {
        for action in ShortcutAction.allCases {
            guard let index = action.layoutIndex,
                  let shortcut = shortcuts[action],
                  shortcut.matches(keyCode: keyCode, flags: flags, allowAdditional: allowAdditional) else {
                continue
            }
            return index
        }
        return nil
    }
}

struct ShortcutsValidationResult: Equatable {
    let conflicts: Set<ShortcutAction>
    let missingModifiers: Set<ShortcutAction>
    let invalidKeys: Set<ShortcutAction>
    let message: String?

    var isValid: Bool {
        return conflicts.isEmpty && missingModifiers.isEmpty && invalidKeys.isEmpty
    }
}

enum ShortcutsStore {
    private static let storageKey = "WManager.shortcuts"

    static func load(userDefaults: UserDefaults = .standard) -> ShortcutsState {
        if let data = userDefaults.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(ShortcutsState.self, from: data) {
            return normalize(decoded)
        }
        return defaultState()
    }

    static func save(_ state: ShortcutsState, userDefaults: UserDefaults = .standard) {
        let normalized = normalize(state)
        if let data = try? JSONEncoder().encode(normalized) {
            userDefaults.set(data, forKey: storageKey)
        } else {
            userDefaults.removeObject(forKey: storageKey)
        }
        NotificationCenter.default.post(name: .shortcutsDidChange, object: nil)
    }

    static func defaultState() -> ShortcutsState {
        var shortcuts: [ShortcutAction: ShortcutDefinition] = [:]
        for action in ShortcutAction.allCases {
            shortcuts[action] = defaultShortcut(for: action)
        }
        return ShortcutsState(shortcuts: shortcuts)
    }

    static func defaultShortcut(for action: ShortcutAction) -> ShortcutDefinition {
        switch action {
        case .toggleOverlay:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.t),
                modifiers: [.command, .option]
            )
        case .tileLeft:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.leftArrow),
                modifiers: [.command, .option]
            )
        case .tileRight:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.rightArrow),
                modifiers: [.command, .option]
            )
        case .maximize:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.upArrow),
                modifiers: [.command, .option]
            )
        case .layout1:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.one),
                modifiers: [.control, .shift]
            )
        case .layout2:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.two),
                modifiers: [.control, .shift]
            )
        case .layout3:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.three),
                modifiers: [.control, .shift]
            )
        case .layout4:
            return ShortcutDefinition(
                keyCode: Int(KeyCode.four),
                modifiers: [.control, .shift]
            )
        }
    }

    static func validate(_ shortcuts: [ShortcutAction: ShortcutDefinition]) -> ShortcutsValidationResult {
        struct Signature: Hashable {
            let keyCode: Int
            let modifiers: ShortcutModifiers
        }

        var conflicts: Set<ShortcutAction> = []
        var missingModifiers: Set<ShortcutAction> = []
        var invalidKeys: Set<ShortcutAction> = []
        var signatureMap: [Signature: [ShortcutAction]] = [:]

        for action in ShortcutAction.allCases {
            guard let shortcut = shortcuts[action] else { continue }

            if shortcut.modifiers.isEmpty {
                missingModifiers.insert(action)
            }

            let cgKeyCode = CGKeyCode(shortcut.keyCode)
            if cgKeyCode == KeyCode.escape
                || cgKeyCode == KeyCode.returnKey
                || KeyCode.isModifierKey(cgKeyCode) {
                invalidKeys.insert(action)
            }

            let signature = Signature(keyCode: shortcut.keyCode, modifiers: shortcut.modifiers)
            signatureMap[signature, default: []].append(action)
        }

        for actions in signatureMap.values where actions.count > 1 {
            conflicts.formUnion(actions)
        }

        let message: String?
        if !missingModifiers.isEmpty {
            message = "Shortcuts must include at least one modifier key."
        } else if !invalidKeys.isEmpty {
            message = "Shortcuts cannot use Escape/Return or modifier-only keys."
        } else if !conflicts.isEmpty {
            message = "Shortcuts must be unique."
        } else {
            message = nil
        }

        return ShortcutsValidationResult(
            conflicts: conflicts,
            missingModifiers: missingModifiers,
            invalidKeys: invalidKeys,
            message: message
        )
    }

    private static func normalize(_ state: ShortcutsState) -> ShortcutsState {
        var shortcuts = state.shortcuts
        for action in ShortcutAction.allCases {
            if shortcuts[action] == nil {
                shortcuts[action] = defaultShortcut(for: action)
            }
        }
        return ShortcutsState(shortcuts: shortcuts)
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    var intValue: Int? { nil }

    init?(intValue: Int) {
        return nil
    }

    init(stringValue: String) {
        self.stringValue = stringValue
    }
}

extension Notification.Name {
    static let shortcutsDidChange = Notification.Name("ShortcutsStoreDidChange")
}

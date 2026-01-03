import Cocoa

enum AccessibilityHelper {
    static func ensureTrusted() {
        let promptKey = kAXTrustedCheckOptionPrompt.takeRetainedValue() as String
        let options = [promptKey: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            NSLog("Accessibility permission not granted yet.")
        }
    }
}

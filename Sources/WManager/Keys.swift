import CoreGraphics

enum KeyCode {
    static let one: CGKeyCode = 18
    static let two: CGKeyCode = 19
    static let three: CGKeyCode = 20
    static let four: CGKeyCode = 21
    static let five: CGKeyCode = 23
    static let six: CGKeyCode = 22
    static let seven: CGKeyCode = 26
    static let eight: CGKeyCode = 28
    static let nine: CGKeyCode = 25

    static let a: CGKeyCode = 0
    static let s: CGKeyCode = 1
    static let d: CGKeyCode = 2
    static let f: CGKeyCode = 3
    static let q: CGKeyCode = 12
    static let w: CGKeyCode = 13
    static let e: CGKeyCode = 14
    static let r: CGKeyCode = 15
    static let t: CGKeyCode = 17
    static let z: CGKeyCode = 6
    static let x: CGKeyCode = 7
    static let c: CGKeyCode = 8
    static let v: CGKeyCode = 9

    static let leftArrow: CGKeyCode = 123
    static let rightArrow: CGKeyCode = 124
    static let downArrow: CGKeyCode = 125
    static let upArrow: CGKeyCode = 126
    static let escape: CGKeyCode = 53
    static let returnKey: CGKeyCode = 36

    static let leftShift: CGKeyCode = 56
    static let rightShift: CGKeyCode = 60
    static let leftControl: CGKeyCode = 59
    static let rightControl: CGKeyCode = 62
    static let leftOption: CGKeyCode = 58
    static let rightOption: CGKeyCode = 61
    static let leftCommand: CGKeyCode = 55
    static let rightCommand: CGKeyCode = 54

    static func isModifierKey(_ keyCode: CGKeyCode) -> Bool {
        switch keyCode {
        case leftShift, rightShift,
             leftControl, rightControl,
             leftOption, rightOption,
             leftCommand, rightCommand:
            return true
        default:
            return false
        }
    }

    static func label(for keyCode: CGKeyCode) -> String {
        switch keyCode {
        case one: return "1"
        case two: return "2"
        case three: return "3"
        case four: return "4"
        case five: return "5"
        case six: return "6"
        case seven: return "7"
        case eight: return "8"
        case nine: return "9"
        case a: return "A"
        case s: return "S"
        case d: return "D"
        case f: return "F"
        case q: return "Q"
        case w: return "W"
        case e: return "E"
        case r: return "R"
        case t: return "T"
        case z: return "Z"
        case x: return "X"
        case c: return "C"
        case v: return "V"
        case leftArrow: return "Left"
        case rightArrow: return "Right"
        case downArrow: return "Down"
        case upArrow: return "Up"
        case escape: return "Esc"
        case returnKey: return "Return"
        default:
            return "Key \(keyCode)"
        }
    }
}

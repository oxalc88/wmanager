import Cocoa
import Darwin

enum DesktopManager {
    static func currentSpaceID(for screen: NSScreen?) -> CGSSpaceID? {
        guard let connection = SkyLightAPI.mainConnectionID(),
              let copySpaces = SkyLightAPI.copyManagedDisplaySpaces() else {
            return nil
        }
        guard let managedSpaces = copySpaces(connection) as? [[String: Any]] else {
            return nil
        }

        let targetScreen = screen ?? NSScreen.main ?? NSScreen.screens.first
        let displayIdentifierValue: String?
        if let targetScreen {
            displayIdentifierValue = displayIdentifier(for: targetScreen)
        } else {
            displayIdentifierValue = nil
        }
        let displayEntry = managedSpaces.first { entry in
            guard let entryIdentifier = entry["Display Identifier"] as? String else { return false }
            return entryIdentifier == displayIdentifierValue
        } ?? managedSpaces.first

        if let current = displayEntry?["Current Space"] {
            if let spaceID = managedSpaceID(from: current) {
                return spaceID
            }
        }

        let spacesValue = displayEntry?["Spaces"]
        if let spaces = spacesValue as? [[String: Any]] {
            if let current = spaces.first(where: { ($0["Current Space"] as? NSNumber)?.boolValue == true }) {
                return managedSpaceID(from: current)
            }
            if let first = spaces.first {
                return managedSpaceID(from: first)
            }
        }

        return nil
    }

    private static func managedSpaceID(from value: Any) -> CGSSpaceID? {
        if let space = value as? [String: Any] {
            return managedSpaceID(from: space)
        }
        if let number = value as? NSNumber {
            return number.uint64Value
        }
        if let number = value as? UInt64 {
            return number
        }
        if let number = value as? Int {
            return CGSSpaceID(number)
        }
        return nil
    }

    private static func managedSpaceID(from space: [String: Any]) -> CGSSpaceID? {
        if let id = space["ManagedSpaceID"] as? NSNumber {
            return id.uint64Value
        }
        if let id = space["ManagedSpaceID"] as? UInt64 {
            return id
        }
        if let id = space["ManagedSpaceID"] as? Int {
            return CGSSpaceID(id)
        }
        return nil
    }

    private static func displayIdentifier(for screen: NSScreen) -> String? {
        guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
            return nil
        }
        let displayID = CGDirectDisplayID(screenNumber.uint32Value)
        guard let uuid = CGDisplayCreateUUIDFromDisplayID(displayID) else { return nil }
        return CFUUIDCreateString(kCFAllocatorDefault, uuid.takeRetainedValue()) as String
    }
}

private enum SkyLightAPI {
    typealias CGSMainConnectionIDFunc = @convention(c) () -> CGSConnectionID
    typealias CGSCopyManagedDisplaySpacesFunc = @convention(c) (CGSConnectionID) -> CFArray

    private static let handles: [UnsafeMutableRawPointer] = {
        let paths = [
            "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight",
            "/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/SkyLight",
            "/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices"
        ]
        var loaded: [UnsafeMutableRawPointer] = []
        for path in paths {
            if let handle = dlopen(path, RTLD_LAZY) {
                loaded.append(handle)
            }
        }
        return loaded
    }()

    private static let defaultHandles: [UnsafeMutableRawPointer] = [
        UnsafeMutableRawPointer(bitPattern: -2), // RTLD_DEFAULT
        UnsafeMutableRawPointer(bitPattern: -5)  // RTLD_MAIN_ONLY
    ].compactMap { $0 }

    static func mainConnectionID() -> CGSConnectionID? {
        return loadAny(["CGSMainConnectionID", "SLSMainConnectionID"], as: CGSMainConnectionIDFunc.self)?()
    }

    static func copyManagedDisplaySpaces() -> CGSCopyManagedDisplaySpacesFunc? {
        return loadAny(["CGSCopyManagedDisplaySpaces", "SLSCopyManagedDisplaySpaces"], as: CGSCopyManagedDisplaySpacesFunc.self)
    }

    private static func loadAny<T>(_ names: [String], as type: T.Type) -> T? {
        let searchHandles = defaultHandles + handles
        for handle in searchHandles {
            for name in names {
                if let symbol = dlsym(handle, name) {
                    return unsafeBitCast(symbol, to: type)
                }
            }
        }
        return nil
    }
}

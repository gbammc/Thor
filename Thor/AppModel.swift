//
//  AppModel.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut
import Carbon.HIToolbox
import OSLog

@available(macOS 11.0, *)
extension Logger {
    static let app = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "app")
    static let shortcut = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "shortcut")
}

class AppModel: NSObject {

    let id: UUID
    let appDisplayName: String
    let appBundleIdentifier: String
    let appBundleURL: URL?
    let appIconData: Data?
    let bookmark: Data?
    let shortcut: MASShortcut?

    private let values: [String: String]

    private enum InfoKeys: String {
        case appBundleURL, appBundleIdentifier, appDisplayName, shortcut, appIconData, bookmark
        case shortcutKeyCode, shortcutModifierFlags
    }

    var icon: NSImage? {
        var iconImage: NSImage?

        if let appIconData {
            iconImage = NSImage(data: appIconData)
        } else {
            guard let appBundleURL, let bundle = Bundle(url: appBundleURL) else {
                return nil
            }

            if let iconFileName = (bundle.infoDictionary?["CFBundleIconFile"]) as? String,
               let iconFilePath = bundle.pathForImageResource(iconFileName) {
                iconImage = NSImage(contentsOfFile: iconFilePath)
            } else if let iconName = (bundle.infoDictionary?["CFBundleIconName"]) as? String,
                      let image = bundle.image(forResource: iconName) {
                iconImage = image
            }
        }

        iconImage?.size = NSSize(width: 36, height: 36)

        return iconImage
    }

    static func resizeImage(image: NSImage, targetSize: NSSize) -> NSImage? {
        let resizedImage = NSImage(size: targetSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize))
        resizedImage.unlockFocus()
        return resizedImage
    }

    static func appIconData(from bundle: Bundle) -> Data? {
        if let iconFileName = (bundle.infoDictionary?["CFBundleIconFile"]) as? String,
           let iconFilePath = bundle.pathForImageResource(iconFileName),
           let originImage = NSImage(contentsOfFile: iconFilePath),
           let resizedImage = resizeImage(image: originImage, targetSize: NSSize(width: 36, height: 36)) {
            guard let tiffData = resizedImage.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData) else { return nil }
            return bitmapRep.representation(using: .png, properties: [:])
        } else if let iconName = (bundle.infoDictionary?["CFBundleIconName"]) as? String,
                  let originImage = bundle.image(forResource: iconName),
                  let resizedImage = resizeImage(image: originImage, targetSize: NSSize(width: 36, height: 36)) {
            guard let tiffData = resizedImage.tiffRepresentation,
                  let bitmapRep = NSBitmapImageRep(data: tiffData) else { return nil }
            return bitmapRep.representation(using: .png, properties: [:])
        }
        return nil
    }

    convenience init?(selectedURL url: URL) {
        guard let bundle = Bundle(url: url) else { return nil }
        let displayName = NSMetadataItem(url: url)?.value(forAttribute: kMDItemDisplayName as String) as? String
            ?? FileManager.default.displayName(atPath: url.path)
        var values = [
            InfoKeys.appBundleURL.rawValue: url.absoluteString,
            InfoKeys.appBundleIdentifier.rawValue: bundle.bundleIdentifier ?? "",
            InfoKeys.appDisplayName.rawValue: displayName,
            InfoKeys.shortcut.rawValue: ""
        ]
        values[InfoKeys.appIconData.rawValue] = Self.appIconData(from: bundle)?.base64EncodedString()
        do {
            values[InfoKeys.bookmark.rawValue] = try Self.makeBookmark(for: url).base64EncodedString()
        } catch {
            Logger.app.warning("Could not save application bookmark: \(error.localizedDescription)")
        }
        self.init(values: values, displayName: displayName)
    }

    convenience init?(dict: NSDictionary) {
        guard let displayName = dict[InfoKeys.appDisplayName.rawValue] as? String else { return nil }
        let values = dict as? [String: Any] ?? [:]
        var strings = values.compactMapValues { $0 as? String }
        for key in [InfoKeys.appIconData, .bookmark] {
            if let data = values[key.rawValue] as? Data {
                strings[key.rawValue] = data.base64EncodedString()
            }
        }
        if let shortcut = values[InfoKeys.shortcut.rawValue] as? MASShortcut {
            Self.encode(shortcut, into: &strings)
        }
        self.init(values: strings, displayName: displayName)
    }

    convenience init?(jsonValue: [String: String]) {
        guard let displayName = jsonValue[InfoKeys.appDisplayName.rawValue] else { return nil }
        self.init(values: jsonValue, displayName: displayName)
    }

    private init(values: [String: String], displayName: String, id: UUID = UUID()) {
        self.id = id
        self.values = values
        appDisplayName = displayName
        appBundleIdentifier = values[InfoKeys.appBundleIdentifier.rawValue] ?? ""
        if let storedURL = values[InfoKeys.appBundleURL.rawValue],
           let url = URL(string: storedURL), url.isFileURL {
            appBundleURL = url
        } else {
            appBundleURL = nil
        }
        appIconData = values[InfoKeys.appIconData.rawValue].flatMap { Data(base64Encoded: $0) }
        bookmark = values[InfoKeys.bookmark.rawValue].flatMap { Data(base64Encoded: $0) }
        if let keyCode = values[InfoKeys.shortcutKeyCode.rawValue].flatMap(UInt16.init),
           let modifierFlags = values[InfoKeys.shortcutModifierFlags.rawValue].flatMap(UInt.init) {
            shortcut = MASShortcut(keyCode: Int(keyCode), modifierFlags: NSEvent.ModifierFlags(rawValue: modifierFlags))
        } else {
            shortcut = values[InfoKeys.shortcut.rawValue].flatMap { MASShortcut(from: $0) }
        }
    }

    func settingShortcut(_ shortcut: MASShortcut?) -> AppModel {
        var updated = values
        Self.encode(shortcut, into: &updated)
        return AppModel(values: updated, displayName: appDisplayName, id: id)
    }

    func relocating(to app: AppModel) -> AppModel {
        var updated = values
        for key in [InfoKeys.appBundleURL, .appBundleIdentifier, .appDisplayName, .appIconData, .bookmark] {
            updated[key.rawValue] = app.values[key.rawValue]
        }
        return AppModel(values: updated, displayName: app.appDisplayName, id: id)
    }

    func refreshingBookmark(_ data: Data, at url: URL) -> AppModel {
        var updated = values
        updated[InfoKeys.bookmark.rawValue] = data.base64EncodedString()
        updated[InfoKeys.appBundleURL.rawValue] = url.absoluteString
        return AppModel(values: updated, displayName: appDisplayName, id: id)
    }

    func restoringBookmark(from localApps: [AppModel]) -> AppModel {
        if let bookmark, matchesImportedTarget(bookmark) { return self }

        let path = appBundleURL?.standardizedFileURL.path
        let identifier = appBundleIdentifier
        let localBookmark = localApps.lazy.filter { app in
            path != nil && app.appBundleIdentifier == identifier
                && app.appBundleURL?.standardizedFileURL.path == path
        }.compactMap(\.bookmark).first(where: matchesImportedTarget)
        var updated = values
        updated[InfoKeys.bookmark.rawValue] = localBookmark?.base64EncodedString()
        return AppModel(values: updated, displayName: appDisplayName, id: id)
    }

    private func matchesImportedTarget(_ bookmark: Data) -> Bool {
        guard let resolved = try? accessBookmarkedApp(bookmark) else { return false }
        // A bookmark may follow a moved app, but a still-available saved path identifies a specific copy.
        guard let targetURL = appBundleURL, matchesApp(at: targetURL) else { return true }
        return Self.isSameApp(at: resolved.url, as: targetURL)
    }

    static func makeBookmark(for url: URL) throws -> Data {
        try url.bookmarkData(options: [],
                             includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    func encodeToJSONValue() -> [String: String] {
        values
    }

    private static func encode(_ shortcut: MASShortcut?, into values: inout [String: String]) {
        values[InfoKeys.shortcut.rawValue] = shortcut?.toString() ?? ""
        values[InfoKeys.shortcutKeyCode.rawValue] = shortcut.map { String($0.keyCode) }
        values[InfoKeys.shortcutModifierFlags.rawValue] = shortcut.map { String($0.modifierFlags.rawValue) }
    }

}

extension MASShortcut {

    static let keycodeMap = [
        kVK_ANSI_A: "a",
        kVK_ANSI_S: "s",
        kVK_ANSI_D: "d",
        kVK_ANSI_F: "f",
        kVK_ANSI_H: "h",
        kVK_ANSI_G: "g",
        kVK_ANSI_Z: "z",
        kVK_ANSI_X: "x",
        kVK_ANSI_C: "c",
        kVK_ANSI_V: "v",
        kVK_ANSI_B: "b",
        kVK_ANSI_Q: "q",
        kVK_ANSI_W: "w",
        kVK_ANSI_E: "e",
        kVK_ANSI_R: "r",
        kVK_ANSI_Y: "y",
        kVK_ANSI_T: "t",
        kVK_ANSI_O: "o",
        kVK_ANSI_U: "u",
        kVK_ANSI_I: "i",
        kVK_ANSI_P: "p",
        kVK_ANSI_L: "l",
        kVK_ANSI_J: "j",
        kVK_ANSI_K: "k",
        kVK_ANSI_N: "n",
        kVK_ANSI_M: "m",

        kVK_ANSI_1: "1",
        kVK_ANSI_2: "2",
        kVK_ANSI_3: "3",
        kVK_ANSI_4: "4",
        kVK_ANSI_5: "5",
        kVK_ANSI_6: "6",
        kVK_ANSI_7: "7",
        kVK_ANSI_8: "8",
        kVK_ANSI_9: "9",
        kVK_ANSI_0: "0",

        kVK_ANSI_Equal: "=",
        kVK_ANSI_Minus: "-",
        kVK_ANSI_RightBracket: "]",
        kVK_ANSI_LeftBracket: "[",
        kVK_ANSI_Quote: "\"",
        kVK_ANSI_Semicolon: ";",
        kVK_ANSI_Backslash: "\\",
        kVK_ANSI_Comma: ",",
        kVK_ANSI_Slash: "/",
        kVK_ANSI_Period: ".",
        kVK_ANSI_Grave: "`",

        kVK_ANSI_KeypadDecimal: "numpad_decimal",
        kVK_ANSI_KeypadMultiply: "numpad_multiply",
        kVK_ANSI_KeypadPlus: "numpad_add",
        kVK_ANSI_KeypadDivide: "numpad_divide",
        kVK_ANSI_KeypadMinus: "numpad_subtract",
        kVK_ANSI_KeypadClear: "numpad_clear",
        kVK_ANSI_KeypadEnter: "numpad_enter",
        kVK_ANSI_KeypadEquals: "numpad_equals",
        kVK_ANSI_Keypad0: "numpad0",
        kVK_ANSI_Keypad1: "numpad1",
        kVK_ANSI_Keypad2: "numpad2",
        kVK_ANSI_Keypad3: "numpad3",
        kVK_ANSI_Keypad4: "numpad4",
        kVK_ANSI_Keypad5: "numpad5",
        kVK_ANSI_Keypad6: "numpad6",
        kVK_ANSI_Keypad7: "numpad7",
        kVK_ANSI_Keypad8: "numpad8",
        kVK_ANSI_Keypad9: "numpad9",

        kVK_Return: "return",
        kVK_End: "end",
        kVK_Home: "home",
        kVK_Tab: "tab",
        kVK_Escape: "escape",
        kVK_Space: "space",
        kVK_Delete: "delete",
        kVK_CapsLock: "capslock",
        kVK_PageDown: "pagedown",
        kVK_PageUp: "pageup",

        kVK_LeftArrow: "left",
        kVK_RightArrow: "right",
        kVK_DownArrow: "down",
        kVK_UpArrow: "up",

        kVK_F1: "f1",
        kVK_F2: "f2",
        kVK_F3: "f3",
        kVK_F4: "f4",
        kVK_F5: "f5",
        kVK_F6: "f6",
        kVK_F7: "f7",
        kVK_F8: "f8",
        kVK_F9: "f9",
        kVK_F10: "f10",
        kVK_F11: "f11",
        kVK_F12: "f12",
        kVK_F13: "f13",
        kVK_F14: "f14",
        kVK_F15: "f15",
        kVK_F16: "f16",
        kVK_F17: "f17",
        kVK_F18: "f18",
        kVK_F19: "f19",
        kVK_F20: "f20"
    ]

    private static let inversedKeycodeMap = Dictionary(uniqueKeysWithValues: keycodeMap.map { ($0.value, $0.key) })

    static let supportedModifiers = [
        NSEvent.ModifierFlags.shift,
        NSEvent.ModifierFlags.control,
        NSEvent.ModifierFlags.option,
        NSEvent.ModifierFlags.command
    ]

    static let modifierMap = [
        NSEvent.ModifierFlags.shift: "shift",
        NSEvent.ModifierFlags.control: "ctrl",
        NSEvent.ModifierFlags.option: "alt",
        NSEvent.ModifierFlags.command: "cmd"
    ]

    static let inversedModifierMap: [String: NSEvent.ModifierFlags] = {
        var inversedMap = [String: NSEvent.ModifierFlags]()
        for (key, value) in MASShortcut.modifierMap {
            inversedMap[value] = key
        }
        return inversedMap
    }()

    convenience init?(from string: String) {
        let components = string.split(separator: "+", omittingEmptySubsequences: false)

        var modifiers = NSEvent.ModifierFlags(rawValue: 0)
        var keyCode: Int?
        for key in components {
            if let modifier = MASShortcut.inversedModifierMap[String(key)] {
                guard !modifiers.contains(modifier) else { return nil }
                modifiers.insert(modifier)
            } else if let code = MASShortcut.inversedKeycodeMap[String(key)] {
                // only support one key code
                guard keyCode == nil else { return nil }
                keyCode = code
            } else {
                // invalid value
                return nil
            }
        }

        guard let keyCode else { return nil }
        self.init(keyCode: keyCode, modifierFlags: modifiers)
    }

    func toString() -> String {
        let msg = "keyCode: \(self.keyCode), "
                    + "keyValue: \(MASShortcut.keycodeMap[self.keyCode] ?? ""), "
                    + "modifiers: \(self.modifierFlags.rawValue)"
        Logger.shortcut.info("\(msg)")

        guard let key = MASShortcut.keycodeMap[keyCode] else { return "" }

        var components = [String]()
        for modifier in MASShortcut.supportedModifiers where modifierFlags.contains(modifier) {
            components.append(MASShortcut.modifierMap[modifier]!)
        }
        components.append(key)
        return components.joined(separator: "+")
    }

}

extension NSEvent.ModifierFlags: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

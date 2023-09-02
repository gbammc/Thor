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

class AppModel: NSObject {

    let appBundleURL: URL
    let appDisplayName: String
    var shortcut: MASShortcut?

    private enum InfoKeys: String {
        case appBundleURL, appDisplayName, shortcut, bookmark
    }

    var icon: NSImage? {
        guard let bundle = Bundle(url: appBundleURL) else {
            return nil
        }

        var iconImage: NSImage?

        if let iconFileName = (bundle.infoDictionary?["CFBundleIconFile"]) as? String,
           let iconFilePath = bundle.pathForImageResource(iconFileName) {
            iconImage = NSImage(contentsOfFile: iconFilePath)
        } else if let iconName = (bundle.infoDictionary?["CFBundleIconName"]) as? String,
                  let image = bundle.image(forResource: iconName) {
            iconImage = image
        }

        iconImage?.size = NSSize(width: 36, height: 36)

        return iconImage
    }

    init?(item: NSMetadataItem) {
        guard let path = item.value(forAttribute: kMDItemPath as String) as? String,
              let displayName = item.value(forAttribute: kMDItemDisplayName as String) as? String,
              let appBundle = Bundle(path: path) else {
            return nil
        }

        self.appBundleURL = appBundle.bundleURL
        self.appDisplayName = displayName
    }

    init?(dict: NSDictionary) {
        guard let appBundle = dict.object(forKey: InfoKeys.appBundleURL.rawValue) as? String,
              let bundleURL = URL(string: appBundle), Bundle(url: bundleURL) != nil,
              let displayName = dict.object(forKey: InfoKeys.appDisplayName.rawValue) as? String,
              let shortcut = dict.object(forKey: InfoKeys.shortcut.rawValue) as? MASShortcut else {
            return nil
        }

        self.appBundleURL = bundleURL
        self.appDisplayName = displayName
        self.shortcut = shortcut
    }

    init?(jsonValue: [String: String]) {
        guard let appBundle = jsonValue[InfoKeys.appBundleURL.rawValue],
              let bundleURL = URL(string: appBundle), Bundle(url: bundleURL) != nil,
              let displayName = jsonValue[InfoKeys.appDisplayName.rawValue],
              let shortcutString = jsonValue[InfoKeys.shortcut.rawValue],
              let shortcut = MASShortcut(from: shortcutString) else {
            return nil
        }

        self.appBundleURL = bundleURL
        self.appDisplayName = displayName
        self.shortcut = shortcut
    }

    func encode() -> NSDictionary {
        var dict = [String: Any]()
        dict[InfoKeys.appBundleURL.rawValue] = appBundleURL.absoluteString
        dict[InfoKeys.appDisplayName.rawValue] = appDisplayName
        dict[InfoKeys.shortcut.rawValue] = shortcut ?? NSNull()

        return dict as NSDictionary
    }

    func encodeToJSONValue() -> [String: String] {
        return [
            InfoKeys.appBundleURL.rawValue: appBundleURL.absoluteString,
            InfoKeys.appDisplayName.rawValue: appDisplayName,
            InfoKeys.shortcut.rawValue: shortcut?.toString() ?? ""
        ]
    }

}

func == (lhs: AppModel, rhs: AppModel) -> Bool {
    return lhs.appBundleURL.absoluteString == rhs.appBundleURL.absoluteString
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

    static func inversedKeycodeMap() -> [String: Int] {
        var inversedMap = [String: Int]()
        for (key, value) in MASShortcut.keycodeMap {
            inversedMap[value] = key
        }
        return inversedMap
    }

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

    static func inversedModifierMap() -> [String: NSEvent.ModifierFlags] {
        var inversedMap = [String: NSEvent.ModifierFlags]()
        for (key, value) in MASShortcut.modifierMap {
            inversedMap[value] = key
        }
        return inversedMap
    }

    convenience init?(from string: String) {
        let components = string.split(separator: "+")
        guard components.count > 0 else { return nil }

        var modifiers = NSEvent.ModifierFlags(rawValue: 0)
        var keyCode = 0
        for key in components {
            if let modifier = MASShortcut.inversedModifierMap()[String(key)] {
                guard !modifiers.contains(modifier) else { return nil }
                modifiers.insert(modifier)
            } else if let code = MASShortcut.inversedKeycodeMap()[String(key)] {
                // only support one key code
                guard keyCode == 0 else { return nil }
                keyCode = code
            } else {
                // invalid value
                return nil
            }
        }

        self.init(keyCode: keyCode, modifierFlags: modifiers)
    }

    func toString() -> String {
        guard let key = MASShortcut.keycodeMap[keyCode] else { return "" }

        var components = [String]()
        for modifier in MASShortcut.supportedModifiers {
            if modifierFlags.contains(modifier) {
                components.append(MASShortcut.modifierMap[modifier]!)
            }
        }
        components.append(key)
        return components.joined(separator: "+")
    }

}

extension NSEvent.ModifierFlags: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

//
//  NSApplication+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 5/5/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import ServiceManagement

extension NSApplication {

    class func shortVersionString() -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return "Unknown"
        }

        return (infoDict["CFBundleShortVersionString"] as? String) ?? ""
    }

    class func buildVersionString() -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return "?"
        }

        return (infoDict["CFBundleVersion"] as? String) ?? ""
    }

    class func formattedVersion() -> String {
        return "Version \(shortVersionString()) (\(buildVersionString()))"
    }

}

extension NSApplication {

    // MARK: Variables

    var startAtLogin: Bool {
        get {
            if defaults.value(forKey: DefaultsKeys.LaunchAtLoginKey.key) == nil {
                defaults[.LaunchAtLoginKey] = itemRefInLoginItems().thisRef != nil
            }
            return defaults[.LaunchAtLoginKey]
        }
        set {
            defaults[.LaunchAtLoginKey] = newValue
            SMLoginItemSetEnabled(launcherAppId as CFString, newValue)
        }
    }

    private var loginItemsRef: LSSharedFileList? {
        let items = kLSSharedFileListSessionLoginItems.takeRetainedValue()
        return LSSharedFileListCreate(nil, items, nil).takeRetainedValue()
    }

    // MARK: Methods

    func toggleStartAtLogin() {
        startAtLogin = !startAtLogin
    }

    private func itemRefInLoginItems() -> (thisRef: LSSharedFileListItem?, lastRef: LSSharedFileListItem?) {
        guard let ref = loginItemsRef,
            let items = LSSharedFileListCopySnapshot(ref, nil).takeRetainedValue() as? [LSSharedFileListItem] else {
                return (nil, nil)
        }

        guard items.count > 0, let lastItem = items.last else {
            return (nil, kLSSharedFileListItemBeforeFirst.takeRetainedValue())
        }

        let bundleURL = Bundle.main.bundleURL
        for item in items {
            let itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil)
            if let itemURL = itemURL, bundleURL == URL(string: String(describing: itemURL.takeRetainedValue())) {
                return (item, lastItem)
            }
        }

        return (nil, lastItem)
    }

}

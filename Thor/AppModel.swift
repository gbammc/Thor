//
//  AppModel.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class AppModel: NSObject {

    let appBundleURL: URL
    let appName: String
    let appDisplayName: String
    let appIconName: String

    var shortcut: MASShortcut?

    var icon: NSImage? {
        guard let bundle = Bundle(url: appBundleURL), let bundleIdentifier = bundle.bundleIdentifier else {
            return nil
        }

        let compositeName = "\(bundleIdentifier):\(appIconName)"

        guard let file = bundle.pathForImageResource(appIconName),
            let bundleImage = NSImage(contentsOfFile: file) else {
                return nil
        }

        bundleImage.setName(compositeName)
        bundleImage.size = NSSize(width: 36, height: 36)

        return bundleImage
    }

    init?(item: NSMetadataItem) {
        guard let path = item.value(forAttribute: kMDItemPath as String) as? String,
            let displayName = item.value(forAttribute: kMDItemDisplayName as String) as? String,
            let name = item.value(forKey: kMDItemFSName as String) as? String,
            let appBundle = Bundle(path: path),
            let iconName = (appBundle.infoDictionary?["CFBundleIconFile"]) as? String else {
                return nil
        }

        self.appBundleURL = appBundle.bundleURL
        self.appName = name
        self.appDisplayName = displayName
        self.appIconName = iconName
    }

    init?(dict: NSDictionary) {
        guard let appBundle = dict.object(forKey: "appBundleURL") as? String,
            let bundleURL = URL(string: appBundle), Bundle(url: bundleURL) != nil,
            let name = dict.object(forKey: "appName") as? String,
            let displayName = dict.object(forKey: "appDisplayName") as? String,
            let iconName = dict.object(forKey: "appIconName") as? String,
            let shortcut = dict.object(forKey: "shortcut") as? MASShortcut else {
                return nil
        }

        self.appBundleURL = bundleURL
        self.appName = name
        self.appDisplayName = displayName
        self.appIconName = iconName
        self.shortcut = shortcut
    }

    func encode() -> NSDictionary {
        var dict = [String: Any]()
        dict["appBundleURL"] = appBundleURL.absoluteString
        dict["appName"] = appName
        dict["appDisplayName"] = appDisplayName
        dict["appIconName"] = appIconName
        dict["shortcut"] = shortcut ?? NSNull()

        return dict as NSDictionary
    }

}

func == (lhs: AppModel, rhs: AppModel) -> Bool {
    return lhs.appBundleURL.absoluteString == rhs.appBundleURL.absoluteString
}

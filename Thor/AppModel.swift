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
    var shortcut: MASShortcut?

    private enum InfoKeys: String {
        case appBundleURL, appName, appDisplayName, shortcut, bookmark
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
              let name = item.value(forKey: kMDItemFSName as String) as? String,
              let appBundle = Bundle(path: path) else {
            return nil
        }

        self.appBundleURL = appBundle.bundleURL
        self.appName = name
        self.appDisplayName = displayName
    }

    init?(dict: NSDictionary) {
        guard let appBundle = dict.object(forKey: InfoKeys.appBundleURL.rawValue) as? String,
              let bundleURL = URL(string: appBundle), Bundle(url: bundleURL) != nil,
              let name = dict.object(forKey: InfoKeys.appName.rawValue) as? String,
              let displayName = dict.object(forKey: InfoKeys.appDisplayName.rawValue) as? String,
              let shortcut = dict.object(forKey: InfoKeys.shortcut.rawValue) as? MASShortcut else {
            return nil
        }

        self.appBundleURL = bundleURL
        self.appName = name
        self.appDisplayName = displayName
        self.shortcut = shortcut
    }

    func encode() -> NSDictionary {
        var dict = [String: Any]()
        dict[InfoKeys.appBundleURL.rawValue] = appBundleURL.absoluteString
        dict[InfoKeys.appName.rawValue] = appName
        dict[InfoKeys.appDisplayName.rawValue] = appDisplayName
        dict[InfoKeys.shortcut.rawValue] = shortcut ?? NSNull()

        return dict as NSDictionary
    }

}

func == (lhs: AppModel, rhs: AppModel) -> Bool {
    return lhs.appBundleURL.absoluteString == rhs.appBundleURL.absoluteString
}

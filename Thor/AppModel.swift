//
//  AppModel.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class AppModel: Equatable {

    let appBundleURL: URL
    let appName: String
    let appDisplayName: String
    let appIconName: String
    
    var shortcut: MASShortcut?
    
    var icon: NSImage? {
        get {
            let bundle = Bundle(url: appBundleURL)!
            let compositeName = "\(bundle.bundleIdentifier):\(appIconName)"
            if let file = bundle.pathForImageResource(appIconName), bundleImage = NSImage(contentsOfFile: file) {
                bundleImage.setName(compositeName)
                bundleImage.size = NSSize(width: 36, height: 36)
                return bundleImage
            }
            
            return nil
        }
    }
    
    init?(item: NSMetadataItem) {
        guard let path = item.value(forAttribute: kMDItemPath as String) as? String else { return nil }
        
        guard let displayName = item.value(forAttribute: kMDItemDisplayName as String) as? String else { return nil }
        
        guard let name = item.value(forKey: kMDItemFSName as String) as? String else { return nil }
        
        guard let appBundle = Bundle(path: path) else { return nil }
        
        guard let iconName = (appBundle.infoDictionary?["CFBundleIconFile"]) as? String else { return nil }
        
        self.appBundleURL = appBundle.bundleURL
        self.appName = name
        self.appDisplayName = displayName
        self.appIconName = iconName
    }
    
    init?(dict: NSDictionary) {
        guard let appBundle = dict.object(forKey: "appBundleURL") as? String else { return nil }
        self.appBundleURL = URL(string: appBundle)!
        
        guard let name = dict.object(forKey: "appName") as? String else { return nil }
        self.appName = name
        
        guard let displayName = dict.object(forKey: "appDisplayName") as? String else { return nil }
        self.appDisplayName = displayName
        
        guard let iconName = dict.object(forKey: "appIconName") as? String else { return nil }
        self.appIconName = iconName
        
        if let shortcut = dict.object(forKey: "shortcut") as? MASShortcut {
            self.shortcut = shortcut
        }
    }
    
    func encode() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict.setObject(appBundleURL.absoluteString!, forKey: "appBundleURL")
        dict.setObject(appName, forKey: "appName")
        dict.setObject(appDisplayName, forKey: "appDisplayName")
        dict.setObject(appIconName, forKey: "appIconName")
        dict.setObject(shortcut ?? NSNull(), forKey: "shortcut")
        
        return dict
    }
    
    class func appsFroms(_ items: [AnyObject]) -> [AppModel] {
        guard let apps = items as? [NSMetadataItem] else { return [] }
        
        return apps.flatMap({ AppModel(item: $0) }).sorted(isOrderedBefore: { $0.0.appDisplayName.lowercased() < $0.1.appDisplayName.lowercased() })
    }
    
}

func ==(lhs: AppModel, rhs: AppModel) -> Bool {
    return lhs.appBundleURL.absoluteString == rhs.appBundleURL.absoluteString
}

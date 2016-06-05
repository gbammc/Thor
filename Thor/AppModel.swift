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

    let appBundleURL: NSURL
    let appName: String
    let appDisplayName: String
    let appIconName: String
    
    var shortcut: MASShortcut?
    
    var icon: NSImage? {
        get {
            let bundle = NSBundle(URL: appBundleURL)!
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
        guard let path = item.valueForAttribute(kMDItemPath as String) as? String else { return nil }
        
        guard let displayName = item.valueForAttribute(kMDItemDisplayName as String) as? String else { return nil }
        
        guard let name = item.valueForKey(kMDItemFSName as String) as? String else { return nil }
        
        guard let appBundle = NSBundle(path: path) else { return nil }
        
        guard let iconName = (appBundle.infoDictionary?["CFBundleIconFile"]) as? String else { return nil }
        
        self.appBundleURL = appBundle.bundleURL
        self.appName = name
        self.appDisplayName = displayName
        self.appIconName = iconName
    }
    
    init?(dict: NSDictionary) {
        guard let appBundle = dict.objectForKey("appBundleURL") as? String else { return nil }
        self.appBundleURL = NSURL(string: appBundle)!
        
        guard let name = dict.objectForKey("appName") as? String else { return nil }
        self.appName = name
        
        guard let displayName = dict.objectForKey("appDisplayName") as? String else { return nil }
        self.appDisplayName = displayName
        
        guard let iconName = dict.objectForKey("appIconName") as? String else { return nil }
        self.appIconName = iconName
        
        if let shortcut = dict.objectForKey("shortcut") as? MASShortcut {
            self.shortcut = shortcut
        }
    }
    
    func encode() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict.setObject(appBundleURL.absoluteString, forKey: "appBundleURL")
        dict.setObject(appName, forKey: "appName")
        dict.setObject(appDisplayName, forKey: "appDisplayName")
        dict.setObject(appIconName, forKey: "appIconName")
        dict.setObject(shortcut ?? NSNull(), forKey: "shortcut")
        
        return dict
    }
    
    class func appsFroms(items: [AnyObject]) -> [AppModel] {
        guard let apps = items as? [NSMetadataItem] else { return [] }
        
        return apps.flatMap({ AppModel(item: $0) }).sort({ $0.0.appDisplayName.lowercaseString < $0.1.appDisplayName.lowercaseString })
    }
    
}

func ==(lhs: AppModel, rhs: AppModel) -> Bool {
    return lhs.appBundleURL.absoluteString == rhs.appBundleURL.absoluteString
}

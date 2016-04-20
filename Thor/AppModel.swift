//
//  AppModel.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

class AppModel {

    let appBundleURL: NSURL
    let appName: String
    let appDisplayName: String
    let appIconName: String
    let isSysApp: Bool
    
    init?(item: NSMetadataItem) {
        guard let path = item.valueForAttribute(kMDItemPath as String) as? String else { return nil }
    
        guard let appBundle = NSBundle(path: path) else { return nil }
        
        guard let iconName = appBundle.infoDictionary?["CFBundleIconFile"] as? String else { return nil }
        
        guard let name = item.valueForKey(kMDItemFSName as String) as? String else { return nil }
        
        guard let displayName = item.valueForAttribute(kMDItemDisplayName as String) as? String else { return nil }
        
        self.appBundleURL = appBundle.bundleURL
        self.appName = name
        self.appDisplayName = displayName
        self.appIconName = iconName
        self.isSysApp = path.containsString("/System/Library")
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
        
        guard let isSysApp = dict.objectForKey("isSysApp") as? Bool else { return nil }
        self.isSysApp = isSysApp
    }
    
    func encode() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict.setObject(appBundleURL.absoluteString, forKey: "appBundleURL")
        dict.setObject(appName, forKey: "appName")
        dict.setObject(appDisplayName, forKey: "appDisplayName")
        dict.setObject(appIconName, forKey: "appIconName")
        dict.setObject(isSysApp, forKey: "isSysApp")
        
        return dict
    }
    
    class func appsFroms(items: [AnyObject]) -> [AppModel] {
        guard let apps = items as? [NSMetadataItem] else { return [] }
        
        return apps.flatMap({ AppModel(item: $0) }).sort({ $0.0.appDisplayName < $0.1.appDisplayName })
    }
    
}
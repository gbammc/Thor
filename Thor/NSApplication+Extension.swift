//
//  NSApplication+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 5/5/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

extension NSApplication {
    
    class func shortVersionString() -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return "Unknown"
        }
        
        return infoDict["CFBundleShortVersionString"] as! String
    }
    
    class func buildVersionString() -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return "?"
        }
        
        return infoDict["CFBundleVersion"] as! String
    }
    
    class func formattedVersion() -> String {
        return "Version \(shortVersionString()) (\(buildVersionString()))"
    }
    
}

extension NSApplication {
    
    // MARK: Variables
    
    var startAtLogin: Bool {
        get {
            return itemReferencesInLoginItems().thisReference != nil
        } set {
            makeLoginItem(newValue)
        }
    }
    
    private var loginItemsReference: LSSharedFileList? {
        return LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileList?
    }
    
    // MARK: Methods
    
    func toggleStartAtLogin() {
        startAtLogin = !startAtLogin
    }
    
    private func makeLoginItem(_ shouldBeLoginItem: Bool) {
        let itemReferences = itemReferencesInLoginItems()
        if let loginItemsRef = loginItemsReference {
            if shouldBeLoginItem {
                let bundleURL = Bundle.main.bundleURL as CFURL
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastItemReference, nil, nil, bundleURL, nil, nil)
            } else {
                if let itemReference = itemReferences.thisReference {
                    LSSharedFileListItemRemove(loginItemsRef, itemReference)
                }
            }
        }
    }
    
    private func itemReferencesInLoginItems() -> (thisReference: LSSharedFileListItem?, lastItemReference: LSSharedFileListItem?) {
        let bundleURL: URL = Bundle.main.bundleURL
        if let loginItemsRef = loginItemsReference {
            let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
            if loginItems.count > 0 {
                let lastItemReference: LSSharedFileListItem = loginItems.lastObject as! LSSharedFileListItem
                for currentItemReference in loginItems as! [LSSharedFileListItem] {
                    let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemReference, 0, nil)
                    if let itemURL = itemURL, bundleURL == URL(string: String(describing: itemURL.takeRetainedValue())) {
                        return (currentItemReference, lastItemReference)
                    }
                }
                return (nil, lastItemReference)
            } else {
                return (nil, kLSSharedFileListItemBeforeFirst.takeRetainedValue())
            }
        }
        return (nil, nil)
    }
    
}

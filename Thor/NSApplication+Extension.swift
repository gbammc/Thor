//
//  NSApplication+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 5/5/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

extension NSApplication {
    
    // MARK: Variables
    
    var startAtLogin: Bool {
        get {
            return itemReferencesInLoginItems().thisReference != nil
        } set {
            makeLoginItem(newValue)
        }
    }
    
    private var loginItemsReference: LSSharedFileListRef? {
        return LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil).takeRetainedValue() as LSSharedFileListRef?
    }
    
    // MARK: Methods
    
    func toggleStartAtLogin() {
        startAtLogin = !startAtLogin
    }
    
    private func makeLoginItem(shouldBeLoginItem: Bool) {
        let itemReferences = itemReferencesInLoginItems()
        if let loginItemsRef = loginItemsReference {
            if shouldBeLoginItem {
                let bundleURL: NSURL = NSBundle.mainBundle().bundleURL
                LSSharedFileListInsertItemURL(loginItemsRef, itemReferences.lastItemReference, nil, nil, bundleURL, nil, nil)
            } else {
                if let itemReference = itemReferences.thisReference {
                    LSSharedFileListItemRemove(loginItemsRef, itemReference)
                }
            }
        }
    }
    
    private func itemReferencesInLoginItems() -> (thisReference: LSSharedFileListItemRef?, lastItemReference: LSSharedFileListItemRef?) {
        let bundleURL: NSURL = NSBundle.mainBundle().bundleURL
        if let loginItemsRef = loginItemsReference {
            let loginItems: NSArray = LSSharedFileListCopySnapshot(loginItemsRef, nil).takeRetainedValue() as NSArray
            if loginItems.count > 0 {
                let lastItemReference: LSSharedFileListItemRef = loginItems.lastObject as! LSSharedFileListItemRef
                for currentItemReference in loginItems as! [LSSharedFileListItemRef] {
                    let itemURL = LSSharedFileListItemCopyResolvedURL(currentItemReference, 0, nil)
                    if itemURL != nil && bundleURL.isEqual(itemURL.takeRetainedValue()) {
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

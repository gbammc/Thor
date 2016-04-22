//
//  Constant.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

let SharedAppDelegate = NSApplication.sharedApplication().delegate as? AppDelegate
let titleItemWidth: CGFloat = 40.0
let titleItemHeight: CGFloat = 37.0

func loadDataFrom(path: String) -> AnyObject? {
    guard let data = NSData(contentsOfFile: path) else { return nil }
    
    let obj = NSKeyedUnarchiver.unarchiveObjectWithData(data)
    
    return obj
}

func save(obj: AnyObject, to path: String) -> Bool {
    return NSKeyedArchiver.archiveRootObject(obj, toFile: path)
}

let selectedAppsFile = "apps"

// identifiers
let titleViewIdentifier = "titleViewIdentifier"
let appsTitleItemIdentifier = "appsTitleItemIdentifier"
let settingsTitleItemIdentifier = "settingsTitleItemIdentifier"
let appTableCellViewIdentifier = "AppTableCellView"
let shortcutTableCellViewIdentifier = "ShortcutTableCellView"
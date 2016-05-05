//
//  Constant.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

let SharedAppDelegate        = NSApplication.sharedApplication().delegate as? AppDelegate
let titleItemWidth: CGFloat  = 40.0
let titleItemHeight: CGFloat = 37.0

// notifications
let refreshAppsListNotification     = "refreshAppsListNotification"

// identifiers
let titleViewIdentifier             = "titleViewIdentifier"
let appsTitleItemIdentifier         = "appsTitleItemIdentifier"
let settingsTitleItemIdentifier     = "settingsTitleItemIdentifier"
let appTableCellViewIdentifier      = "AppTableCellView"
let shortcutTableCellViewIdentifier = "ShortcutTableCellView"

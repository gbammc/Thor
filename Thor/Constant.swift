//
//  Constant.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

let sharedAppDelegate        = NSApplication.shared.delegate as? AppDelegate
let titleItemWidth: CGFloat  = 40.0
let titleItemHeight: CGFloat = 37.0

let launcherAppId = "me.alvinzhu.Thor.LauncherApplication"

// identifiers
let titleViewIdentifier             = NSToolbarItem.Identifier("titleViewIdentifier")
let appsTitleItemIdentifier         = NSToolbarItem.Identifier("appsTitleItemIdentifier")
let settingsTitleItemIdentifier     = NSToolbarItem.Identifier("settingsTitleItemIdentifier")
let shortcutTableCellViewIdentifier = "ShortcutTableCellView"

// Color Set
let windowbackgroundColorName = "WindowBackgroundColor"

// Notifications
extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

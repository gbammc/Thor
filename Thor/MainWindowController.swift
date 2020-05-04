//
//  MainWindowController.swift
//  Thor
//
//  Created by AlvinZhu on 4/20/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class MainWindowController: TOLWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.contentView?.layer?.masksToBounds = true

        let appItem = TitleViewItem(itemIdentifier: appsTitleItemIdentifier.rawValue)
        appItem.activeImage = NSImage(named: "AppStore-active")
        appItem.inactiveImage = NSImage(named: "AppStore")

        let settingsItem = TitleViewItem(itemIdentifier: settingsTitleItemIdentifier.rawValue)
        settingsItem.activeImage = NSImage(named: "Settings-active")
        settingsItem.inactiveImage = NSImage(named: "Settings")

        if let viewController = storyboard?.instantiateController(withIdentifier: ShortcutListViewController.className),
            let shortcutListViewController = viewController as? ShortcutListViewController {
            insert(appItem, viewController: shortcutListViewController)
        }

        if let viewController = storyboard?.instantiateController(withIdentifier: SettingsViewController.className),
            let settingsViewController = viewController as? SettingsViewController {
            insert(settingsItem, viewController: settingsViewController)
        }
    }

}

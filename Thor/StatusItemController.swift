//
//  StatusItemController.swift
//  Thor
//
//  Created by Alvin on 5/12/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import Sparkle

class StatusItemController: NSObject, NSMenuDelegate {

    // MARK: Properties
    
    var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var versionMenuItem: NSMenuItem!
    @IBOutlet weak var updateMenuItem: NSMenuItem!
    
    // MARK: NSMenuDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        versionMenuItem.title = NSApplication.formattedVersion()
    }
    
    // MARK: Actions
    
    @IBAction func showApps(_ sender: AnyObject) {
        SharedAppDelegate?.showMainWindow()
    }
    
    @IBAction func privacyPolicy(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/gbammc/Thor/blob/master/privacy.md")!)
    }
    
    @IBAction func quit(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func checkForUpdates(_ sender: AnyObject) {
        SUUpdater.shared().checkForUpdates(sender)
    }
    
    @IBAction func exportShortcuts(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.title = "Export Shortcuts To File".localized()
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "thor_shortcuts"
        savePanel.isExtensionHidden = false
        savePanel.becomeKey()
        savePanel.begin { (result) in
            guard result == .OK, let url = savePanel.url else { return }
            
            _ = AppsManager.manager.saveData(to: url.path)
        }
    }
    
    @IBAction func importShortcuts(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Import Shortcuts From File".localized()
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.becomeKey()
        openPanel.begin { (result) in
            guard result == .OK, let url = openPanel.url else { return }
            
            AppsManager.manager.loadApps(from: url.path)
        }
    }
    
    // MARK: Status bar
    
    func displayInStatusBar() {
        statusItem.image = NSImage(named: "menu-item")
        statusItem.menu = statusMenu
    }
    
}

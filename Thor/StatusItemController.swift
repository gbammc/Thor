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
    
    var statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var versionMenuItem: NSMenuItem!
    
    // MARK: Life cycle
    
    override init() {
        super.init()
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(displayInStatusBar), name: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil)
    }
    
    // MARK: NSMenuDelegate
    
    func menuWillOpen(_ menu: NSMenu) {
        versionMenuItem.title = NSApplication.formattedVersion()
    }
    
    // MARK: Actions
    
    @IBAction func showApps(_ sender: AnyObject) {
        if let rootViewController = SharedAppDelegate?.mainWindowController {
            rootViewController.showWindow(nil)
        } else {
            let rootViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: MainWindowController.classString) as! MainWindowController
            SharedAppDelegate?.mainWindowController = rootViewController
            SharedAppDelegate?.mainWindowController?.showWindow(nil)
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func quit(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func checkForUpdates(_ sender: AnyObject) {
        SUUpdater.shared().checkForUpdates(sender)
    }
    
    // MARK: Status bar
    
    func displayInStatusBar() {
        let image = NSImage(named: "menu-item")
        image?.isTemplate = true
        
        statusItem.menu = statusMenu
        statusItem.image = image
    }
    
}

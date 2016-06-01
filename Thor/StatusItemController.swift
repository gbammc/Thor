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
    
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var versionMenuItem: NSMenuItem!
    
    // MARK: Life cycle
    
    override init() {
        super.init()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displayInStatusBar), name: "AppleInterfaceThemeChangedNotification", object: nil)
    }
    
    // MARK: NSMenuDelegate
    
    func menuWillOpen(menu: NSMenu) {
        versionMenuItem.title = NSApplication.formattedVersion()
    }
    
    // MARK: Actions
    
    @IBAction func showApps(sender: AnyObject) {
        if let rootViewController = SharedAppDelegate?.mainWindowController {
            rootViewController.showWindow(nil)
        } else {
            let rootViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(MainWindowController)) as! MainWindowController
            SharedAppDelegate?.mainWindowController = rootViewController
            SharedAppDelegate?.mainWindowController?.showWindow(nil)
        }
    }
    
    @IBAction func quit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func checkForUpdates(sender: AnyObject) {
        SUUpdater.sharedUpdater().checkForUpdates(sender)
    }
    
    // MARK: Status bar
    
    func displayInStatusBar() {
        let image = NSImage(named: "menu-item")
        image?.template = true
        
        statusItem.menu = statusMenu
        statusItem.image = image
    }
    
}

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

    @IBOutlet weak var versionMenuItem: NSMenuItem!
    
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
    
    func menuWillOpen(menu: NSMenu) {
        versionMenuItem.title = NSApplication.formattedVersion()
    }
    
}

//
//  StatusItemController.swift
//  Thor
//
//  Created by Alvin on 5/12/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class StatusItemController: NSObject {

    @IBAction func showApps(sender: AnyObject) {
        if let rootViewController = SharedAppDelegate?.mainWindowController {
            rootViewController.showWindow(nil)
        } else {
            let rootViewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier(String(MainWindowController)) as! MainWindowController
            SharedAppDelegate?.mainWindowController = rootViewController
            SharedAppDelegate?.mainWindowController?.showWindow(nil)
        }
    }
    
    @IBAction func about(sender: AnyObject) {
    }
    
    @IBAction func exit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
}

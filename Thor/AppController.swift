//
//  AppController.swift
//  Thor
//
//  Created by AlvinZhu on 4/19/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class AppController: NSObject {

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

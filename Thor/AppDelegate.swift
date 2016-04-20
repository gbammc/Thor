//
//  AppDelegate.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut
import SwiftyUserDefaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var globalMonitor: AnyObject?
    var localMonitor: AnyObject?
    var mainWindowController: MainWindowController?
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    var window: NSWindow?
    lazy var statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        return statusItem
    }()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        displayInStatusBar()
        
        if Defaults[.displayStatusItem] {
            displayInStatusBar()
        }
    }
    
    func listenEvents() {
        globalMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask([.FlagsChangedMask, .KeyDownMask], handler: { (event) in
            
        })
        
        localMonitor = NSEvent.addLocalMonitorForEventsMatchingMask([.FlagsChangedMask, .KeyDownMask], handler: { (event) -> NSEvent? in
            
            return event
        })
    }
    
    func displayInStatusBar() {
        statusItem.menu = statusMenu
        statusItem.image = NSImage(named: "Settings")
        statusItem.highlightMode = true
    }
    
    func disappearFromStatusBar() {
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
    }
    
    func refreshWindow() {
        
    }

}


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

    // MARK: Properties
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    var isTapping = false
    var hasTapped = false
    var isGoingToDisableShortcut = false

    var mainWindowController: MainWindowController?
    
    var anewShortcutTimer: NSTimer?
    var delayTimer: NSTimer?
    
    var statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    // MARK: Life cycle
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Defaults.registerDefaults([
            DefaultsKeys.DeactivateKey._key : 0,
            DefaultsKeys.DelayInterval._key : 0.3,
            DefaultsKeys.EnableShortcut._key : true,
            ])
        
        NSApp.setActivationPolicy(.Accessory)
        
        shortcutEnableMonitor()
        
        displayInStatusBar()
        
        ShortcutRegister.register()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displayInStatusBar), name: "AppleInterfaceThemeChangedNotification", object: nil)
    }
    
    // MARK: Listen events
    
    private func shortcutEnableMonitor() {
        let delayInterval: NSTimeInterval        = 0.3
        let anewShortcutInterval: NSTimeInterval = Defaults[.DelayInterval]
        
        let shortcutActivateHandler = { (event: NSEvent) in
            let deactivateKey: NSEventModifierFlags = [.AlternateKeyMask, .CommandKeyMask, .ControlKeyMask, .ShiftKeyMask][Defaults[.DeactivateKey]]
            let modifier = event.modifierFlags.intersect(deactivateKey)
            
            if modifier == deactivateKey {
                if self.isGoingToDisableShortcut {
                    self.isGoingToDisableShortcut = false
                    
                    ShortcutRegister.unregister()
                    
                    self.anewShortcutTimer = NSTimer(timeInterval: anewShortcutInterval, target: self, selector: #selector(self.anewShortcutEnable), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.anewShortcutTimer!, forMode: NSRunLoopCommonModes)
                } else {
                    self.isGoingToDisableShortcut = true
                    
                    self.delayTimer = NSTimer(timeInterval: delayInterval, target: self, selector: #selector(self.checkShortcutEnable(_:)), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.delayTimer!, forMode: NSRunLoopCommonModes)
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEventsMatchingMask([.FlagsChangedMask], handler: { (event) in
            shortcutActivateHandler(event)
        })
        
        NSEvent.addLocalMonitorForEventsMatchingMask([.FlagsChangedMask], handler: { (event) -> NSEvent? in
            shortcutActivateHandler(event)
            return event
        })
    }
    
    // MARK: Status bar
    
    @objc private func displayInStatusBar() {
        let image = NSImage(named: "menu-item")
        image?.template = true
        
        statusItem.menu = statusMenu
        statusItem.image = image
    }
    
    @objc private func checkShortcutEnable(timer: NSTimer) {
        delayTimer?.invalidate()
        delayTimer = nil
        
        isGoingToDisableShortcut = false
    }
    
    @objc private func anewShortcutEnable(timer: NSTimer) {
        anewShortcutTimer?.invalidate()
        anewShortcutTimer = nil
        
        ShortcutRegister.register()
    }

}

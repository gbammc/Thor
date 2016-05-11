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
    var isGoingToDisableHotKey = false

    var mainWindowController: MainWindowController?
    
    var anewHotKeyTimer: NSTimer?
    var delayTimer: NSTimer?
    
    var statusItem: NSStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    // MARK: Life cycle
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Defaults.registerDefaults([
            DefaultsKeys.DeactivateKey._key : 0,
            DefaultsKeys.DelayInterval._key : 0.3,
            DefaultsKeys.EnableShortcut._key : true,
            ])
        
        NSApp.setActivationPolicy(.Accessory)
        
        hotKeyEnableMonitor()
        
        displayInStatusBar()
        
        HotKeysRegister.registerHotKeys()
        
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displayInStatusBar), name: "AppleInterfaceThemeChangedNotification", object: nil)
    }
    
    // MARK: Listen events
    
    private func hotKeyEnableMonitor() {
        let delayInterval: NSTimeInterval        = 0.3
        let anewShortcutInterval: NSTimeInterval = Defaults[.DelayInterval]
        
        let hotKeyActivateHandler = { (event: NSEvent) in
            let deactivateKey: NSEventModifierFlags = [.CommandKeyMask, .AlternateKeyMask, .ControlKeyMask, .ShiftKeyMask][Defaults[.DeactivateKey]]
            let modifier = event.modifierFlags.intersect(deactivateKey)
            
            if modifier == deactivateKey {
                if self.isGoingToDisableHotKey {
                    self.isGoingToDisableHotKey = false
                    
                    HotKeysRegister.unregisterHotKeys()
                    
                    self.anewHotKeyTimer = NSTimer(timeInterval: anewShortcutInterval, target: self, selector: #selector(self.anewHotKeyEnable), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.anewHotKeyTimer!, forMode: NSRunLoopCommonModes)
                } else {
                    self.isGoingToDisableHotKey = true
                    
                    self.delayTimer = NSTimer(timeInterval: delayInterval, target: self, selector: #selector(self.checkHotKeyEnable(_:)), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.delayTimer!, forMode: NSRunLoopCommonModes)
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEventsMatchingMask([.FlagsChangedMask], handler: { (event) in
            hotKeyActivateHandler(event)
        })
        
        NSEvent.addLocalMonitorForEventsMatchingMask([.FlagsChangedMask], handler: { (event) -> NSEvent? in
            hotKeyActivateHandler(event)
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
    
    @objc private func checkHotKeyEnable(timer: NSTimer) {
        delayTimer?.invalidate()
        delayTimer = nil
        
        isGoingToDisableHotKey = false
    }
    
    @objc private func anewHotKeyEnable(timer: NSTimer) {
        anewHotKeyTimer?.invalidate()
        anewHotKeyTimer = nil
        
        HotKeysRegister.registerHotKeys()
    }

}

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

    var globalMonitor: AnyObject?
    var localMonitor: AnyObject?
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
        
        hotKeyEnableMonitor()
        
        displayInStatusBar()
        
        HotKeysRegister.registerHotKeys()
    }
    
    // MARK: Listen events
    
    func hotKeyEnableMonitor() {
        let delayInterval: NSTimeInterval      = 1
        let anewShortcutInterval: NSTimeInterval = Defaults[.DelayInterval]
        
        let hotKeyActivateHandler = { (event: NSEvent) in
            let deactivateKey: NSEventModifierFlags = [.CommandKeyMask, .AlternateKeyMask, .ControlKeyMask, .ShiftKeyMask][Defaults[.DeactivateKey]]
            let modifier = event.modifierFlags.intersect(deactivateKey)

            if modifier == deactivateKey {
                if self.isGoingToDisableHotKey {
                    self.isGoingToDisableHotKey = false
                    
                    HotKeysRegister.unregisterHotKeys()
                    
                    self.anewHotKeyTimer = NSTimer(timeInterval: anewShortcutInterval, target: self, selector: #selector(AppDelegate.anewHotKeyEnable), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.anewHotKeyTimer!, forMode: NSRunLoopCommonModes)
                } else {
                    self.isGoingToDisableHotKey = true
                    
                    self.delayTimer = NSTimer(timeInterval: delayInterval, target: self, selector: #selector(AppDelegate.checkHotKeyEnable(_:)), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.delayTimer!, forMode: NSRunLoopCommonModes)
                }
            }
        }
        
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        
        globalMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask([.FlagsChangedMask, .KeyDownMask], handler: { (event) in
            hotKeyActivateHandler(event)
        })
        
        localMonitor = NSEvent.addLocalMonitorForEventsMatchingMask([.FlagsChangedMask, .KeyDownMask], handler: { (event) -> NSEvent? in
            hotKeyActivateHandler(event)
            return event
        })
    }
    
    // MARK: Status bar
    
    func displayInStatusBar() {
        statusItem.menu = statusMenu
        statusItem.image = NSImage(named: "Settings")
//        statusItem.highlightMode = true
    }
    
    func checkHotKeyEnable(timer: NSTimer) {
        delayTimer?.invalidate()
        delayTimer = nil
        
        isGoingToDisableHotKey = false
    }
    
    func anewHotKeyEnable(timer: NSTimer) {
        anewHotKeyTimer?.invalidate()
        anewHotKeyTimer = nil
        
        HotKeysRegister.registerHotKeys()
    }

}


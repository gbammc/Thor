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
    
    var isFirstActive = false
    var isTapping = false
    var hasTapped = false
    var enableHotKey = false

    var globalMonitor: AnyObject?
    var localMonitor: AnyObject?
    var mainWindowController: MainWindowController?
    var timerDelay: NSTimer?
    var timerDisableHotKey: NSTimer?
    
    lazy var window: CheatSheetWindow = {
        CheatSheetWindow()
    }()
    
    lazy var statusItem: NSStatusItem = {
        NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    }()
    
    // MARK: Life cycle
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if Defaults[.displayStatusItem] || true {
            displayInStatusBar()
        }
        
        activateCheatSheetMonitor()
        HotKeysManager.sharedManager().registerHotKeys()
    }
    
    // MARK: Listen events
    
    func activateCheatSheetMonitor() {
        let interval: NSTimeInterval                  = getDelayInterval()
        let intervalAnewHotKey: NSTimeInterval        = 1
        let intervalCheckHotKeyEnable: NSTimeInterval = 0.3
        
        let cheatSheetActivateHandler = { (event: NSEvent) in
            let flags = event.modifierFlags.intersect(.DeviceIndependentModifierFlagsMask)
            
            if flags == .ControlKeyMask && self.window.fadingOut && !self.isTapping {
                self.isTapping = true
                
                if self.hasTapped {
                    self.hasTapped = false
                    
                    self.timerDelay?.invalidate()
                    self.timerDisableHotKey?.invalidate()
                    
                    HotKeysManager.sharedManager().unregisterHotKeys()
                    
                    let timer = NSTimer(timeInterval: intervalAnewHotKey, target: self, selector: #selector(AppDelegate.anewHotKeyEnable), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                } else {
                    self.hasTapped = true
                    self.timerDisableHotKey = NSTimer(timeInterval: intervalCheckHotKeyEnable, target: self, selector: #selector(AppDelegate.checkHotKeyEnable(_:)), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.timerDisableHotKey!, forMode: NSRunLoopCommonModes)
                    
                    if !Defaults[.showCheatSheetWindow] {
                        return
                    }
                    
                    self.timerDelay = NSTimer(timeInterval: interval, target: self, selector: #selector(AppDelegate.cheatSheetWindowFadeIn(_:)), userInfo: nil, repeats: false)
                    NSRunLoop.currentRunLoop().addTimer(self.timerDelay!, forMode: NSRunLoopCommonModes)
                }
            } else {
                self.timerDelay?.invalidate()
                
                if self.isTapping {
                    self.window.fadeOut()
                }
                self.isTapping = false
            }
        }
        
        if let globalMonitor = globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
        }
        
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        
        globalMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask([.FlagsChangedMask, .KeyDownMask], handler: { (event) in
            cheatSheetActivateHandler(event)
        })
        
        localMonitor = NSEvent.addLocalMonitorForEventsMatchingMask([.FlagsChangedMask, .KeyDownMask], handler: { (event) -> NSEvent? in
            cheatSheetActivateHandler(event)
            return event
        })
    }
    
    // MARK: Status bar
    
    func displayInStatusBar() {
        statusItem.menu = statusMenu
        statusItem.image = NSImage(named: "Settings")
        statusItem.highlightMode = true
    }
    
    func disappearFromStatusBar() {
        NSStatusBar.systemStatusBar().removeStatusItem(statusItem)
    }
    
    func refreshWindow() {
        window.refresh()
    }
    
    func getDelayInterval() -> NSTimeInterval {
        return Defaults[.delayInterval] ?? 3.0
    }
    
    func cheatSheetWindowFadeIn(timer: NSTimer) {
        timer.invalidate()
        
        if isTapping {
            window.fadeIn()
        }
    }
    
    func checkHotKeyEnable(timer: NSTimer) {
        timer.invalidate()
        
        hasTapped = false
    }
    
    func anewHotKeyEnable(timer: NSTimer) {
        timer.invalidate()
        
        HotKeysManager.sharedManager().registerHotKeys()
        enableHotKey = true
    }

}


//
//  AppDelegate.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: Properties
    
    var hasLaunched = false
    var isGoingToDisableShortcut = false
    
    var anewShortcutTimer: Timer?
    var delayTimer: Timer?
    
    var mainWindowController: MainWindowController?
    
    @IBOutlet weak var statusItemController: StatusItemController!
    
    // MARK: Life cycle
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Defaults.register(defaults: [
            DefaultsKeys.DeactivateKey._key : 0,
            DefaultsKeys.DelayInterval._key : 0.3,
            DefaultsKeys.EnableShortcut._key : true,
            ])
        
        NSApp.setActivationPolicy(.accessory)
        
        statusItemController.displayInStatusBar()
        
        shortcutEnableMonitor()
        
        MASShortcutValidator.shared().allowAnyShortcutWithOptionModifier = true
        ShortcutMonitor.register()
        
        if AppsManager.manager.selectedApps.count == 0 {
            showMainWindow()
        }
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        if hasLaunched {
            showMainWindow()
        } else {
            hasLaunched = true
        }
    }
    
    func showMainWindow() {
        if let rootViewController = mainWindowController {
            rootViewController.showWindow(nil)
        } else {
            let rootViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: MainWindowController.classString) as! MainWindowController
            mainWindowController = rootViewController
            mainWindowController?.showWindow(nil)
        }
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    // MARK: Listen events
    
    private func shortcutEnableMonitor() {
        let delayInterval: TimeInterval        = 0.3
        let anewShortcutInterval: TimeInterval = Defaults[.DelayInterval]
        
        let shortcutActivateHandler = { (event: NSEvent) in
            let deactivateKey: NSEvent.ModifierFlags = [.option, .command, .control, .shift][Defaults[.DeactivateKey]]
            let modifier = event.modifierFlags.intersection(deactivateKey)
            
            if modifier == deactivateKey && Defaults[.EnableDeactivateKey] {
                if self.isGoingToDisableShortcut {
                    self.isGoingToDisableShortcut = false
                    
                    ShortcutMonitor.unregister()
                    
                    self.anewShortcutTimer = Timer(timeInterval: anewShortcutInterval, target: self, selector: #selector(self.anewShortcutEnable), userInfo: nil, repeats: false)
                    RunLoop.current.add(self.anewShortcutTimer!, forMode: RunLoop.Mode.common)
                } else {
                    self.isGoingToDisableShortcut = true
                    
                    self.delayTimer = Timer(timeInterval: delayInterval, target: self, selector: #selector(self.checkShortcutEnable(_:)), userInfo: nil, repeats: false)
                    RunLoop.current.add(self.delayTimer!, forMode: RunLoop.Mode.common)
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.flagsChanged], handler: { (event) in
            shortcutActivateHandler(event)
        })
        
        NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged], handler: { (event) -> NSEvent? in
            shortcutActivateHandler(event)
            return event
        })
    }
    
    @objc private func checkShortcutEnable(_ timer: Timer) {
        delayTimer?.invalidate()
        delayTimer = nil
        
        isGoingToDisableShortcut = false
    }
    
    @objc private func anewShortcutEnable(_ timer: Timer) {
        anewShortcutTimer?.invalidate()
        anewShortcutTimer = nil
        
        ShortcutMonitor.register()
    }

}

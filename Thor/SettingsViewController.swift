//
//  SettingsViewController.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

class SettingsViewController: NSViewController {
    
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var btnLaunchAtLogin: NSButton!
    @IBOutlet weak var btnEnableShortcut: NSButton!
    @IBOutlet weak var btnShortcutDeavtivateKey: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        btnLaunchAtLogin.state = NSApplication.sharedApplication().startAtLogin ? NSOnState : NSOffState
        
        btnEnableShortcut.state = Defaults[.EnableShortcut] ? NSOnState : NSOffState
        
        btnShortcutDeavtivateKey.selectItemAtIndex(Defaults[.DeactivateKey])
        
        slider.doubleValue = Defaults[.DelayInterval]
    }
   
    @IBAction func toggleLaunchAtLogin(sender: AnyObject) {
        NSApplication.sharedApplication().toggleStartAtLogin()
    }
    
    @IBAction func toggleEnableShortcut(sender: AnyObject) {
        let enable = btnEnableShortcut.state == NSOnState
        
        Defaults[.EnableShortcut] = enable
        
        enable ? ShortcutMonitor.register() : ShortcutMonitor.unregister()
    }
    
    @IBAction func changeDeactivateKey(sender: AnyObject) {
        Defaults[.DeactivateKey] = btnShortcutDeavtivateKey.indexOfSelectedItem
    }
    
    @IBAction func changeShortcutReactivateInterval(sender: AnyObject) {
        Defaults[.DelayInterval] = slider.doubleValue
    }
    
    @IBAction func exit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
}

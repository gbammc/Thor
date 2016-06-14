//
//  SettingsViewController.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var btnLaunchAtLogin: NSButton!
    @IBOutlet weak var btnEnableShortcut: NSButton!
    @IBOutlet weak var btnShortcutDeavtivateKey: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.white().cgColor
        
        btnLaunchAtLogin.state = NSApplication.shared().startAtLogin ? NSOnState : NSOffState
        
        btnEnableShortcut.state = Defaults[.EnableShortcut] ? NSOnState : NSOffState
        
        btnShortcutDeavtivateKey.selectItem(at: Defaults[.DeactivateKey])
        
        slider.doubleValue = Defaults[.DelayInterval]
    }
   
    @IBAction func toggleLaunchAtLogin(_ sender: AnyObject) {
        NSApplication.shared().toggleStartAtLogin()
    }
    
    @IBAction func toggleEnableShortcut(_ sender: AnyObject) {
        let enable = btnEnableShortcut.state == NSOnState
        
        Defaults[.EnableShortcut] = enable
        
        enable ? ShortcutMonitor.register() : ShortcutMonitor.unregister()
    }
    
    @IBAction func changeDeactivateKey(_ sender: AnyObject) {
        Defaults[.DeactivateKey] = btnShortcutDeavtivateKey.indexOfSelectedItem
    }
    
    @IBAction func changeShortcutReactivateInterval(_ sender: AnyObject) {
        Defaults[.DelayInterval] = slider.doubleValue
    }
    
    @IBAction func exit(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
}

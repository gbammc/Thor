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
    @IBOutlet weak var btnShortcutDeactivateKey: NSPopUpButton!
    @IBOutlet weak var btnEnableDeactivateKey: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.clear.cgColor
        
        btnLaunchAtLogin.state = NSApplication.shared.startAtLogin ? .on : .off
        
        btnEnableShortcut.state = Defaults[.EnableShortcut] ? .on : .off
        
        btnShortcutDeactivateKey.selectItem(at: Defaults[.DeactivateKey])
        
        btnEnableDeactivateKey.state = Defaults[.EnableDeactivateKey] ? .on : .off
        
        slider.doubleValue = Defaults[.DelayInterval]
    }
   
    @IBAction func toggleLaunchAtLogin(_ sender: Any) {
        NSApplication.shared.toggleStartAtLogin()
    }
    
    @IBAction func toggleEnableShortcut(_ sender: Any) {
        let enable = btnEnableShortcut.state == .on
        
        Defaults[.EnableShortcut] = enable
        
        enable ? ShortcutMonitor.register() : ShortcutMonitor.unregister()
    }
    
    @IBAction func changeDeactivateKey(_ sender: Any) {
        Defaults[.DeactivateKey] = btnShortcutDeactivateKey.indexOfSelectedItem
    }
    
    @IBAction func toggleEnableDeactivateKey(_ sender: Any) {
        Defaults[.EnableDeactivateKey] = btnEnableDeactivateKey.state == .on
    }
    
    @IBAction func changeShortcutReactivateInterval(_ sender: Any) {
        Defaults[.DelayInterval] = slider.doubleValue
    }
    
    @IBAction func exit(_ sender: Any) {
        NSApp.terminate(self)
    }
    
}

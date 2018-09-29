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
        
        if #available(OSX 10.13, *) {
            view.layer?.backgroundColor = NSColor(named: windowbackgroundColorName)?.cgColor
        } else {
            view.layer?.backgroundColor = NSColor.white.cgColor
        }
        
        btnLaunchAtLogin.state = NSApplication.shared.startAtLogin ? .on : .off
        
        btnEnableShortcut.state = Defaults[.EnableShortcut] ? .on : .off
        
        btnShortcutDeavtivateKey.selectItem(at: Defaults[.DeactivateKey])
        
        slider.doubleValue = Defaults[.DelayInterval]
    }
   
    @IBAction func toggleLaunchAtLogin(_ sender: AnyObject) {
        NSApplication.shared.toggleStartAtLogin()
    }
    
    @IBAction func toggleEnableShortcut(_ sender: AnyObject) {
        let enable = btnEnableShortcut.state == .on
        
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

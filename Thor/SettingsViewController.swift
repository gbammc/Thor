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
    @IBOutlet weak var btnShowCheatSheet: NSButton!
    @IBOutlet weak var btnCheatSheetAvtivateHotKey: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        let manager = LoginItemsManager()
        btnLaunchAtLogin.state = manager.startAtLogin ? NSOnState : NSOffState
        
        btnEnableShortcut.state = Defaults[.enableShortcut] ? NSOnState : NSOffState
        
        toggleCheatSheet(Defaults[.showCheatSheet])
        
        slider.doubleValue = Defaults[.delayInterval]
    }
   
    @IBAction func toggleLaunchAtLogin(sender: AnyObject) {
        let manager = LoginItemsManager()
        manager.toggleStartAtLogin()
    }
    
    @IBAction func toggleEnableShortcut(sender: AnyObject) {
        Defaults[.enableShortcut] = btnEnableShortcut.state == NSOnState
    }
    
    @IBAction func toggleShowCheatSheet(sender: AnyObject) {
        toggleCheatSheet(btnShowCheatSheet.state == NSOnState)
    }
    
    @IBAction func changeCheatSheetActivateInterval(sender: AnyObject) {
        Defaults[.delayInterval] = slider.doubleValue
    }
    
    @IBAction func exit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    private func toggleCheatSheet(isOn: Bool) {
        Defaults[.showCheatSheet] = isOn
        
        btnShowCheatSheet.state = isOn ? NSOnState : NSOffState
        slider.enabled = isOn
        btnCheatSheetAvtivateHotKey.enabled = isOn
    }
    
}

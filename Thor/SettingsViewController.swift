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
    @IBOutlet weak var btnShowCheatSheet: NSButton!
    @IBOutlet weak var btnCheatSheetAvtivateHotKey: NSPopUpButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        let manager = LoginItemsManager()
        btnLaunchAtLogin.state = manager.startAtLogin ? NSOnState : NSOffState
        
        toggleCheatSheet(Defaults[.showCheatSheet])
        
        slider.doubleValue = Defaults[.delayInterval]
    }
   
    @IBAction func toggleLaunchAtLogin(sender: NSButton) {
        let manager = LoginItemsManager()
        manager.toggleStartAtLogin()
    }
    
    @IBAction func toggleShowCheatSheet(sender: NSButton) {
        toggleCheatSheet(sender.state == NSOnState)
    }
    
    @IBAction func changeCheatSheetActivateInterval(sender: NSSlider) {
        Defaults[.delayInterval] = sender.doubleValue
    }
    
    @IBAction func exit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    private func toggleCheatSheet(isOn: Bool) {
        Defaults[.showCheatSheet] = isOn
        slider.enabled = isOn
        btnCheatSheetAvtivateHotKey.enabled = isOn
    }
    
}

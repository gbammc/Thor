//
//  AddAppViewController.swift
//  Thor
//
//  Created by AlvinZhu on 4/21/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class AddAppViewController: NSViewController {

    @IBOutlet weak var btnApps: NSPopUpButton!
    @IBOutlet weak var shortcutView: MASShortcutView!
    
    var apps: [AppModel]?
    var selectedApp: AppModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        AppsManager.manager.getApps {
            self.apps = $0
            self.resetSelections($0)
        }
    }
    
    func resetSelections(apps: [AppModel]) {
        let menu = NSMenu()
        var selectedIndex = 0
        
        for (idx, app) in apps.enumerate() {
            if app.appName == selectedApp?.appName {
                selectedIndex = idx
                shortcutView.shortcutValue = selectedApp?.shortcut
            }
            
            let item = NSMenuItem()
            item.title = app.appDisplayName
            item.image = app.icon
            
            menu.addItem(item)
        }
        
        btnApps.removeAllItems()
        btnApps.menu = menu
        btnApps.selectItemAtIndex(selectedIndex)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        view.window?.close()
        NSApp.stopModal()
    }

    @IBAction func selectApps(sender: AnyObject) {
        
    }
    
    @IBAction func save(sender: AnyObject) {
        if shortcutView.shortcutValue != nil {
            let idx = btnApps.indexOfSelectedItem
            let app = apps![idx]
            app.shortcut = shortcutView.shortcutValue
            
            AppsManager.manager.selectedApps.append(app)
            AppsManager.manager.saveData()
            
            NSNotificationCenter.defaultCenter().postNotificationName(refreshAppsListNotification, object: nil)
        }
        
        view.window?.close()
        NSApp.stopModal()
    }
    
}

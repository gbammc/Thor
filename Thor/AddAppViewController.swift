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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppsManager.manager.getApps {
            self.apps = $0
            self.resetSelections($0)
        }
        
        shortcutView.shortcutValueChange = { (view) in
            NSLog("\(view.shortcutValue)")
        }
    }
    
    func resetSelections(apps: [AppModel]) {
        let menu = NSMenu()
        // apps menuitem
        
        apps.forEach {
            let item = NSMenuItem()
            item.title = $0.appDisplayName
            item.image = $0.icon
            
            menu.addItem(item)
        }
        
        btnApps.removeAllItems()
        btnApps.menu = menu
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
        }
        
        view.window?.close()
        NSApp.stopModal()
    }
    
}

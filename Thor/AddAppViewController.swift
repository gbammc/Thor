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
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        view.window?.close()
        NSApp.stopModal()
    }
    
    func resetSelections(apps: [AppModel]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            let menu = NSMenu()
            var selectedIndex = 0
            
            for (idx, app) in apps.enumerate() {
                if app.appName == self.selectedApp?.appName {
                    selectedIndex = idx
                    self.shortcutView.shortcutValue = self.selectedApp?.shortcut
                }
                
                let item = NSMenuItem()
                item.title = app.appDisplayName
                item.image = app.icon
                
                menu.addItem(item)
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.btnApps.removeAllItems()
                self.btnApps.menu = menu
                self.btnApps.selectItemAtIndex(selectedIndex)
            })
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        if shortcutView.shortcutValue != nil {
            let idx = btnApps.indexOfSelectedItem
            let app = apps![idx]
            app.shortcut = shortcutView.shortcutValue
            
            if let selectedApp = selectedApp {
                for app in AppsManager.manager.selectedApps where app.appName == selectedApp.appName {
                    app.shortcut = shortcutView.shortcutValue
                }
            } else {
                AppsManager.manager.selectedApps.append(app)
            }
            
            AppsManager.manager.saveData()
            
            NSNotificationCenter.defaultCenter().postNotificationName(refreshAppsListNotification, object: nil)
        }
        
        view.window?.close()
        NSApp.stopModal()
    }
    
}

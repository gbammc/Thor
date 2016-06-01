//
//  ShortcutListViewController.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class ShortcutListViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    var apps: [AppModel] { get { return AppsManager.manager.selectedApps } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    
    @IBAction func add(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = [kUTTypeApplicationFile as String, kUTTypeApplicationBundle as String]
        
        openPanel.beginSheetModalForWindow(view.window!, completionHandler: { (result) in
            if result == NSModalResponseOK, let metaDataItem = NSMetadataItem(URL: openPanel.URLs.first!) {
                let app = AppModel(item: metaDataItem)
                
                AppsManager.manager.save(app, shortcut: nil)
                
                self.tableView.reloadData()
                self.tableView.scrollRowToVisible(self.apps.count - 1)
            }
        })
    }
    
    @IBAction func remove(sender: AnyObject) {
        guard tableView.selectedRow != -1 else { return }
        
        let alert = NSAlert()
        alert.addButtonWithTitle("Sure".localized())
        alert.addButtonWithTitle("Cancel".localized())
        alert.messageText = "Delete this shortcut?".localized()
        alert.alertStyle = .WarningAlertStyle
        
        if alert.runModal() == NSAlertFirstButtonReturn {
            AppsManager.manager.delete(tableView.selectedRow)
            
            tableView.reloadData()
        }
    }

}

extension ShortcutListViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return apps.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return apps[row]
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let app = apps[row]
        let cell = tableView.makeViewWithIdentifier(shortcutTableCellViewIdentifier, owner: self) as! ShortcutTableCellView
        cell.configure(app.appDisplayName, icon: app.icon, shortcut: app.shortcut) { (shortcut) in
            AppsManager.manager.save(app, shortcut: shortcut)
        }
        
        return cell
    }
    
}

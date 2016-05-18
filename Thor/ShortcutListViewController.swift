//
//  ShortcutListViewController.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class ShortcutListViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    lazy var editShortcutWindowController = SharedAppDelegate?.mainWindowController?.storyboard?.instantiateControllerWithIdentifier(String(EditShortcutWindowController)) as! EditShortcutWindowController
    
    var apps: [AppModel] { get { return AppsManager.manager.selectedApps } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        tableView.doubleAction = #selector(editShortcut)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSNotificationCenter.defaultCenter().addObserver(tableView, selector: #selector(NSTableView.reloadData), name: refreshAppsListNotification, object: nil)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        NSNotificationCenter.defaultCenter().removeObserver(tableView, name: refreshAppsListNotification, object: nil)
    }
    
    @IBAction func add(sender: AnyObject) {
        NSApplication.sharedApplication().runModalForWindow(editShortcutWindowController.window!)
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
    
    @objc private func editShortcut() {
        let editShortcutViewController = editShortcutWindowController.contentViewController as! EditShortcutViewController
        
        let app = AppsManager.manager.selectedApps[tableView.selectedRow]
        editShortcutViewController.editedApp = app
        
        NSApp.runModalForWindow(editShortcutWindowController.window!)
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
        if tableColumn?.identifier == appTableCellViewIdentifier {
            let cell = tableView.makeViewWithIdentifier(appTableCellViewIdentifier, owner: self) as! NSTableCellView
            cell.textField?.stringValue = app.appDisplayName
            cell.imageView?.image = app.icon
            
            return cell
        } else {
            let cell = tableView.makeViewWithIdentifier(shortcutTableCellViewIdentifier, owner: self) as! NSTableCellView
            cell.textField?.stringValue = "\(app.shortcut!)"
            
            return cell
        }
    }
    
}

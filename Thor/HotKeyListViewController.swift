//
//  HotKeyListViewController.swift
//  Thor
//
//  Created by Alvin on 5/12/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class HotKeyListViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    lazy var editHotKeyWindowController: EditHotKeyWindowController = SharedAppDelegate?.mainWindowController?.storyboard?.instantiateControllerWithIdentifier(String(EditHotKeyWindowController)) as! EditHotKeyWindowController
    
    var apps: [AppModel] { get { return AppsManager.manager.selectedApps } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        tableView.doubleAction = #selector(editHotKey)
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
        NSApplication.sharedApplication().runModalForWindow(editHotKeyWindowController.window!)
    }
    
    @IBAction func remove(sender: AnyObject) {
        let alert = NSAlert()
        alert.addButtonWithTitle("Sure".localized())
        alert.addButtonWithTitle("Cancel".localized())
        alert.messageText = "Delete this hotkey?".localized()
        alert.alertStyle = .WarningAlertStyle
        
        if alert.runModal() == NSAlertFirstButtonReturn {
            AppsManager.manager.delete(tableView.selectedRow)
            
            tableView.reloadData()
        }
    }
    
    @objc private func editHotKey() {
        let editHotKeyViewController = editHotKeyWindowController.contentViewController as! EditHotKeyViewController
        
        let app = AppsManager.manager.selectedApps[tableView.selectedRow]
        editHotKeyViewController.editedApp = app
        
//        NSApp.runModalForWindow(editHotKeyWindowController.window!)
        
        view.window!.beginSheet(editHotKeyWindowController.window!) { (response) in
            
        }
    
//        NSApp.beginSheet(editHotKeyWindowController.window!, modalForWindow: view.window!, modalDelegate: nil, didEndSelector: nil, contextInfo: nil)
    }
}

extension HotKeyListViewController: NSTableViewDataSource, NSTableViewDelegate {
    
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
            let cell = tableView.makeViewWithIdentifier(hotKeyTableCellViewIdentifier, owner: self) as! NSTableCellView
            cell.textField?.stringValue = "\(app.shortcut!)"
            
            return cell
        }
    }
    
}

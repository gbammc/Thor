//
//  AppsViewController.swift
//  Thor
//
//  Created by AlvinZhu on 4/19/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class AppsViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    lazy var addAppWindowController: AddAppWindowController = SharedAppDelegate?.mainWindowController?.storyboard?.instantiateControllerWithIdentifier(String(AddAppWindowController)) as! AddAppWindowController
    
    var apps: [AppModel] { get { return AppsManager.manager.selectedApps } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        tableView.doubleAction = #selector(AppsViewController.editShortcut)
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
        NSApplication.sharedApplication().runModalForWindow(addAppWindowController.window!)
    }
    
    func editShortcut() {
        let addAppViewController = addAppWindowController.contentViewController as! AddAppViewController
        
        let app = AppsManager.manager.selectedApps[tableView.selectedRow]
        addAppViewController.selectedApp = app
        
        NSApplication.sharedApplication().runModalForWindow(addAppWindowController.window!)
    }
    
    @IBAction func remove(sender: AnyObject) {
        let alert = NSAlert()
        alert.addButtonWithTitle("OK".localized())
        alert.addButtonWithTitle("Cancel".localized())
        alert.messageText = "Delete the shortcut?".localized()
        alert.alertStyle = .WarningAlertStyle
        
        if alert.runModal() == NSAlertFirstButtonReturn {
            AppsManager.manager.selectedApps.removeAtIndex(tableView.selectedRow)
            AppsManager.manager.saveData()
            
            tableView.reloadData()
        }
    }
}

extension AppsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
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

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
    
    lazy var addAppWindowController: AddAppWindowController = {
        let addAppWindowController =  SharedAppDelegate?.mainWindowController?.storyboard?.instantiateControllerWithIdentifier(String(AddAppWindowController)) as! AddAppWindowController
        
        return addAppWindowController
    }()
    
    var apps = AppsManager.manager.selectedApps
//    var apps = ["", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    
    @IBAction func add(sender: AnyObject) {
        let window = addAppWindowController.window!
        
        let xPos = (NSWidth(window.screen!.frame) - NSWidth(window.frame)) / 2
        let yPos = (NSHeight(window.screen!.frame) - NSHeight(window.frame))
        window.setFrame(NSRect(x: xPos, y: yPos, width: NSWidth(window.frame), height: NSHeight(window.frame)), display: false)
        
        NSApplication.sharedApplication().runModalForWindow(window)
    }
    
    @IBAction func remove(sender: AnyObject) {
        
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
        if tableColumn?.identifier == appTableCellViewIdentifier {
            let cell = tableView.makeViewWithIdentifier(appTableCellViewIdentifier, owner: self)
            
            return cell
        } else {
            let cell = tableView.makeViewWithIdentifier(shortcutTableCellViewIdentifier, owner: self)
            
            return cell
        }
    }
    
}
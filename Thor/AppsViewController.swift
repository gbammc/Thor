//
//  AppsViewController.swift
//  Thor
//
//  Created by AlvinZhu on 4/19/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class AppsViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnAdd: NSButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer?.backgroundColor = NSColor.whiteColor().CGColor
    }
    
}

//
//  EditHotKeyWindowController.swift
//  Thor
//
//  Created by Alvin on 5/12/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class EditHotKeyWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .Hidden
        window?.backgroundColor = NSColor.whiteColor()
        window?.center()
    }

}

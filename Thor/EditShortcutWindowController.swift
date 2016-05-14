//
//  EditShortcutWindowController.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class EditShortcutWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .Hidden
        window?.backgroundColor = NSColor.whiteColor()
    }

}

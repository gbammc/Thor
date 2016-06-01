//
//  ShortcutTableCellView.swift
//  Thor
//
//  Created by hebao on 6/1/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class ShortcutTableCellView: NSTableCellView {
    
    @IBOutlet weak var shortcutView: MASShortcutView!
    
    func configure(name: String, icon: NSImage?, shortcut: MASShortcut?, shortcutValueChange: (MASShortcut?) -> ()) {
        textField?.stringValue = name
        imageView?.image = icon
        
        shortcutView.shortcutValueChange = nil
        shortcutView.shortcutValue = shortcut
        shortcutView.shortcutValueChange = { sender in
            shortcutValueChange(sender.shortcutValue)
        }
    }
    
}

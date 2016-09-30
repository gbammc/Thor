//
//  ShortcutTableCellView.swift
//  Thor
//
//  Created by Alvin on 6/1/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import MASShortcut

class ShortcutTableCellView: NSTableCellView {
    
    @IBOutlet weak var shortcutView: MASShortcutView!
    
    func configure(_ name: String, icon: NSImage?, shortcut: MASShortcut?, shortcutValueChange: @escaping (MASShortcut?) -> ()) {
        textField?.stringValue = name
        imageView?.image = icon
        
        shortcutView.shortcutValueChange = nil
        shortcutView.shortcutValue = shortcut
        shortcutView.shortcutValueChange = { sender in
            shortcutValueChange(sender?.shortcutValue)
        }
    }
    
}

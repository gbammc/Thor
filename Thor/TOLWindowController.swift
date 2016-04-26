//
//  TOLWindowController.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class TOLWindowController: NSWindowController {
    
    var identifiers = [String]()
    var views = [String: NSView]()
    var items = [String: NSToolbarItem]()
    var titleView = TitleView()
    var viewControllers = [String: NSViewController]()

    override func windowDidLoad() {
        super.windowDidLoad()
                
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .Hidden
        window?.backgroundColor = NSColor.whiteColor()
        
        guard window?.toolbar == nil else { return }
        
        let toolbar = NSToolbar(identifier: "toolbar")
        toolbar.delegate = self
        toolbar.showsBaselineSeparator = false
        
        window?.toolbar = toolbar
        
        // title
        
        titleView.toggleCallback = toggleViewControllers
        
        let titleItem = NSToolbarItem(itemIdentifier: titleViewIdentifier)
        titleItem.view = titleView
        
        identifiers.append(titleViewIdentifier)
        items[titleViewIdentifier] = titleItem
        toolbar.insertItemWithItemIdentifier(titleViewIdentifier, atIndex: 0)
        
        // space
        
        let spaceItem = NSToolbarItem(itemIdentifier: NSToolbarFlexibleSpaceItemIdentifier)
        
        identifiers.append(NSToolbarFlexibleSpaceItemIdentifier)
        items[NSToolbarFlexibleSpaceItemIdentifier] = spaceItem
        toolbar.insertItemWithItemIdentifier(NSToolbarFlexibleSpaceItemIdentifier, atIndex: 0)
    }
    
    override func showWindow(sender: AnyObject?) {
        super.showWindow(sender)
        
        NSApp.activateIgnoringOtherApps(true)
    }
    
    override func keyDown(theEvent: NSEvent) {
        let key = theEvent.charactersIgnoringModifiers
        if theEvent.modifierFlags.contains(.CommandKeyMask) && key == "w" {
            close()
        } else {
            super.keyDown(theEvent)
        }
    }
    
    func insert(titleItem: TitleViewItem, viewController: NSViewController) {
        titleView.insert(titleItem)
        viewControllers[titleItem.identifier!] = viewController
        items[titleViewIdentifier]?.minSize = NSSize(width: titleItemWidth * CGFloat(titleView.items.count), height: titleItemHeight)
        
        titleView.toggle(titleView.items.first!)
    }
    
    func toggleViewControllers(item: TitleViewItem) {
        contentViewController = viewControllers[item.identifier!]
    }
    
}

extension TOLWindowController: NSToolbarDelegate {
    
    func toolbarDefaultItemIdentifiers(toolbar: NSToolbar) -> [String] {
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(toolbar: NSToolbar) -> [String] {
        return identifiers
    }
    
    func toolbar(toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {        
        return items[itemIdentifier]
    }
    
}

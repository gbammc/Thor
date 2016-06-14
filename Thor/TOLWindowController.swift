//
//  TOLWindowController.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

class TOLWindowController: NSWindowController {
    
    var titleView       = TitleView()
    var identifiers     = [String]()
    var items           = [String: NSToolbarItem]()
    var viewControllers = [String: NSViewController]()

    override func windowDidLoad() {
        super.windowDidLoad()
                
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.backgroundColor = NSColor.white()
        
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
        toolbar.insertItem(withItemIdentifier: titleViewIdentifier, at: 0)
        
        // space
        
        let spaceItem = NSToolbarItem(itemIdentifier: NSToolbarFlexibleSpaceItemIdentifier)
        
        identifiers.append(NSToolbarFlexibleSpaceItemIdentifier)
        items[NSToolbarFlexibleSpaceItemIdentifier] = spaceItem
        toolbar.insertItem(withItemIdentifier: NSToolbarFlexibleSpaceItemIdentifier, at: 0)
    }
    
    override func showWindow(_ sender: AnyObject?) {
        super.showWindow(sender)
        
        NSApp.activateIgnoringOtherApps(true)
    }
    
    override func keyDown(_ theEvent: NSEvent) {
        let key = theEvent.charactersIgnoringModifiers
        if theEvent.modifierFlags.contains(.command) && key == "w" {
            close()
        } else {
            super.keyDown(theEvent)
        }
    }
    
    func insert(_ titleItem: TitleViewItem, viewController: NSViewController) {
        titleView.insert(titleItem)
        viewControllers[titleItem.identifier!] = viewController
        items[titleViewIdentifier]?.minSize = NSSize(width: titleItemWidth * CGFloat(titleView.items.count), height: titleItemHeight)
        
        titleView.toggle(titleView.items.first!)
    }
    
    private func toggleViewControllers(_ item: TitleViewItem) {
        if contentViewController?.childViewControllers.count > 0 {
            contentViewController?.view.subviews.forEach { $0.removeFromSuperview() }
            contentViewController?.childViewControllers.forEach { $0.removeFromParentViewController() }
        }
        
        if let viewController = viewControllers[item.identifier!] {
            contentViewController?.insertChildViewController(viewController, at: 0)
            contentViewController?.view.addSubview(viewController.view)
            contentViewController?.view.frame = viewController.view.frame
        }
    }
    
}

extension TOLWindowController: NSToolbarDelegate {
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [String] {
        return identifiers
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: String, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {        
        return items[itemIdentifier]
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class TitleView: NSView {
    
    var items = [TitleViewItem]()
    var toggleCallback: ((item: TitleViewItem) -> ())?
    
    func insert(_ item: TitleViewItem) {
        items.append(item)
        items.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerated() {
            item.frame = NSRect(x: CGFloat(index) * titleItemWidth, y: 0, width: titleItemWidth, height: self.frame.size.height)
            item.target = self
            item.action = #selector(TitleView.toggle(_:))
            
            addSubview(item)
        }
    }
    
    func toggle(_ sender: TitleViewItem) {
        items.forEach { $0.state = ($0 != sender) ? NSOnState : NSOffState }
        
        toggleCallback?(item: sender)
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class TitleViewItem: NSButton {
    
    var activeImage: NSImage? {
        get { return image }
        set { image = newValue }
    }
    
    var inactiveImage: NSImage? {
        get { return alternateImage }
        set { alternateImage = newValue }
    }
    
    init(itemIdentifier: String) {
        super.init(frame: NSRect.zero)
        
        identifier = itemIdentifier
        isBordered = false
        setButtonType(.toggleButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

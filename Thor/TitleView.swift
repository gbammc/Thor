//
//  TitleView.swift
//  Thor
//
//  Created by AlvinZhu on 4/19/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

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
        bordered = false
        setButtonType(.ToggleButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TitleView: NSView {
    
    var items = [TitleViewItem]()
    var toggleCallback: ((item: TitleViewItem) -> ())?
    
    func insert(item: TitleViewItem) {
        items.append(item)
        
        items.forEach { $0.removeFromSuperview() }
        
        for (index, item) in items.enumerate() {
            item.frame = NSRect(x: CGFloat(index) * titleItemWidth, y: 0, width: titleItemWidth, height: self.height)
            item.target = self
            item.action = #selector(TitleView.toggle(_:))
            
            addSubview(item)
        }
    }
    
    func toggle(sender: TitleViewItem) {
        items.forEach { $0.state = ($0 != sender) ? NSOnState : NSOffState }
        
        toggleCallback?(item: sender)
    }
}

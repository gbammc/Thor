//
//  TitleView.swift
//  Thor
//
//  Created by AlvinZhu on 4/19/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import SnapKit

protocol TitleViewDelegate {
//    func titleView(titleView: TitleView, didSelectItem)
}

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
            addSubview(item)
            
            item.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(CGFloat(index) * titleItemWidth)
                make.width.equalTo(titleItemWidth)
                make.top.bottom.equalTo(self)
            })
            
            item.target = self
            item.action = #selector(TitleView.toggle(_:))
        }
    }
    
    func toggle(sender: TitleViewItem) {
        items.forEach { $0.state = ($0 != sender) ? NSOnState : NSOffState }
        
        toggleCallback?(item: sender)
    }
}

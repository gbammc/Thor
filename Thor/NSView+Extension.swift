//
//  NSView+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

extension NSView {
    
    var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }
    
    var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }
    
    var right: CGFloat {
        get { return frame.origin.x + frame.size.width }
        set { frame.origin.x = newValue - frame.size.width }
    }
    
    var bottom: CGFloat {
        get { return frame.origin.y + frame.size.height }
        set { frame.origin.y = newValue - frame.size.height }
    }
    
    var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }
    
    var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }
    
    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }
    
    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }
    
    var centerX: CGFloat {
        get { return NSMidX(self.frame) }
        set { frame.origin.x = newValue - (self.frame.size.width * 0.5) }
    }
    
    var centerY: CGFloat {
        get { return NSMidY(self.frame) }
        set { frame.origin.y = newValue - (self.frame.size.height * 0.5) }
    }
    
}

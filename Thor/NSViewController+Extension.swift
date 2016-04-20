//
//  NSViewController+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 4/19/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa

extension NSViewController {
    
    var mainWindonController: MainWindowController? {
        get {
            return storyboard?.instantiateControllerWithIdentifier(String(MainWindowController)) as? MainWindowController
        }
    }
    
}
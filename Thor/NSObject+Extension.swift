//
//  NSObject+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 9/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

extension NSObject {
    
    static var classString: String {
        get {
            return String(describing: self)
        }
    }
    
}

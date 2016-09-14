//
//  String+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 4/29/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

extension String {
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
}

extension NSObject {
    
    static var name: String {
        get {
            return String(describing: self)
        }
    }
    
}

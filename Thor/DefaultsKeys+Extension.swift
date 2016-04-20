//
//  DefaultsKeys+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    
    static let hotKey = DefaultsKey<[NSData]?>("hotKey")
    static let modifyKey = DefaultsKey<Int?>("modifyKey")
    static let delayInterval = DefaultsKey<Double?>("delayInterval")
    static let displayStatusItem = DefaultsKey<Bool>("displayStatusItem")
    
}

//
//  Defaults.swift
//  Thor
//
//  Created by Alvin on 6/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

let Defaults = UserDefaults.standard

extension UserDefaults {
    
    subscript(key: DefaultsKey<String>) -> String {
        get { return string(forKey: key._key) ?? "" }
        set { set(newValue, forKey: key._key) }
    }
    
    subscript(key: DefaultsKey<Int>) -> Int {
        get { return integer(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    
    subscript(key: DefaultsKey<Double>) -> Double {
        get { return double(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    
    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return bool(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    
    subscript(key: DefaultsKey<Array<Any>?>) -> Array<Any>? {
        get { return array(forKey: key._key) }
        set { set(newValue, forKey: key._key) }
    }
    
}

class DefaultsKeys {
    init() {}
}

class DefaultsKey<ValueType>: DefaultsKeys {
    
    let _key: String
    
    init(_ key: String) {
        self._key = key
    }
    
}

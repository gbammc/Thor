//
//  Defaults.swift
//  Thor
//
//  Created by Alvin on 6/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

let defaults = UserDefaults.standard

extension UserDefaults {

    subscript(key: DefaultsKey<String>) -> String {
        get { return string(forKey: key.key) ?? "" }
        set { set(newValue, forKey: key.key) }
    }

    subscript(key: DefaultsKey<Int>) -> Int {
        get { return integer(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }

    subscript(key: DefaultsKey<Double>) -> Double {
        get { return double(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }

    subscript(key: DefaultsKey<Bool>) -> Bool {
        get { return bool(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }

    subscript(key: DefaultsKey<[Any]?>) -> [Any]? {
        get { return array(forKey: key.key) }
        set { set(newValue, forKey: key.key) }
    }

}

class DefaultsKeys {
    init() {}
}

class DefaultsKey<ValueType>: DefaultsKeys {

    let key: String

    init(_ key: String) {
        self.key = key
    }

}

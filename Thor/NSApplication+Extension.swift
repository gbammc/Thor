//
//  NSApplication+Extension.swift
//  Thor
//
//  Created by AlvinZhu on 5/5/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Cocoa
import ServiceManagement

extension NSApplication {

    class func shortVersionString() -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return "Unknown"
        }

        return (infoDict["CFBundleShortVersionString"] as? String) ?? ""
    }

    class func buildVersionString() -> String {
        guard let infoDict = Bundle.main.infoDictionary else {
            return "?"
        }

        return (infoDict["CFBundleVersion"] as? String) ?? ""
    }

    class func formattedVersion() -> String {
        return "Version \(shortVersionString()) (\(buildVersionString()))"
    }

}

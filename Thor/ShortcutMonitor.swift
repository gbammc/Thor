//
//  ShortcutMonitor.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import MASShortcut

struct ShortcutMonitor {
    
    static func register() {
        let apps = AppsManager.manager.selectedApps
        for app in apps where app.shortcut != nil {
            MASShortcutMonitor.sharedMonitor().registerShortcut(app.shortcut, withAction: {
                guard Defaults[.EnableShortcut] else { return }
                
                if let frontmostAppIdentifier = NSWorkspace.sharedWorkspace().frontmostApplication?.bundleIdentifier, targetAppIdentifier = NSBundle(URL: app.appBundleURL)?.bundleIdentifier where frontmostAppIdentifier == targetAppIdentifier {
                    NSRunningApplication.runningApplicationsWithBundleIdentifier(frontmostAppIdentifier).first?.hide()
                } else {
                    NSWorkspace.sharedWorkspace().launchApplication(app.appName)
                }
            })
        }
    }
    
    static func unregister() {
        let apps = AppsManager.manager.selectedApps
        for app in apps where app.shortcut != nil {
            MASShortcutMonitor.sharedMonitor().unregisterShortcut(app.shortcut)
        }
    }
    
}

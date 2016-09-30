//
//  ShortcutMonitor.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import MASShortcut

struct ShortcutMonitor {
    
    static func register() {
        let apps = AppsManager.manager.selectedApps
        for app in apps where app.shortcut != nil {
            MASShortcutMonitor.shared().register(app.shortcut, withAction: {
                guard Defaults[.EnableShortcut] else { return }
                
                if let frontmostAppIdentifier = NSWorkspace.shared().frontmostApplication?.bundleIdentifier, let targetAppIdentifier = Bundle(url: app.appBundleURL)?.bundleIdentifier , frontmostAppIdentifier == targetAppIdentifier {
                    NSRunningApplication.runningApplications(withBundleIdentifier: frontmostAppIdentifier).first?.hide()
                } else {
                    NSWorkspace.shared().launchApplication(app.appName)
                }
            })
        }
    }
    
    static func unregister() {
        let apps = AppsManager.manager.selectedApps
        for app in apps where app.shortcut != nil {
            MASShortcutMonitor.shared().unregisterShortcut(app.shortcut)
        }
    }
    
}

//
//  ShortcutMonitor.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import Cocoa
import MASShortcut

struct ShortcutMonitor {

    static func register() {
        let apps = AppsManager.manager.selectedApps
        for app in apps where app.shortcut != nil {
            MASShortcutMonitor.shared().register(app.shortcut, withAction: {
                guard defaults[.EnableShortcut] else { return }

                guard let targetAppIdentifier = Bundle(url: app.appBundleURL)?.bundleIdentifier else { return }
                
                if let frontmostAppIdentifier = NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
                    frontmostAppIdentifier == targetAppIdentifier {
                    // Only hide if backgroundWhenActive is enabled
                    if defaults[.backgroundWhenActive] {
                        NSRunningApplication.runningApplications(withBundleIdentifier: frontmostAppIdentifier).first?.hide()
                    } else {
                        // Ensure the app is reliably activated and brought to front
                        if let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: targetAppIdentifier).first {
                            // Unhide first if the app is hidden - this is crucial for reliable activation
                            if runningApp.isHidden {
                                runningApp.unhide()
                            }
                            // Activate with options that ensure windows come forward and app receives input
                            runningApp.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
                        }
                    }
                } else {
                    // App is not currently foregrounded - activate it
                    if let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: targetAppIdentifier).first {
                        // App is already running - unhide and activate it
                        if runningApp.isHidden {
                            runningApp.unhide()
                        }
                        runningApp.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
                    } else {
                        // App is not running - launch it
                        if #available(macOS 10.15, *) {
                            let configuration = NSWorkspace.OpenConfiguration()
                            configuration.activates = true
                            NSWorkspace.shared.openApplication(at: app.appBundleURL,
                                                               configuration: configuration) { _, error in
                                if let error = error {
                                    NSLog("ERROR: \(error)")
                                }
                            }
                        } else {
                            NSWorkspace.shared.launchApplication(app.appBundleURL.lastPathComponent)
                        }
                    }
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

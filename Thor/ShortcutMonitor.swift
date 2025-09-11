//
//  ShortcutMonitor.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Carbon.HIToolbox
import Cocoa
import Foundation
import MASShortcut
import ApplicationServices

struct ShortcutMonitor {
    /// Cycles through windows of an application using Cmd+Tilde keystroke
    private static func cycleWindowsForApp() {
        // Check if accessibility permissions are granted
        if AccessibilityUtils.checkAccessibilityPermissions(shouldPromptIfNeeded: false) {
            let source = CGEventSource(stateID: .hidSystemState)
            let keyGrave = CGKeyCode(kVK_ANSI_Grave)  // Key code for `~` on US keyboards
            let keyDown = CGEvent(
                keyboardEventSource: source, virtualKey: keyGrave, keyDown: true)
            keyDown?.flags = .maskCommand
            let keyUp = CGEvent(
                keyboardEventSource: source, virtualKey: keyGrave, keyDown: false)
            keyUp?.flags = .maskCommand

            keyDown?.post(tap: .cghidEventTap)
            keyUp?.post(tap: .cghidEventTap)
        } else {
            AccessibilityUtils.checkAccessibilityPermissions()
        }
    }

    /// Toggles app visibility (hide/unhide)
    private static func toggleAppVisibility(bundleIdentifier: String) {
        if let runningApp = NSRunningApplication.runningApplications(
            withBundleIdentifier: bundleIdentifier
        ).first {
            // Toggle visibility
            if runningApp.isHidden {
                runningApp.unhide()
            } else {
                runningApp.hide()
            }
        }
    }

    /// Launches or activates an app
    private static func launchOrActivateApp(appURL: URL) {
        if #available(macOS 10.15, *) {
            let configuration = NSWorkspace.OpenConfiguration()
            configuration.activates = true
            NSWorkspace.shared.openApplication(
                at: appURL,
                configuration: configuration
            ) { _, error in
                if let error = error {
                    NSLog("ERROR: \(error)")
                }
            }
        } else {
            NSWorkspace.shared.launchApplication(appURL.lastPathComponent)
        }
    }

    static func register() {
        let apps = AppsManager.manager.selectedApps
        for app in apps where app.shortcut != nil {
            MASShortcutMonitor.shared().register(
                app.shortcut,
                withAction: {
                    guard defaults[.EnableShortcut] else { return }

                    if let frontmostAppIdentifier = NSWorkspace.shared.frontmostApplication?
                        .bundleIdentifier,
                        let targetAppIdentifier = Bundle(url: app.appBundleURL)?.bundleIdentifier,
                        frontmostAppIdentifier == targetAppIdentifier {
                        // If cycle windows feature is enabled, use Cmd+Tilde to cycle windows
                        if defaults[.cycleWindowsEnabled] {
                            cycleWindowsForApp()
                        } else {
                            // Use the old hide/unhide behavior
                            toggleAppVisibility(bundleIdentifier: targetAppIdentifier)
                        }
                    } else {
                        launchOrActivateApp(appURL: app.appBundleURL)
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

//
//  AccessibilityUtils.swift
//  Thor
//
//  Created by AlvinZhu on 7/1/2024.
//  Copyright © 2024 AlvinZhu. All rights reserved.
//

import Cocoa
import ApplicationServices

enum AccessibilityUtils {
    static let accessibilityPromptKey = "hasShownAccessibilityPrompt"
    private static var hasShownPermissionAlert = false

    /// Checks if the app has accessibility permissions and shows a prompt if needed.
    /// - Parameters:
    ///   - shouldPromptIfNeeded: Whether to show the prompt dialog if permissions aren't granted
    ///   - force: If true, shows the prompt even if it was shown before
    ///   - completion: Optional closure called with result (true if permissions are granted)
    /// - Returns: Whether accessibility permissions are granted
    @discardableResult
    static func checkAccessibilityPermissions(
        shouldPromptIfNeeded: Bool = true,
        force: Bool = false,
        completion: ((Bool) -> Void)? = nil
    ) -> Bool {
        // Check if we should show the prompt
        if !shouldPromptIfNeeded ||
            (!force && (hasShownPermissionAlert || UserDefaults.standard.bool(forKey: accessibilityPromptKey))) {
            let trusted = AXIsProcessTrusted()
            completion?(trusted)
            return trusted
        }
        // Show the prompt with the option to grant permission
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)

        // If not trusted after prompt, show our custom alert
        if !trusted && shouldPromptIfNeeded {
            showAccessibilityAlert()
        }

        // Mark that we've shown the prompt
        hasShownPermissionAlert = true
        UserDefaults.standard.set(true, forKey: accessibilityPromptKey)

        completion?(trusted)
        return trusted
    }

    /// Shows an alert explaining the need for accessibility permissions
    private static func showAccessibilityAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = """
            Thor needs accessibility permissions to cycle through application windows using Command+Tilde.
            Please enable it in System Preferences > Security & Privacy > Privacy > Accessibility.
            """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Later")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let prefsURL = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                NSWorkspace.shared.open(URL(string: prefsURL)!)
            }
        }
    }
}

//
//  ShortcutMonitor.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import CoreFoundation
import Cocoa
import MASShortcut
import OSLog

struct ShortcutMonitor {

    static func register(apps: [AppModel] = AppsManager.manager.selectedApps) {
        guard defaults[.EnableShortcut] else { return }
        for app in apps {
            guard let shortcut = app.shortcut else { continue }
            MASShortcutMonitor.shared().register(shortcut, withAction: {
                guard defaults[.EnableShortcut] else { return }
                activate(app)
            })
        }
    }

    static func unregister(apps: [AppModel] = AppsManager.manager.selectedApps) {
        for app in apps {
            guard let shortcut = app.shortcut else { continue }
            MASShortcutMonitor.shared().unregisterShortcut(shortcut)
        }
    }

    private static func activate(_ app: AppModel) {
        do {
            if let bookmark = app.bookmark, let resolved = try app.accessBookmarkedApp(bookmark) {
                if resolved.isStale {
                    do {
                        let bookmark = try AppModel.makeBookmark(for: resolved.url)
                        try AppsManager.manager.refreshBookmark(bookmark, for: app, at: resolved.url)
                    } catch {
                        Logger.app.warning("Could not renew bookmark: \(error.localizedDescription)")
                    }
                }
                openOrHide(at: resolved.url)
                return
            }
        } catch {
            Logger.app.warning("Could not resolve application bookmark: \(error.localizedDescription)")
        }

        if let url = app.appBundleURL, app.matchesApp(at: url) {
            openOrHide(at: url)
        } else if !app.appBundleIdentifier.isEmpty {
            let urls = NSWorkspace.shared.urlsForApplications(withBundleIdentifier: app.appBundleIdentifier)
            if urls.count == 1, let url = urls.first, app.matchesApp(at: url, allowsMissingBundleInfo: true) {
                openOrHide(at: url)
            }
        }
    }

    private static func openOrHide(at url: URL) {
        let workspace = NSWorkspace.shared
        if let frontmost = workspace.frontmostApplication, let frontmostURL = frontmost.bundleURL,
           AppModel.isSameApp(at: url, as: frontmostURL) {
            frontmost.hide()
            return
        }

        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        configuration.allowsRunningApplicationSubstitution = false
        workspace.openApplication(at: url, configuration: configuration) { _, error in
            if let error {
                Logger.app.error("Failed to launch: \(error.localizedDescription)")
            }
        }
    }

}

extension AppModel {

    func accessBookmarkedApp(_ bookmark: Data) throws -> (url: URL, isStale: Bool)? {
        var stale = false
        let url = try URL(resolvingBookmarkData: bookmark, options: [.withoutUI],
                          relativeTo: nil, bookmarkDataIsStale: &stale)
        guard matchesApp(at: url) else { return nil }
        return (url, stale)
    }

    func matchesApp(at url: URL, allowsMissingBundleInfo: Bool = false) -> Bool {
        // Read the current bundle metadata without reusing a cached Bundle for this URL.
        guard let info = CFBundleCopyInfoDictionaryInDirectory(url as CFURL) as? [String: Any],
              !info.isEmpty else { return allowsMissingBundleInfo }
        let identifier = info[kCFBundleIdentifierKey as String] as? String
        return appBundleIdentifier.isEmpty || identifier == appBundleIdentifier
    }

    static func isSameApp(at url: URL, as otherURL: URL) -> Bool {
        let path = url.standardizedFileURL.path
        let otherPath = otherURL.standardizedFileURL.path
        if path == otherPath { return true }

        let resourceKeys: Set<URLResourceKey> = [.fileResourceIdentifierKey]
        let file = URL(fileURLWithPath: path)
        let otherFile = URL(fileURLWithPath: otherPath)
        guard let identity = try? file.resourceValues(forKeys: resourceKeys).fileResourceIdentifier,
              let otherIdentity = try? otherFile.resourceValues(forKeys: resourceKeys).fileResourceIdentifier else {
            return false
        }
        return identity.isEqual(otherIdentity)
    }

}

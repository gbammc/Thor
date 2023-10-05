//
//  AppsManager.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import MASShortcut

class AppsManager: NSObject {

    // MARK: Properties

    static let manager = AppsManager()

    @objc dynamic var selectedApps = [AppModel]()

    private var closure: (([AppModel]) -> Void)!

    private var selectedAppsFilePath: String {
        let dir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first
        let key = kCFBundleNameKey as String

        guard let appSupportDir = dir, let appName = Bundle.main.infoDictionary![key] as? String else {
            return ""
        }

        var appDir = appSupportDir.appendingPathComponent(appName)
        if !FileManager.default.fileExists(atPath: appDir) {
            // Backward compatibility
            let backwardAppDir = appSupportDir.appendingPathComponent("Thor")

            if !FileManager.default.fileExists(atPath: backwardAppDir) {
                _ = try? FileManager.default.createDirectory(atPath: appDir, withIntermediateDirectories: true)
            } else {
                appDir = backwardAppDir
            }
        }

        return appDir.appendingPathComponent("apps.json")
    }

    // MARK: Life cycle

    override init() {
        super.init()

        loadApps(from: selectedAppsFilePath)
    }

    // MARK: Actions

    func save(_ app: AppModel?, shortcut: MASShortcut?) {
        guard let app = app else { return }

        ShortcutMonitor.unregister()

        if let existedApp = selectedApps.filter({ $0 == app }).first {
            existedApp.shortcut = shortcut
        } else {
            app.shortcut = shortcut
            selectedApps.append(app)
        }

        if saveData(to: selectedAppsFilePath) {
            ShortcutMonitor.register()
        }
    }

    func delete(_ index: Int) {
        guard 0 <= index && index < selectedApps.count else { return }

        ShortcutMonitor.unregister()

        selectedApps.remove(at: index)

        if saveData(to: selectedAppsFilePath) {
            ShortcutMonitor.register()
        }
    }

    func loadApps(from path: String) {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let apps = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            selectedApps = apps.compactMap { AppModel(jsonValue: $0) }
        } else if let data = try? Data(contentsOf: URL(fileURLWithPath: path).deletingPathExtension()),
                  let apps = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self,
                                                                                 NSArray.self,
                                                                                 NSString.self,
                                                                                 MASShortcut.self],
                                                                     from: data) as? [NSDictionary] {
            // Backward compatibility
            selectedApps = apps.compactMap { AppModel(dict: $0) }
        }
        _ = saveData(to: selectedAppsFilePath)
    }

    func move(with indexes: [Int], to row: Int) {
        let apps = indexes.map { selectedApps[$0] }
        let target = row - indexes.filter { $0 < row }.count
        for (idx, index) in indexes.enumerated() {
            selectedApps.remove(at: index - idx)
        }
        selectedApps.insert(contentsOf: apps, at: target)

        _ = saveData(to: selectedAppsFilePath)
    }

    func saveData(to path: String) -> Bool {
        do {
            let apps = selectedApps.map { $0.encodeToJSONValue() }
            let encoded = try JSONSerialization.data(withJSONObject: apps, options: [.prettyPrinted, .sortedKeys])
            try encoded.write(to: URL(fileURLWithPath: path), options: [.atomic])
            return true
        } catch {
            return false
        }
    }

}

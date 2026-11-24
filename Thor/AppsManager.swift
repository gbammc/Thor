//
//  AppsManager.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import MASShortcut
import OSLog

class AppsManager: NSObject {

    static let manager = AppsManager()

    @objc dynamic private(set) var selectedApps = [AppModel]()

    private let configurationURL: URL
    private var loadError: Error?

    private static var defaultConfigurationURL: URL {
        let appSupport = URL.applicationSupportDirectory
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String ?? "Thor"
        let currentDirectory = appSupport.appendingPathComponent(appName, isDirectory: true)
        let legacyDirectory = appSupport.appendingPathComponent("Thor", isDirectory: true)
        let files = FileManager.default
        let hasLegacyDirectory = files.fileExists(atPath: legacyDirectory.path)
        let useLegacyDirectory = hasLegacyDirectory && !files.fileExists(atPath: currentDirectory.path)
        let directory = useLegacyDirectory ? legacyDirectory : currentDirectory
        return directory.appendingPathComponent("apps.json")
    }

    override convenience init() {
        self.init(configurationURL: Self.defaultConfigurationURL)
    }

    init(configurationURL: URL) {
        self.configurationURL = configurationURL
        super.init()
        do {
            selectedApps = try Self.readLocalApps(from: configurationURL)
        } catch {
            loadError = error
            Logger.app.error("Could not read shortcut configuration: \(error.localizedDescription)")
        }
    }

    func add(_ app: AppModel) throws -> Int {
        if let path = app.appBundleURL?.standardizedFileURL.path,
           let index = selectedApps.firstIndex(where: { $0.appBundleURL?.standardizedFileURL.path == path }) {
            try relocate(selectedApps[index], to: app)
            return index
        }
        try commit(selectedApps + [app])
        return selectedApps.count - 1
    }

    func setShortcut(_ shortcut: MASShortcut?, for app: AppModel) throws {
        try replace(app) { $0.settingShortcut(shortcut) }
    }

    func relocate(_ app: AppModel, to replacement: AppModel) throws {
        try replace(app) { $0.relocating(to: replacement) }
    }

    func refreshBookmark(_ data: Data, for app: AppModel, at url: URL) throws {
        // A queued hotkey can still refer to the previous target after an edit.
        guard let index = selectedApps.firstIndex(where: { $0 === app }) else { return }
        var apps = selectedApps
        apps[index] = app.refreshingBookmark(data, at: url)
        try commit(apps)
    }

    private func replace(_ app: AppModel, with replacement: (AppModel) -> AppModel) throws {
        guard let index = selectedApps.firstIndex(where: { $0.id == app.id }) else { return }
        var apps = selectedApps
        apps[index] = replacement(apps[index])
        try commit(apps)
    }

    func delete(_ index: Int) throws {
        guard selectedApps.indices.contains(index) else { return }
        var apps = selectedApps
        apps.remove(at: index)
        try commit(apps)
    }

    func move(with indexes: [Int], to row: Int) throws {
        guard !indexes.isEmpty, indexes.allSatisfy(selectedApps.indices.contains),
              (0...selectedApps.count).contains(row) else { return }
        let movedRows = IndexSet(indexes)
        var apps = selectedApps.enumerated().filter { !movedRows.contains($0.offset) }.map(\.element)
        let target = row - movedRows.count(in: 0..<row)
        apps.insert(contentsOf: movedRows.map { selectedApps[$0] }, at: target)
        try commit(apps, updateShortcuts: false)
    }

    func importShortcuts(from url: URL) throws {
        let apps = try Self.decodeJSON(Data(contentsOf: url)).map { $0.restoringBookmark(from: selectedApps) }
        if loadError != nil {
            // Preserve the original file even when a valid import replaces an unreadable configuration.
            let recoveryURL = configurationURL.deletingLastPathComponent()
                .appendingPathComponent("apps-before-import-\(UUID().uuidString).json")
            do {
                try FileManager.default.copyItem(at: configurationURL, to: recoveryURL)
            } catch let error as CocoaError where error.code == .fileNoSuchFile || error.code == .fileReadNoSuchFile {
                // A legacy archive retains its own path when the JSON file is created.
            }
        }
        try commit(apps, replacingUnreadableConfiguration: true)
    }

    func exportShortcuts(to url: URL) throws {
        if let loadError { throw loadError }
        try Self.write(selectedApps, to: url)
    }

    private func commit(_ apps: [AppModel], updateShortcuts: Bool = true,
                        replacingUnreadableConfiguration: Bool = false) throws {
        if let loadError, !replacingUnreadableConfiguration { throw loadError }
        try FileManager.default.createDirectory(at: configurationURL.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try Self.write(apps, to: configurationURL)
        loadError = nil
        let shouldRegister = updateShortcuts && defaults[.EnableShortcut]
        if shouldRegister { ShortcutMonitor.unregister(apps: selectedApps) }
        selectedApps = apps
        if shouldRegister { ShortcutMonitor.register(apps: selectedApps) }
    }

    private static func readLocalApps(from url: URL) throws -> [AppModel] {
        do {
            return try decodeJSON(Data(contentsOf: url))
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
            let data: Data
            do {
                data = try Data(contentsOf: url.deletingPathExtension())
            } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
                return []
            }
            let types: [AnyClass] = [
                NSDictionary.self, NSArray.self, NSString.self, NSData.self, NSNull.self, MASShortcut.self
            ]
            let decoded = try NSKeyedUnarchiver.unarchivedObject(ofClasses: types, from: data)
            guard let apps = decoded as? [NSDictionary] else {
                throw CocoaError(.fileReadCorruptFile)
            }
            return try apps.map { record in
                guard let app = AppModel(dict: record) else { throw CocoaError(.fileReadCorruptFile) }
                return app
            }
        }
    }

    private static func decodeJSON(_ data: Data) throws -> [AppModel] {
        let records = try JSONDecoder().decode([[String: String]].self, from: data)
        return try records.map { record in
            guard let app = AppModel(jsonValue: record) else {
                throw CocoaError(.fileReadCorruptFile)
            }
            return app
        }
    }

    private static func write(_ apps: [AppModel], to url: URL) throws {
        let records = apps.map { $0.encodeToJSONValue() }
        let data = try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: url, options: .atomic)
    }

}

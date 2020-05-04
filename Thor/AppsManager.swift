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
    
    private var closure: (([AppModel]) -> ())!
    
    private var selectedAppsFilePath: String {
        get {
            let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
            let dir = (NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent(appName)
            if !FileManager.default.fileExists(atPath: dir) {
                _ = try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            }
            
            return (dir as NSString).appendingPathComponent("apps")
        }
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
        
        if let existedApp = selectedApps.filter({ $0.appName == app.appName }).first {
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
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let apps = NSKeyedUnarchiver.unarchiveObject(with: data) as? [NSDictionary] else {
            return
        }
        
        selectedApps = apps.compactMap { AppModel(dict: $0) }
        
        _ = saveData(to: selectedAppsFilePath)
    }
    
    func saveData(to path: String) -> Bool {
        let apps = selectedApps.map { $0.encode() }
        return NSKeyedArchiver.archiveRootObject(apps, toFile: path)
    }
    
}

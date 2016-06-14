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
    
    var selectedApps = [AppModel]()
    
    private var closure: (([AppModel]) -> ())!
    
    private var selectedAppsFile: String {
        get {
            let appName = Bundle.main().infoDictionary![kCFBundleNameKey as String] as! String
            let path = (NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent(appName)
            if !FileManager.default().fileExists(atPath: path) {
                _ = try? FileManager.default().createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
            
            return (path as NSString).appendingPathComponent("apps")
        }
    }
    
    // MARK: Life cycle
    
    override init() {
        super.init()

        if let data = try? Data(contentsOf: URL(fileURLWithPath: selectedAppsFile)), apps = NSKeyedUnarchiver.unarchiveObject(with: data) as? [NSDictionary] {
            selectedApps = apps.flatMap { AppModel(dict: $0) }
        }
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
        
        saveData()
    }
    
    func delete(_ index: Int) {
        guard 0 <= index && index < selectedApps.count else { return }
        
        selectedApps.remove(at: index)
        
        saveData()
    }
    
    private func saveData() {
        let apps = selectedApps.map { $0.encode() }
        
        if NSKeyedArchiver.archiveRootObject(apps, toFile: selectedAppsFile) {
            ShortcutMonitor.register()
        }
    }
    
}

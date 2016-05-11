//
//  AppsManager.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

class AppsManager: NSObject {
    
    static let manager = AppsManager()
    
    var selectedApps = [AppModel]()
    
    private var query = NSMetadataQuery()
    private var closure: (([AppModel]) -> ())!
    
    private var selectedAppsFile: String {
        get {
            let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as! String
            let path = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first!
            
            return path.stringByAppendingString("/\(appName)/apps")
        }
    }
    
    override init() {
        super.init()

        query.predicate = NSPredicate(format: "kMDItemKind == 'Application'")
        query.searchScopes = ["/Applications/", "/System/Library/CoreServices/"]
        
        if let data = NSData(contentsOfFile: selectedAppsFile), apps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
            selectedApps = apps.flatMap { AppModel(dict: $0) }
        }
    }
    
    func getAppsInApplicationsDirectiory(closure: [AppModel] -> ()) {
        self.closure = closure

        startQuery()
    }
    
    func save(app: AppModel) {
        selectedApps.append(app)
        
        saveData()
    }
    
    func delete(index: Int) {
        guard 0 <= index && index < selectedApps.count else { return }
        
        selectedApps.removeAtIndex(index)
        
        saveData()
    }
    
    private func saveData() {
        let apps = selectedApps.map { $0.encode() }
        
        if NSKeyedArchiver.archiveRootObject(apps, toFile: selectedAppsFile) {
            HotKeysRegister.registerHotKeys()
        }
    }
    
    private func startQuery() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSMetadataQueryDidFinishGatheringNotification, object: nil, queue: NSOperationQueue.currentQueue()) { (_) in
            self.query.stopQuery()
            
            let apps = AppModel.appsFroms(self.query.results)
            self.closure(apps)
        }
        
        query.startQuery()
    }
    
}

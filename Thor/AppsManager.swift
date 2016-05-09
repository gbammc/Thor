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
    private var callback: (([AppModel]) -> ())!
    
    private var selectedAppsFile: String {
        get {
            let appName = NSBundle.mainBundle().infoDictionary![kCFBundleNameKey as String] as! String
            let path = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first!
            return path.stringByAppendingString("/\(appName)/apps")
        }
    }
    
    override init() {
        super.init()

        query.predicate = NSPredicate(format: "kMDItemKind=='Application'")
        query.searchScopes = ["/Applications/", "/System/Library/CoreServices/"]
        
        if let data = NSData(contentsOfFile: selectedAppsFile), apps = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary] {
            selectedApps = apps.flatMap { AppModel(dict: $0) }
        }
    }
    
    func getApps(callback: [AppModel] -> ()) {
        self.callback = callback

        startQuery()
    }
    
    private func startQuery() {
        NSNotificationCenter.defaultCenter().addObserverForName(NSMetadataQueryDidFinishGatheringNotification, object: nil, queue: NSOperationQueue.currentQueue()) { (_) in
            self.query.stopQuery()
            
            let apps = AppModel.appsFroms(self.query.results)
            self.callback(apps)
        }
        
        query.startQuery()
    }
    
    func saveData() {
        let apps = selectedApps.map { $0.encode() }
        
        if NSKeyedArchiver.archiveRootObject(apps, toFile: selectedAppsFile) {
            HotKeysRegister.registerHotKeys()
        }
    }
    
}

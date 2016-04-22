//
//  AppsManager.swift
//  Thor
//
//  Created by AlvinZhu on 4/18/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation

class AppsManager {
    
    static let manager = AppsManager()
    
    var selectedApps = [AppModel]()
    
    private let query: NSMetadataQuery
    private var callback: (([AppModel]) -> ())?
    
    init() {
        let pred = NSPredicate(format: "kMDItemKind=='Application'")
        query = NSMetadataQuery()
        query.predicate = pred
        query.searchScopes = ["/Applications/"]
        
        if let apps = loadDataFrom(selectedAppsFile) as? [NSDictionary] {
            selectedApps = apps.flatMap { AppModel(dict: $0) }
        }
    }
    
    func getApps(callback: ([AppModel] -> ())?) {
        self.callback = callback
        
        startQuery()
    }
    
    func saveData() {
        let apps = selectedApps.map { $0.encode() }
        save(apps, to: selectedAppsFile)
    }
    
    private func startQuery() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AppsManager.queryFinish(_:)), name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        
        query.startQuery()
    }
    
    @objc private func queryFinish(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSMetadataQueryDidFinishGatheringNotification, object: nil)
        
        let apps = AppModel.appsFroms(query.results)
        
        callback?(apps)
    }
    
}
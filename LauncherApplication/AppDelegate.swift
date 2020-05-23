//
//  AppDelegate.swift
//  LauncherApplication
//
//  Created by Alvin on 2020/5/23.
//  Copyright © 2020 AlvinZhu. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "me.alvinzhu.Thor"
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = !runningApps.filter { $0.bundleIdentifier == mainAppIdentifier }.isEmpty

        if !isRunning {
            DistributedNotificationCenter.default().addObserver(self,
                                                                selector: #selector(terminate),
                                                                name: .killLauncher,
                                                                object: mainAppIdentifier)

           let path = Bundle.main.bundlePath as NSString
           var components = path.pathComponents
           components.removeLast(3)
           components.append("MacOS")
           components.append("Thor")

           let newPath = NSString.path(withComponents: components)

           NSWorkspace.shared.launchApplication(newPath)
       } else {
           terminate()
       }
    }

    @objc func terminate() {
        NSApp.terminate(nil)
    }

}

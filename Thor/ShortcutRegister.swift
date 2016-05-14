//
//  ShortcutRegister.swift
//  Thor
//
//  Created by Alvin on 5/14/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

import Foundation
import Carbon
import SwiftyUserDefaults

struct ShortcutRegister {
    
    static func register() {
        unregister()
        
        var hotKeyRefs = [NSData]()
        let apps = AppsManager.manager.selectedApps
        for (i, app) in apps.enumerate() {
            let signature = OSType((app.appName as NSString).UTF8String.memory)
            let id = UInt32(i)
            let hotKeyID = EventHotKeyID(signature: signature, id: id)
            
            var hotKeyRef: EventHotKeyRef = nil
            RegisterEventHotKey(app.shortcut!.carbonKeyCode, app.shortcut!.carbonFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
            if hotKeyRef != nil {
                let data = NSData(bytes: &hotKeyRef, length: sizeof(EventHotKeyRef))
                hotKeyRefs.append(data)
            }
        }
        
        Defaults[.Shortcuts] = hotKeyRefs
        
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, event, userData) -> OSStatus in
            guard Defaults[.EnableShortcut] else { return noErr }
            
            let apps = AppsManager.manager.selectedApps
            guard apps.count > 0 else { return noErr }
            
            var hotKeyRef = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, sizeof(EventHotKeyID), nil, &hotKeyRef)
            let app = apps[Int(hotKeyRef.id)]
            NSWorkspace.sharedWorkspace().launchApplication(app.appName)
            
            return noErr
            }, 1, &eventType, nil, nil)
    }
    
    static func unregister() {
        if let hotKeyRefs = Defaults[.Shortcuts] {
            hotKeyRefs.forEach {
                var hotKeyRef: EventHotKeyRef = nil
                $0.getBytes(&hotKeyRef, length: sizeof(EventHotKeyRef))
                if hotKeyRef != nil {
                    UnregisterEventHotKey(hotKeyRef)
                }
            }
        }
    }
    
}

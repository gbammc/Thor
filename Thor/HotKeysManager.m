//
//  HotKeysManager.m
//  Thor
//
//  Created by AlvinZhu on 4/25/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

#import "HotKeysManager.h"
#import <Carbon/Carbon.h>
#import "Thor-Swift.h"

@import MASShortcut;

@implementation HotKeysManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static HotKeysManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[HotKeysManager alloc] init];
    });
    
    return manager;
}

- (void)registerHotKeys
{
    NSArray<AppModel *> *apps = [AppsManager manager].selectedApps;
    [self registerHotKeys:apps];
}

- (void)registerHotKeys:(NSArray<AppModel *> *)apps
{
    [self unregisterHotKeys];
    
    EventHotKeyID hotKeyID;
    EventTypeSpec eventType;
    NSMutableArray *array = [NSMutableArray array];
    unsigned int idx = 0;
    
    for (AppModel *app in apps) {
        hotKeyID.id = idx;
        hotKeyID.signature = (OSType)[app.appName UTF8String];
        EventHotKeyRef hotKeyRef;
        RegisterEventHotKey(app.shortcut.carbonKeyCode, app.shortcut.carbonFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        if (!hotKeyRef) {
            NSData *data = [NSData dataWithBytes:&hotKeyRef length:sizeof(EventHotKeyRef)];
            [array addObject:data];
        }
        
        idx++;
    }
    
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&hotkeyHandler, 1, &eventType, NULL, NULL);
}

- (void)unregisterHotKeys
{
    NSArray *hotKeyRefs = [[NSUserDefaults standardUserDefaults] objectForKey:@"hotKey"];
    for (NSData *value in hotKeyRefs) {
        EventHotKeyRef myHotKeyRef;
        [value getBytes:&myHotKeyRef length:sizeof(EventHotKeyRef)];
        UnregisterEventHotKey(myHotKeyRef);
    }
}

OSStatus hotkeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData)
{
//    BOOL enableHotKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableHotKey"];
//    if (!enableHotKey) {
//        return noErr;
//    }
    
    EventHotKeyID hotKeyRef;
    
    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
    
    NSArray *apps = [AppsManager manager].selectedApps;
    if (apps.count == 0) {
        return noErr;
    }
    
    AppModel *app = apps[hotKeyRef.id];
    [[NSWorkspace sharedWorkspace] launchApplication:app.appName];
    
    return noErr;
}

@end

//
//  HotKeysCoordinator.m
//  Thor
//
//  Created by AlvinZhu on 4/25/16.
//  Copyright © 2016 AlvinZhu. All rights reserved.
//

#import "HotKeysCoordinator.h"
#import <Carbon/Carbon.h>
#import "Thor-Swift.h"

@import MASShortcut;

@implementation HotKeysCoordinator

+ (void)registerHotKeys
{
    NSArray<AppModel *> *apps = [AppsManager manager].selectedApps;
    [self registerHotKeys:apps];
}

+ (void)registerHotKeys:(NSArray<AppModel *> *)apps
{
    [self unregisterHotKeys];
    
    NSMutableArray *array = [NSMutableArray array];
    
    [apps enumerateObjectsUsingBlock:^(AppModel * _Nonnull app, NSUInteger idx, BOOL * _Nonnull stop) {
        EventHotKeyID hotKeyID;
        hotKeyID.id = (UInt32)idx;
        hotKeyID.signature = (OSType)[app.appName UTF8String];
        
        EventHotKeyRef hotKeyRef;
        RegisterEventHotKey(app.shortcut.carbonKeyCode, app.shortcut.carbonFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        if (hotKeyRef) {
            NSData *data = [NSData dataWithBytes:&hotKeyRef length:sizeof(EventHotKeyRef)];
            [array addObject:data];
        }
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"hotKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    EventTypeSpec eventType;
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    
    InstallApplicationEventHandler(&hotkeyHandler, 1, &eventType, NULL, NULL);
}

+ (void)unregisterHotKeys
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
    BOOL enableHotKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"enableShortcut"];
    if (!enableHotKey) {
        return noErr;
    }
    
    NSArray *apps = [AppsManager manager].selectedApps;
    if (apps.count == 0) {
        return noErr;
    }
    
    EventHotKeyID hotKeyRef;
    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
    
    AppModel *app = apps[hotKeyRef.id];
    [[NSWorkspace sharedWorkspace] launchApplication:app.appName];
    
    return noErr;
}

@end

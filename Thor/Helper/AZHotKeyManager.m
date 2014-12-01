//
//  AZHotKeyManager.m
//  AppShortCut
//
//  Created by Alvin on 13-10-19.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZHotKeyManager.h"
#import <Carbon/Carbon.h>
#import "AZAppModel.h"
#import "AZResourceManager.h"
#import "AppDelegate.h"

/* key codes
 * spacebar 49
 * a        0
 * 1        17
 * F1       122
 * left arrow   123
 * down arrow   125
 * right arrow  124
 * up arrow     126
 * enter        36
 * backspace    51
 * `            50
 */

id AZReg;

@implementation AZHotKeyManager

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);

+ (id)sharedInstance {
    if (!AZReg) {
        AZReg = [[[self class] alloc] init];
    }
    return AZReg;
}

- (void)registerHotKeys {
    NSArray *appsArray = [[AZResourceManager sharedInstance] readSelectedAppsList];
    [self registerHotKeys:appsArray];
}

- (void)registerHotKeys:(NSArray *)apps {
    [self unregisterHotKeys];
    
    EventHotKeyID   hotKeyID;
    EventTypeSpec   eventType;
    
    NSMutableArray *array = [NSMutableArray array];
    int keyCodes[] = {18, 19, 20, 21, 23, 22, 26, 28, 25, 29};
    
    EventModifiers modifyKey = 0;
    NSInteger modifyKeyIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"modifyKey"];
    switch (modifyKeyIndex) {
        case 0:
            modifyKey = cmdKey;
            break;
        case 1:
            modifyKey = optionKey;
            break;
        case 2:
            modifyKey = controlKey;
            break;
        case 3:
            modifyKey = shiftKey;
            break;
        default:
            modifyKey = cmdKey;
            break;
    }
    
    for (unsigned int i = 0; i < 10; i++) {
        if ([apps[i] isEqualTo:[NSNull null]]) continue;
        
        hotKeyID.signature = (OSType)[[NSString stringWithFormat:@"app%u", i] UTF8String];
        hotKeyID.id = i;
        
        EventHotKeyRef  hotKeyRef;
        RegisterEventHotKey(keyCodes[i], modifyKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        if (hotKeyRef != nil) {
            NSData *data = [NSData dataWithBytes:&hotKeyRef length:sizeof(EventHotKeyRef)];
            [array addObject:data];
        }
    }
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:array forKey:@"HOT_KEY"];
    [def synchronize];
    
    eventType.eventClass = kEventClassKeyboard;
    eventType.eventKind = kEventHotKeyPressed;
    InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, NULL, NULL);
}

- (void)unregisterHotKeys {
    NSArray *hotKeyRefs = [[NSUserDefaults standardUserDefaults] objectForKey:@"HOT_KEY"];    
    for (NSData *value in hotKeyRefs) {
        EventHotKeyRef  myHotKeyRef;
        [value getBytes:&myHotKeyRef length:sizeof(EventHotKeyRef)];
        UnregisterEventHotKey(myHotKeyRef);
    }
}

OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
    if (!((AppDelegate *)[NSApplication sharedApplication].delegate).enableHotKey) return noErr;
    
    EventHotKeyID hotKeyRef;
    
    GetEventParameter(anEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
    
    NSArray *appsArray = [[AZResourceManager sharedInstance] readSelectedAppsList];
    if (appsArray.count < 10 || [appsArray[hotKeyRef.id] isEqual:[NSNull null]]) return noErr;
    
    AZAppModel *app = [NSKeyedUnarchiver unarchiveObjectWithData:appsArray[hotKeyRef.id]];
    
    NSString *pathUrl = nil;
    if (app.isSysApp) {
        pathUrl = [NSString stringWithFormat:@"/System/Library/CoreServices/%@", app.appName];
    } else {
        pathUrl = [NSString stringWithFormat:@"/Applications/%@", app.appName];
    }
    
    
    
    [[NSWorkspace sharedWorkspace] launchApplication:pathUrl];
    return noErr;
}

@end

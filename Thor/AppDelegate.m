//
//  AppDelegate.m
//  Thor
//
//  Created by Alvin on 11/23/14.
//  Copyright (c) 2014 AlvinZhu. All rights reserved.
//

#import "AppDelegate.h"
#import "AZHotKeyManager.h"
#import "AZResourceManager.h"
#import "AZAppController.h"

/*
 * Add "Application is agent (UIElement)" to plist,
 * and set TRUE to hide the application in app switcher
 */

//static CGEventRef eventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
//
//    NSDate *tempTimeStamp = [NSDate date];
//
//    EventHotKeyID hotKeyRef;
//    EventRecord record;
//    EventHotKeyRef hotkey;
//
//
//    EventRef eventRef;
//    CreateEventWithCGEvent(NULL, event, kEventAttributeNone, &eventRef);
//    GetEventParameter(eventRef, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyRef), NULL, &hotKeyRef);
//
//    GetEventParameter(eventRef, kEventParamDirectObject, typeEventInfo, NULL, sizeof(record), NULL, &record);
//
//    return event;
//}
//
//
//    // listen any key but for flags
//    CGEventMask eventMask = CGEventMaskBit(kCGEventKeyUp) | CGEventMaskBit(kCGEventKeyDown);
//    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, eventCallback, NULL);
//    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
//    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
//    CGEventTapEnable(eventTap, true);
//    CFRelease(eventTap);
//    CFRelease(runLoopSource);

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)awakeFromNib {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shownInStatusBar"]) {
        [self showStatusBar];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    isFirstActive = YES;
    self.enableHotKey = YES;
    [self listenEvents];
    
    NSArray *appsArray = [[AZResourceManager sharedInstance] readSelectedAppsList];
    [[AZHotKeyManager sharedInstance] registerHotKeys:appsArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWindow) name:@"REFRESH_WINDOW" object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"shownInStatusBar"] && !isFirstActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_PREFERENCE_VIEW" object:nil];
    }
    isFirstActive = NO;
}

#pragma mark - StatusBar

- (void)showStatusBar {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"icon_20x20.png "]];
    [self.statusItem setHighlightMode:YES];
}

- (void)hideStatusBar {
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
}

#pragma mark - Handle events

- (void)listenEvents {
    // get modify key
    NSInteger modifyKey = [self getModifyKey];
    
    // get delay interval
    NSTimeInterval interval = [self getDelayInterval];
    
    // Clear previous monitors
    if (self.globalMonitor != nil && self.localMonitor != nil) {
        [NSEvent removeMonitor:self.globalMonitor];
        [NSEvent removeMonitor:self.localMonitor];
    }
    
    NSTimeInterval intervalAnewHotKey = 1;
    NSTimeInterval intervalCheckHotKeyEnable = 0.3;
    
    /* Global monitor
     * OS X 10.9
     * need to "drag-and-drop" your application from the Application folder to the new Accessibility menu
     */
    self.globalMonitor =
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask | NSKeyDownMask handler: ^(NSEvent *event) {
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
        if(flags == modifyKey && !self.window.isFadingOut && !isTapping){
            isTapping = YES;
            
            // check hot key enable
            if (hasTapped) {
                hasTapped = NO;
                self.enableHotKey = NO;
                [self.timerDelay invalidate];
                [self.timerDisabelHotKey invalidate];
                [[AZHotKeyManager sharedInstance] unregisterHotKeys];
                [NSTimer scheduledTimerWithTimeInterval:intervalAnewHotKey target:self selector:@selector(anewHotKeyEnable) userInfo:Nil repeats:NO];
                return;
            }
            
            hasTapped = YES;
            self.timerDisabelHotKey = [NSTimer scheduledTimerWithTimeInterval:intervalCheckHotKeyEnable target:self selector:@selector(checkHotKeyEnable) userInfo:nil repeats:NO];
            
            BOOL shownSwitcherView = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownSwitcherView"];
            if (!shownSwitcherView) return;
            
            if (self.window == nil) {
                self.window  = [[AZAppsSwitchWindow alloc] init];
            }
            self.timerDelay = [NSTimer scheduledTimerWithTimeInterval:interval
                                                               target:self
                                                             selector:@selector(switcherViewFadeIn)
                                                             userInfo:nil
                                                              repeats:NO];
            return;
        }
        
        if ([self.timerDelay isValid]) [self.timerDelay invalidate];
        if (isTapping) [self.window fadeOut];
        isTapping = NO;
    }];
    
    self.localMonitor =
    [NSEvent addLocalMonitorForEventsMatchingMask:NSFlagsChangedMask + NSKeyDownMask handler:^(NSEvent *event) {
        NSUInteger flags = [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
        
        if(flags == modifyKey && !self.window.isFadingOut && !isTapping){
            isTapping = YES;
            // check hot key enable
            if (hasTapped) {
                hasTapped = NO;
                self.enableHotKey = NO;
                [self.timerDelay invalidate];
                [[AZHotKeyManager sharedInstance] unregisterHotKeys];
                [self.timerDisabelHotKey invalidate];
                self.timerDisabelHotKey = [NSTimer scheduledTimerWithTimeInterval:intervalAnewHotKey target:self selector:@selector(anewHotKeyEnable) userInfo:nil repeats:NO];
                
                return event;
            }
            hasTapped = YES;
            self.timerDisabelHotKey = [NSTimer scheduledTimerWithTimeInterval:intervalCheckHotKeyEnable target:self selector:@selector(checkHotKeyEnable) userInfo:nil repeats:NO];
            
            BOOL shownSwitcherView = [[NSUserDefaults standardUserDefaults] boolForKey:@"shownSwitcherView"];
            if (!shownSwitcherView) return event;
            
            if (self.window == nil) {
                self.window  = [[AZAppsSwitchWindow alloc] init];
            }
            self.timerDelay = [NSTimer scheduledTimerWithTimeInterval:interval
                                                               target:self
                                                             selector:@selector(switcherViewFadeIn)
                                                             userInfo:nil
                                                              repeats:NO];
        } else {
            if ([self.timerDelay isValid]) [self.timerDelay invalidate];
            if (isTapping) [self.window fadeOut];
            isTapping = NO;
        }
        return event;
    }];
}

- (NSInteger)getModifyKey {
    NSInteger modifyKeyIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"modifyKey"];
    NSInteger modifyKey = 0;
    switch (modifyKeyIndex) {
        case 0:
            modifyKey = NSCommandKeyMask;
            break;
        case 1:
            modifyKey = NSAlternateKeyMask;
            break;
        case 2:
            modifyKey = NSControlKeyMask;
            break;
        case 3:
            modifyKey = NSShiftKeyMask;
            break;
        default:
            modifyKey = NSCommandKeyMask;
            break;
    }
    return modifyKey;
}

- (NSTimeInterval)getDelayInterval {
    NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:@"delayInterval"];
    return interval;
}

- (void)refreshWindow {
    [self.window refresh];
}

- (void)switcherViewFadeIn {
    if (isTapping) {
        [self.window fadeIn];
    }
}

- (void)checkHotKeyEnable {
    hasTapped = NO;
}

- (void)anewHotKeyEnable {
    [[AZHotKeyManager sharedInstance] registerHotKeys];
    self.enableHotKey = YES;
}

@end

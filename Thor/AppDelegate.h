//
//  AppDelegate.h
//  Thor
//
//  Created by Alvin on 11/23/14.
//  Copyright (c) 2014 AlvinZhu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AZAppsSwitchWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BOOL isFirstActive;
    BOOL isTapping;
    BOOL hasTapped;
}

@property (nonatomic, strong) id globalMonitor;
@property (nonatomic, strong) id localMonitor;
@property (nonatomic, assign) BOOL enableHotKey;
@property (nonatomic, strong) NSTimer *timerDelay;
@property (nonatomic, strong) NSTimer *timerDisabelHotKey;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, weak) IBOutlet NSMenu *statusMenu;
@property (nonatomic, strong) AZAppsSwitchWindow *window;

- (void)listenEvents;
- (void)showStatusBar;
- (void)hideStatusBar;

@end


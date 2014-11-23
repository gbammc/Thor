//
//  AZPreferenceWindowController.h
//  AppShortCut
//
//  Created by Alvin on 13-10-18.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AZPreferenceWindowController : NSWindowController

+ (AZPreferenceWindowController *)sharedPreferenceWindowController;
+ (NSString *)nibName;

- (void)setupToolbar;
- (void)addFlexibeSpacer;
- (void)addView:(NSView *)view label:(NSString *)label;
- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image;

- (void)toggleActivePreferenceView:(NSToolbarItem *)toolbarItem;
- (void)loadViewForIdentifier:(NSString *)identifier;

@end

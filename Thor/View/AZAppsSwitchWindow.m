//
//  AZAppsSwitchWindow.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppsSwitchWindow.h"
#import "AZAppModel.h"
#import "AZAppsManager.h"
#import "AZResourceManager.h"
#import "AZAppIconView.h"

#pragma mark - AZAppsLaunchContentView

CGFloat const iconMargin = 30.0f;
CGFloat const iconOriginY = 20.0f;
CGFloat const iconDefaultSize = 100.0f;

@interface AZAppsLaunchContentView : NSView

@property (nonatomic, strong) NSArray *apps;

@end

@implementation AZAppsLaunchContentView

- (id)initWithFrame:(NSRect)frameRect apps:(NSArray *)apps_ {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.apps = apps_;
        NSInteger appsCount = 0;
        for (id obj in self.apps)
            if (![obj isEqualTo:[NSNull null]]) appsCount++;
        
        CGFloat originX = iconMargin;
        CGFloat iconSize = iconDefaultSize;
        if (frameRect.size.width < (appsCount * (iconSize + iconMargin) + iconMargin)) {
            iconSize = (frameRect.size.width - iconMargin * (appsCount + 1)) / appsCount;
        }
        
        for (NSUInteger i = 0; i < self.apps.count; i++) {
            if ([self.apps[i] isEqualTo:[NSNull null]]) continue;
            
            AZAppModel *app = [NSKeyedUnarchiver unarchiveObjectWithData:self.apps[i]];
            AZAppIconView *appIcon = [[AZAppIconView alloc] initWithFrame:(NSRect){
                originX,
                iconOriginY,
                iconSize,
                iconSize
            } index:i];
            originX += (iconSize + iconMargin);
        
            appIcon.image = [AZResourceManager imageNamed:app.appIconPath inBundle:[NSBundle bundleWithURL:app.appBundleURL]];
            [appIcon.image setSize:NSMakeSize(iconSize, iconSize)];
            [self addSubview:appIcon];
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSBezierPath * path;
    path = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:15 yRadius:15];
    [[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3] set];
    [path fill];
}

@end

#pragma mark - AZAppsSwitchWindow

@implementation AZAppsSwitchWindow

- (NSRect)calculateRect:(NSInteger)appsCount {
    NSRect screenRect = [self getScreenResolution];
    CGFloat iconSize = iconDefaultSize;
    if (screenRect.size.width < (appsCount * (iconSize + iconMargin) + iconMargin)) {
        iconSize = (screenRect.size.width - iconMargin * (appsCount + 1)) / appsCount;
    }
    NSRect rect = (NSRect){
        (screenRect.size.width - appsCount * (iconSize + iconMargin) - iconMargin) / 2,
        (screenRect.size.height - iconSize - iconOriginY * 2) / 2,
        appsCount * (iconSize + iconMargin) + iconMargin,
        iconSize + iconOriginY * 2,
    };
    return rect;
}

- (id)init {
    self.apps = [[AZResourceManager sharedInstance] readSelectedAppsList];
    selectedAppsCount = 0;
    
    for (id obj in self.apps)
        if (![obj isEqualTo:[NSNull null]]) 
            selectedAppsCount++;
    
    NSRect rect = [self calculateRect:selectedAppsCount];
    
    return [self initWithContentRect:rect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
}

- (id)initWithContentRect:(NSRect)contentRect 
                styleMask:(NSUInteger)aStyle 
                  backing:(NSBackingStoreType)bufferingType 
                    defer:(BOOL)flag {
	if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag]) {
		[self setMovableByWindowBackground:NO];
		[self setHasShadow:YES];
		[self setLevel:NSNormalWindowLevel];
        [self setShowsResizeIndicator:NO];
        [self setBackgroundColor:[NSColor clearColor]];
		[self setOpaque:NO];
        
        AZAppsLaunchContentView *contentView = [[AZAppsLaunchContentView alloc] initWithFrame:contentRect apps:self.apps];
        [self setContentView:contentView];
    }
	return self;
}

- (void)refresh {
    self.apps = [[AZResourceManager sharedInstance] readSelectedAppsList];
    selectedAppsCount = 0;
    
    for (id obj in self.apps)
        if (![obj isEqualTo:[NSNull null]]) 
            selectedAppsCount++;
    
    NSRect rect = [self calculateRect:selectedAppsCount];
    [self setFrame:rect display:YES animate:YES];
    AZAppsLaunchContentView *contentView = [[AZAppsLaunchContentView alloc] initWithFrame:rect apps:self.apps];
    [self setContentView:contentView];
}

- (void)fadeIn {
    if (self.isFadingOut) return;
    CGFloat alpha = 0;
    [self setAlphaValue:alpha];
    
    // show the window above other apps, but without activate itself
    [self setLevel:NSScreenSaverWindowLevel + 1];
    [self orderFront:nil];
    
    for (int x = 0; x < 10; x++) {
        alpha += 0.1;
        [self setAlphaValue:alpha];
        [NSThread sleepForTimeInterval:0.02];
    }
    self.isShown = YES;
}

- (void)fadeOut {
    if (self.isFadingOut || !self.isShown) return;
    
    self.isFadingOut = YES;
    CGFloat alpha = 1;
    [self setAlphaValue:alpha];
    [self makeKeyAndOrderFront:self];
    
    for (int x = 0; x < 10; x++) {
        alpha -= 0.1;
        [self setAlphaValue:alpha];
        [NSThread sleepForTimeInterval:0.02];
    }
    self.isShown = NO;
    self.isFadingOut = NO;
}

- (void)setContentView:(NSView *)aView {
    aView.wantsLayer            = YES;
    aView.layer.frame           = aView.frame;
    aView.layer.cornerRadius    = 20.0;
    aView.layer.masksToBounds   = YES;
    
    [super setContentView:aView];
}

- (NSRect)getScreenResolution {
    NSArray *screenArray = [NSScreen screens];
    NSScreen *mainScreen = [NSScreen mainScreen];
    NSUInteger screenCount = screenArray.count;
    
    for (NSUInteger index = 0; index < screenCount; index++) {
        NSScreen *screen = screenArray[index];
        NSRect screenRect = [screen visibleFrame];
        if (mainScreen == screen) return screenRect;
    }
    return mainScreen.frame;
}

// prevent resize window
- (NSSize)windowWillResize:(NSWindow *) window toSize:(NSSize)newSize {
	if([window showsResizeIndicator])
		return newSize; //resize happens
	else
		return [window frame].size; //no change
}

- (BOOL)windowShouldZoom:(NSWindow *)window toFrame:(NSRect)newFrame {
	//let the zoom happen iff showsResizeIndicator is YES
	return [window showsResizeIndicator];
}

@end

//
//  AZPreferenceWindowController.m
//  AppShortCut
//
//  Created by Alvin on 13-10-18.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZPreferenceWindowController.h"

@interface AZPreferenceWindowController ()

@property (nonatomic, strong) NSMutableArray *toolbarIdentifiers;
@property (nonatomic, strong) NSMutableDictionary *toolbarViews;
@property (nonatomic, strong) NSMutableDictionary *toolbarItems;
@property (nonatomic, strong) NSView *contentSubview;

@end


@implementation AZPreferenceWindowController

+ (AZPreferenceWindowController *)sharedPreferenceWindowController {
    static AZPreferenceWindowController *sharedPreferenceWindowController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPreferenceWindowController = [[self alloc] initWithWindowNibName:[self nibName]];
    });
    return sharedPreferenceWindowController;
}

+ (NSString *)nibName {
    return @"AZPreferenceWindowController";
}

- (id)initWithWindow:(NSWindow *)window {
    if ((self = [super initWithWindow:window])) {
        self.toolbarIdentifiers = [[NSMutableArray alloc] init];
        self.toolbarViews = [[NSMutableDictionary alloc] init];
        self.toolbarItems = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)windowDidLoad
{    
    NSWindow *window = 
    [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1000,1000)
                                styleMask:(NSTitledWindowMask |
                                           NSClosableWindowMask |
                                           NSMiniaturizableWindowMask)
                                  backing:NSBackingStoreBuffered
                                    defer:YES];
    [self setWindow:window];
    self.contentSubview = [[NSView alloc] initWithFrame:[[[self window] contentView] frame]];
    [self.contentSubview setAutoresizingMask:(NSViewMinYMargin | NSViewWidthSizable)];
    [[[self window] contentView] addSubview:self.contentSubview];
    [[self window] setShowsToolbarButton:NO];
}

- (void)setupToolbar {
    
}

- (void)addToolbarItemForIdentifier:(NSString *)identifier label:(NSString *)label image:(NSImage *)image selector:(SEL)selector {
    [self.toolbarIdentifiers addObject:identifier];
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    [item setLabel:label];
    [item setImage:image];
    [item setTarget:self];
    [item setAction:selector];
    
    (self.toolbarItems)[identifier] = item;
}

- (void)addFlexibeSpacer {
    [self addToolbarItemForIdentifier:NSToolbarFlexibleSpaceItemIdentifier label:nil image:nil selector:nil];
}

- (void)addView:(NSView *)view label:(NSString *)label {
    [self addView:view label:label image:[NSImage imageNamed:label]];
}

- (void)addView:(NSView *)view label:(NSString *)label image:(NSImage *)image {
    if (view == nil) return;

    NSString *identifier = [label copy];
    (self.toolbarViews)[identifier] = view;
    [self addToolbarItemForIdentifier:identifier
                                label:label 
                                image:image 
                             selector:@selector(toggleActivePreferenceView:)];
}

- (void)showWindow:(id)sender {
    [self window];
    
    [self.toolbarIdentifiers removeAllObjects];
    [self.toolbarViews removeAllObjects];
    [self.toolbarItems removeAllObjects];
    [self setupToolbar];
    
    if (!_toolbarIdentifiers.count) return;
    
    if ([[self window] toolbar] == nil) {
        NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"AZPreferenceToolbar"];
        [toolbar setAllowsUserCustomization:NO];
        [toolbar setAutosavesConfiguration:NO];
        [toolbar setSizeMode:NSToolbarSizeModeDefault];
        [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
        [toolbar setDelegate:(id<NSToolbarDelegate>)self];
        [[self window] setToolbar:toolbar];
    }
    
    NSString *firstIdentifer = ([sender isKindOfClass:[NSString class]]) ? ((NSString *)sender) : ((self.toolbarIdentifiers)[0]);
    [[[self window] toolbar] setSelectedItemIdentifier:firstIdentifer];
    [self displayViewForIdentifier:firstIdentifer];
    [[self window] center];
    
    [super showWindow:sender];
}

#pragma mark - Toolbar

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    return self.toolbarIdentifiers;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)willBeInserted{
	return (self.toolbarItems)[identifier];
}

- (void)toggleActivePreferenceView:(NSToolbarItem *)toolbarItem {
    [self displayViewForIdentifier:[toolbarItem itemIdentifier]];
}

- (void)displayViewForIdentifier:(NSString *)identifier {
    // Find the view we want to display.
    NSView *newView = (self.toolbarViews)[identifier];
    
    // See if there are any visible views.
    NSView *oldView = nil;
    if([[self.contentSubview subviews] count] > 0) {
        // Get a list of all of the views in the window. Usually at this
        // point there is just one visible view. But if the last fade
        // hasn't finished, we need to get rid of it now before we move on.
        NSEnumerator *subviewsEnum = [[self.contentSubview subviews] reverseObjectEnumerator];
        
        // The first one (last one added) is our visible view.
        oldView = [subviewsEnum nextObject];
        
        // Remove any others.
        NSView *reallyOldView = nil;
        while((reallyOldView = [subviewsEnum nextObject]) != nil){
            [reallyOldView removeFromSuperviewWithoutNeedingDisplay];
        }
    }
    
    if (![newView isEqualTo:oldView]) {
        NSRect frame = [newView bounds];
        frame.origin.y = NSHeight([self.contentSubview frame]) - NSHeight([newView bounds]);
        [newView setFrame:frame];
        [self.contentSubview addSubview:newView];
        [[self window] setInitialFirstResponder:newView];
        
        [oldView removeFromSuperviewWithoutNeedingDisplay];
        [newView setHidden:NO];
        [[self window] setFrame:[self frameForView:newView] display:YES animate:YES];
        [[self window] setTitle:[(self.toolbarItems)[identifier] label]];
    }
}

- (void)loadViewForIdentifier:(NSString *)identifier {
    if (self.toolbarItems.count == 0) [self showWindow:identifier];
    
    [[[self window] toolbar] setSelectedItemIdentifier:identifier];
    [self displayViewForIdentifier:identifier];
}

- (NSRect)frameForView:(NSView *)view {
    NSRect windowFrame = [[self window] frame];
    NSRect contentRect = [[self window] contentRectForFrameRect:windowFrame];
    CGFloat windowTitleAndToolbarHeight = NSHeight(windowFrame) - NSHeight(contentRect);
    
    windowFrame.size.height = NSHeight([view frame]) + windowTitleAndToolbarHeight;
    windowFrame.size.width = NSWidth([view frame]);
    windowFrame.origin.y = NSMaxY([[self window] frame]) - NSHeight(windowFrame);
    
    return windowFrame;
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString *key = [theEvent charactersIgnoringModifiers];
    if (([theEvent modifierFlags] & NSCommandKeyMask) && [key isEqualToString:@"w"]) {
        [self close];
    } else {
        [super keyDown:theEvent];
    }
}

@end

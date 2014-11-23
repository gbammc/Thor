//
//  AZConfigView.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZConfigView.h"
#import "AZAppDelegate.h"
#import "AZHotKeyManager.h"
#import "AZAppDelegate.h"

@implementation AZConfigView

- (void)awakeFromNib {
    // observe prefs changed
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver:self
               forKeyPath:@"modifyKey"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:@"loginItemEnable"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:@"shownInStatusBar"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [defaults addObserver:self
               forKeyPath:@"delayInterval"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"modifyKey"] || [keyPath isEqualToString:@"delayInterval"]) {
        [[AZHotKeyManager sharedInstance] registerHotKey];
        [((AZAppDelegate *)[NSApplication sharedApplication].delegate) listenEvents];
        
    } else  if ([keyPath isEqualToString:@"loginItemEnable"]) {
        if ([[change objectForKey:@"new"] boolValue]) {
            [self addAppAsLoginItem];
        } else {
            [self removeAppFromLoginItem];
        }
        
    } else if ([keyPath isEqualToString:@"shownInStatusBar"]) {
        AZAppDelegate *delegate = ((AZAppDelegate *)[NSApplication sharedApplication]);
        if ([[change objectForKey:@"new"] boolValue]) {
            [delegate showStatusBar];
        } else {
            [delegate hideStatusBar];
        }
    }
}

#pragma mark - login item

- (void)addAppAsLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of 
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}	
    
	CFRelease(loginItems);
}

- (void)removeAppFromLoginItem {
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath]; 
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
		for(int i = 0 ; i < [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                                 objectAtIndex:i];
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(__bridge NSURL*)url path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
	}
}

- (IBAction)exit:(id)sender {
    [NSApp terminate:self];
}

@end

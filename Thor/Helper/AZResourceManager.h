//
//  AZResourceManager.h
//  AppShortCut
//
//  Created by Alvin on 13-10-17.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZResourceManager : NSObject {
    NSMutableDictionary *resourceDict;
    NSDictionary *resourceOberrideList;
    NSString *resourceOverrideFolder;
}

+ (id)sharedInstance;
+ (NSImage *)imageNamed:(NSString *)name;
+ (NSImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

- (NSString *)pathForImageNamed:(NSString *)name;

- (void)saveSelectedApps:(NSArray *)apps;
- (NSArray *)readSelectedAppsList;
- (void)cacheAllApps:(NSArray *)apps;
- (NSArray *)readCachedApps;

@end

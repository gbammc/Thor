//
//  AZAppsManager.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppsManager.h"
#import "AZAppModel.h"
#import "AZResourceManager.h"

@implementation AZAppsManager

static AZAppsManager *AZAm = nil;

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AZAm = [[[self class] alloc] init];
    });
    return AZAm;
}

#pragma mark - get Apps

- (NSArray *)getApps {
    // Depreted method, 
//    NSArray *arr = nil;
//    LSInit(1);
//    _LSCopyAllApplicationURLs(&arr);
    
    NSMutableArray *appsArray = [NSMutableArray array];
    NSArray *cachedAppsInfo = [[AZResourceManager sharedInstance] readCachedApps];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    void (^blockSearchApps)(void) = ^{
        // finder
        NSString *finderPath = @"/System/Library/CoreServices/";
        if ([fileManager fileExistsAtPath:finderPath]) {
            NSArray *temp = [fileManager contentsOfDirectoryAtPath:finderPath error:nil];
            for (NSString *name in temp) {
                if ([name isEqualToString:@"Finder.app"]) {
                    AZAppModel *app = [[AZAppModel alloc] init];
                    NSBundle *appBundle = [NSBundle bundleWithPath:[finderPath stringByAppendingPathComponent:name]];
                    NSString *displayName = [[appBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                    NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
                    if (displayName == nil) {
                        displayName = [[name componentsSeparatedByString:@".app"] objectAtIndex:0];
                    }
                    app.appBundleURL = appBundle.bundleURL;
                    app.appName = name;
                    app.appDisplayName = displayName;
                    app.appIconPath = iconName;
                    app.isSysApp = YES;
                    [appsArray addObject:app];
                    break;
                }
            }
        }
        // installed apps
        NSString *appsPath = @"/Applications/";
        if (([fileManager fileExistsAtPath:appsPath])) {
            NSArray *apps = [fileManager contentsOfDirectoryAtPath:appsPath error:nil];
            NSInteger index = appsArray.count;
            for (NSString *name in apps) {
                if ([name hasSuffix:@".app"]) {
                    AZAppModel *app = [[AZAppModel alloc] init];
                    NSBundle *appBundle = [NSBundle bundleWithPath:[appsPath stringByAppendingPathComponent:name]];
                    NSString *displayName = [[appBundle localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
                    NSString *iconName = [[appBundle infoDictionary] objectForKey:@"CFBundleIconFile"];
                    if (displayName == nil) {
                        displayName = [[name componentsSeparatedByString:@".app"] objectAtIndex:0];
                    }
                    app.appBundleURL = appBundle.bundleURL;
                    app.appName = name;
                    app.appDisplayName = displayName;
                    app.appIconPath = iconName;
                    app.isSysApp = NO;
                    app.index = index++;
                    [appsArray addObject:app];
                } 
            }
        }
        
        [[AZResourceManager sharedInstance] cacheAllApps:appsArray];
    };
    
    // reload apps in background
    if (cachedAppsInfo != nil && cachedAppsInfo.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), blockSearchApps);
        return cachedAppsInfo;
    }
    // init
    blockSearchApps();
    return [NSArray arrayWithArray:appsArray];
}

@end

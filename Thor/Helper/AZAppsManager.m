//
//  AZAppsManager.m
//  Thor
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppsManager.h"
#import "AZAppModel.h"
#import "AZResourceManager.h"

@interface AZAppsManager ()

@property (nonatomic, strong) NSMetadataQuery *appsQuery;
@property (nonatomic, copy) void(^getAppsCallback)(NSArray<AZAppModel *> *);

@end

@implementation AZAppsManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static AZAppsManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
        [manager setupQuery];
    });
    return manager;
}

- (void)setupQuery
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"kMDItemContentType == 'com.apple.application-bundle'"];
    
    self.appsQuery = [[NSMetadataQuery alloc] init];
    [self.appsQuery setSearchScopes:@[@"/Applications", @"/System/Library/CoreServices"]];
    [self.appsQuery setPredicate:pred];
}

#pragma mark - get Apps

- (void)getApps:(void(^)(NSArray<AZAppModel *> *))callback
{
    self.getAppsCallback = callback;
    
    [self startQuery];
}

- (void)startQuery
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    [self.appsQuery startQuery];
}

- (void)queryFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    NSArray *apps = [AZAppModel appsFromMetadataItems:self.appsQuery.results];
    
    [[AZResourceManager sharedInstance] cacheAllApps:apps];
    
    if (self.getAppsCallback) {
        self.getAppsCallback(apps);
    }
}

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

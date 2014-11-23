//
//  AZResourceManager.m
//  AppShortCut
//
//  Created by Alvin on 13-10-17.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZResourceManager.h"

NSString *sysIconBundle;
id AZRez;

@implementation AZResourceManager

+ (id)sharedInstance {
    if (!AZRez) {
        sysIconBundle = @"/System/Library/CoreServices/CoreTypes.bundle";
        AZRez = [[[self class] allocWithZone:nil] init];
    }
    return AZRez;
}

+ (NSImage *)imageNamed:(NSString *)name {
    return [[self sharedInstance] imageNamed:name];
}

+ (NSImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
	return [[self sharedInstance] imageNamed:name inBundle:bundle];
}

- (NSImage *)sysIconNamed:(NSString *)name {
    NSString *path = [[NSBundle bundleWithPath:sysIconBundle] pathForResource:name ofType:@"icns"];
    if (!path) return nil;
    return [[NSImage alloc] initByReferencingFile:path];
}

- (NSString *)resourceNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    return nil;
}

- (NSString *)pathForImageNamed:(NSString *)name {
    id locator = [resourceDict objectForKey:name];
    return [self pathWithLocatorInformation:locator];
}

- (NSImage *)imageNamed:(NSString *)name {
    return [self imageNamed:name inBundle:nil];
}

- (NSImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
    if (!name) { return nil; }
    
    NSImage *image = [NSImage imageNamed:name];
    if ((!image && resourceOberrideList)) {
        NSString *file = [resourceOberrideList objectForKey:name];
        if (file) {
            image = [[NSImage alloc] initByReferencingFile:[resourceOverrideFolder stringByAppendingPathComponent:file]];
        }
        [image setName:name];
    }

    // bundle for image name
    NSString *compositeName = [NSString stringWithFormat:@"%@:%@", [bundle bundleIdentifier], name];
    NSImage *bundleImage = [NSImage imageNamed:compositeName];
    if (!bundleImage) {
        bundleImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:name]];
        [bundleImage setName:compositeName];
    }
    if (!image && bundle) { image = bundleImage; }
    
    if (image) { return image; }
    
    id locator = [resourceDict objectForKey:name];
    if ([locator isKindOfClass:[NSNull class]]) { return nil; }
    if (locator) {
        image = [self imageWithLocatorInfomation:locator];
    } else if (!image && ([name hasPrefix:@"/"] || [name hasPrefix:@"~"])) {
        NSString *path = [name stringByStandardizingPath];
        if ([[NSImage imageUnfilteredFileTypes] containsObject:[path pathExtension]]) {
            image = [[NSImage alloc] initByReferencingFile:path];
        } else {
            image = [[NSWorkspace sharedWorkspace] iconForFile:path];
        }
    } else {
        image = [self sysIconNamed:name];
        if (!image) {
            image = [self imageWithLocatorInfomation:[NSDictionary dictionaryWithObjectsAndKeys:name, @"bundle", nil]];
        }
    }
    if (!image && [locator isKindOfClass:[NSString class]]) {
        image = [self imageNamed:locator];
    }
    
    if (!image) {
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@Image", name]);
        if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			image = [self performSelector:selector];
#pragma clang diagnostic pop
        }
    }
    
    if (!image) {
        [resourceDict setObject:[NSNull null] forKey:name];
    } else {
        [image setName:name];
    }
    return image;
}

- (NSString *)pathWithLocatorInformation:(id)locator {
    NSString *path = nil;
    if ([locator isKindOfClass:[NSString class]]) {
        if (![locator length]) return nil;
        if ([locator hasPrefix:@"["]) {
            NSArray *components = [[locator substringFromIndex:1] componentsSeparatedByString:@"] :"];
            if ([components count] > 1) {
                return [self pathWithLocatorInformation:[NSDictionary dictionaryWithObjectsAndKeys:components[0], @"bundle", components[1], @"resource", nil]];
            }
        } else {
            return locator;
        }
    } else if ([locator isKindOfClass:[NSArray class]]) {
        NSUInteger i;
        for (i = 0; i < [(NSArray *)locator count]; i++) {
            path = [self pathWithLocatorInformation:locator[i]];
            if (path) break;
        }
    } else if ([locator isKindOfClass:[NSDictionary class]]) {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        NSString *bundleID = [locator objectForKey:@"bundle"];
        
        NSBundle *bundle = [NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundleID]];
        NSString *resourceName = [locator objectForKey:@"resource"];
        NSString *subPath = [locator objectForKey:@"path"];
        
        NSString *basePath = [bundle bundlePath];
        
        if (resourceName) {
            path = [bundle pathForResource:[resourceName stringByDeletingPathExtension] ofType:[resourceName pathExtension]];
        } else if (subPath) {
            path = [basePath stringByAppendingPathComponent:subPath];
        }
    }
    return path;
}

- (NSImage *)imageWithLocatorInfomation:(id)locator {
    NSImage *image = nil;
    if ([locator isKindOfClass:[NSArray class]]) {
        NSUInteger i;
        for (i = 0; i <[(NSArray *)locator count]; i++) {
            image = [self imageWithLocatorInfomation:locator[i]];
            if (image) break;
        }
    } else {
        image = [[NSImage alloc] initWithContentsOfFile:[self pathWithLocatorInformation:locator]];
    }
    
    if (!image && [locator isKindOfClass:[NSDictionary class]]) {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        NSString *bundleID = [locator objectForKey:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:[workspace absolutePathForAppBundleWithIdentifier:bundleID]];
        
        if (bundle != nil) {
            image = [workspace iconForFile:[bundle bundlePath]];
        } else {
            if ([locator objectForKey:@"type"]) {
                image = [workspace iconForFileType:[locator objectForKey:@"type"]];
            }
        }
    }
    return image;
}

- (NSString *)documentPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = @"~/Library/Application Support/FastSwitcher/";
    folder = [folder stringByExpandingTildeInPath];
    
    if ([fileManager fileExistsAtPath: folder] == NO) {
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folder;
}

NSString *selectedAppsFileName = @"appsData";
// 保存已选应用
- (void)saveSelectedApps:(NSArray *)apps {
    NSData *data =[NSKeyedArchiver archivedDataWithRootObject:apps];
    NSString *documentsPath = [self documentPath];
    NSString *fileInDocuments = [documentsPath stringByAppendingPathComponent:selectedAppsFileName];
    [data writeToFile:fileInDocuments atomically:YES];
}
// 读取已选应用
- (NSArray *)readSelectedAppsList {
    NSString *documentsPath = [self documentPath];
    NSString *fileInDocuments = [documentsPath stringByAppendingPathComponent:selectedAppsFileName];
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:fileInDocuments]];
}

NSString *cacheAppsFileName = @"CacheApps";
// 缓存全部应用信息
- (void)cacheAllApps:(NSArray *)apps {
    NSData *data =[NSKeyedArchiver archivedDataWithRootObject:apps];
    NSString *documentsPath = [self documentPath];
    NSString *fileInDocuments = [documentsPath stringByAppendingPathComponent:cacheAppsFileName];
    [data writeToFile:fileInDocuments atomically:YES];
}
// 读取全部应用信息
- (NSArray *)readCachedApps {
    NSString *documentsPath = [self documentPath];
    NSString *fileInDocuments = [documentsPath stringByAppendingPathComponent:cacheAppsFileName];
    return [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:fileInDocuments]];
}

@end

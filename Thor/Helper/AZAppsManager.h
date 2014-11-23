//
//  AZAppsManager.h
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZAppsManager : NSObject

+ (id)sharedInstance;

- (NSArray *)getApps;

@end

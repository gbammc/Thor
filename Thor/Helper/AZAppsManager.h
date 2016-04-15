//
//  AZAppsManager.h
//  Thor
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AZAppModel;

@interface AZAppsManager : NSObject

+ (instancetype)sharedInstance;

- (void)getApps:(void(^)(NSArray<AZAppModel *> *apps))callback;

@end

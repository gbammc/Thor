//
//  AZAppModel.h
//  Thor
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZAppModel : NSObject <NSCoding>

@property (nonatomic, strong) NSURL     *appBundleURL;
@property (nonatomic, copy) NSString    *appName;
@property (nonatomic, copy) NSString    *appDisplayName;
@property (nonatomic, copy) NSString    *appIconPath;
@property (nonatomic) BOOL              isSysApp;
@property (nonatomic) NSInteger         index;

+ (NSArray<AZAppModel *> *)appsFromMetadataItems:(NSArray *)items;

@end

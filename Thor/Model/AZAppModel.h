//
//  AZAppModel.h
//  FastSwitcher
//
//  Created by Alvin on 13-10-22.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZAppModel : NSObject <NSCoding>

@property (nonatomic, strong) NSURL     *appBundleURL;
@property (nonatomic, strong) NSString  *appName;
@property (nonatomic, strong) NSString  *appDisplayName;
@property (nonatomic, strong) NSString  *appIconPath;
@property (nonatomic) BOOL              isSysApp;
@property (nonatomic) NSInteger         index;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end

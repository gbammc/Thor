//
//  AZHotKeyManager.h
//  Thor
//
//  Created by Alvin on 13-10-19.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZHotKeyManager : NSObject

+ (id)sharedInstance;

- (void)registerHotKeys;
- (void)registerHotKeys:(NSArray *)apps;
- (void)unregisterHotKeys;

@end

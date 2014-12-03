//
//  AZAppsListView.m
//  Thor
//
//  Created by Alvin on 12/2/14.
//  Copyright (c) 2014 AlvinZhu. All rights reserved.
//

#import "AZAppsListView.h"
#import "AZAppsManager.h"
#import "AZAppModel.h"
#import "AZResourceManager.h"
#import "AZHotKeyManager.h"

@interface AZAppsListView ()
@property (nonatomic, strong) NSArray *appsList;
@end

@implementation AZAppsListView 

- (void)awakeFromNib
{
    self.appsList = [[AZAppsManager sharedInstance] getApps];
}

@end

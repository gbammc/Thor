//
//  AZPrefsWindowController.m
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZPrefsWindowController.h"

@interface AZPrefsWindowController ()

@end

@implementation AZPrefsWindowController

- (void)setupToolbar {
    [self addView:self.appsSelectionView label:@"General"];
    [self addView:self.configView label:@"Advanced"];
    [self addView:self.aboutView label:@"Updates"];
}

@end

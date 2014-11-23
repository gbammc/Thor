//
//  AZPrefsWindowController.h
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AZPreferenceWindowController.h"
#import "AZAppsSelectionView.h"
#import "AZConfigView.h"
#import "AZAboutView.h"

@interface AZPrefsWindowController : AZPreferenceWindowController

@property (strong, nonatomic) IBOutlet AZAppsSelectionView *appsSelectionView;
@property (strong, nonatomic) IBOutlet AZConfigView *configView;
@property (strong, nonatomic) IBOutlet AZAboutView *aboutView;

@end

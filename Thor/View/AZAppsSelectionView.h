//
//  AZAppsSelectionView.h
//  FastSwitcher
//
//  Created by Alvin on 13-10-24.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AZAppsSelectionView : NSView

@property (nonatomic, weak) IBOutlet NSPopUpButton *app1;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app2;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app3;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app4;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app5;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app6;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app7;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app8;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app9;
@property (nonatomic, weak) IBOutlet NSPopUpButton *app0;

- (IBAction)selectApp:(id)sender;

@end

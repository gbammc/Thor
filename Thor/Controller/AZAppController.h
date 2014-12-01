//
//  AZAppController.h
//  AppShortCut
//
//  Created by Alvin on 13-10-17.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZAppController : NSObject

//@property (nonatomic, strong) NSMenu *statusMenu;

- (IBAction)showPreferencePanel:(id)sender;
- (IBAction)showAboutPanel:(id)sender;
- (IBAction)exit:(id)sender;

@end

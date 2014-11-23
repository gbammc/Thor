//
//  AZAppIconView.h
//  AppShortCut
//
//  Created by Alvin on 13-10-21.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AZAppIconView : NSImageView

@property (nonatomic) NSUInteger index;

- (id)initWithFrame:(NSRect)frameRect index:(NSUInteger)index;

@end

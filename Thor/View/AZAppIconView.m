//
//  AZAppIconView.m
//  AppShortCut
//
//  Created by Alvin on 13-10-21.
//  Copyright (c) 2013年 Alvin. All rights reserved.
//

#import "AZAppIconView.h"

CGFloat const indexLabelWidth = 40.0f;

#pragma mark - IconindexLabel

#define ALPHA           (0.8)
#define BLACK_COLOR     ([NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:ALPHA])
#define WHITE_COLOR     ([NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:ALPHA])
#define STROKE_WIDTH    (5.0)
#define WIDTH           (10.0)

@interface IconIndexView : NSView

@property (nonatomic) NSUInteger index;

@end

@implementation IconIndexView

- (id)initWithFrame:(NSRect)frameRect index:(NSUInteger)index {
    self = [super initWithFrame:frameRect];
    if (self) {
        // index label
        NSTextField *indexLabel = [[NSTextField alloc] initWithFrame:(NSRect){
            10,
            -4,
            frameRect.size.width,
            frameRect.size.height
        }];
        indexLabel.left = 0;
        [indexLabel setBezeled:NO];
        [indexLabel setDrawsBackground:NO];
        [indexLabel setEditable:NO];
        [indexLabel setSelectable:NO];
        [indexLabel setBackgroundColor:[NSColor clearColor]];
        [indexLabel setFont:[NSFont fontWithName:@"Arial Bold" size:28]];
        [indexLabel setTextColor:[NSColor whiteColor]];
        [indexLabel setAlignment:NSCenterTextAlignment];
        [indexLabel setStringValue:[NSString stringWithFormat:@"%lu", index]];
        [self addSubview:indexLabel];
    }
    return self;
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    NSBezierPath *path;
    NSRect rectangle;
    
    // 外环
    rectangle = [self bounds];
    rectangle.origin.x += STROKE_WIDTH / 2.0;
    rectangle.origin.y += STROKE_WIDTH / 2.0;
    rectangle.size.width -= STROKE_WIDTH;
    rectangle.size.height -= STROKE_WIDTH;
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:rectangle];
    [path setLineWidth:STROKE_WIDTH];
    [WHITE_COLOR setStroke];
    [path stroke];
    [path closePath];
    
    // 内圆
    rectangle = [self bounds];
    rectangle.origin.x += (STROKE_WIDTH);
    rectangle.origin.y += (STROKE_WIDTH);
    rectangle.size.width -= STROKE_WIDTH * 2;
    rectangle.size.height -= STROKE_WIDTH * 2;
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithOvalInRect:rectangle];
    [BLACK_COLOR setFill];
    [path fill];
}

@end

@implementation AZAppIconView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect index:(NSUInteger)index {
    self = [super initWithFrame:frameRect];
    if (self) {		
        index = (index == 9) ? 0 : index + 1;
        IconIndexView *indexView = [[IconIndexView alloc] initWithFrame:(NSRect){
            self.frame.size.width - indexLabelWidth, 
            0,
            indexLabelWidth, 
            indexLabelWidth
        } index:index];
        
        [self addSubview:indexView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
}

@end

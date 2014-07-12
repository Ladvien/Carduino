//
//  drawView.m
//  Carduino
//
//  Created by Ladvien on 7/8/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "drawView.h"

@implementation drawView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 4.0);
    CGContextSetStrokeColorWithColor(context,[UIColor blueColor].CGColor);
    CGRect rectangle = CGRectMake(5,5,50,50);
    CGContextAddEllipseInRect(context, rectangle);
    CGContextStrokePath(context);
    NSLog(@"Blah!!");
}


@end

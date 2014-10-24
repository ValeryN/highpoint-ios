//
//  HPSegmentControl.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.10.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSegmentControl.h"
#import "Constants.h"

@implementation HPSegmentControl

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = rect.size.height/2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:0.f/255.f green:203.f/255.f blue:254.f/255.f alpha:1.f].CGColor;
    self.layer.masksToBounds = YES;
    UIFont *font = FUTURAPT_BOOK_15;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

@end

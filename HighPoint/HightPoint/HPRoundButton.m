//
//  HPRoundButton.m
//  HighPoint
//
//  Created by Eugene on 09/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRoundButton.h"


@implementation HPRoundButton


- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = rect.size.height/2;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithRed:80.f/255.f green:227.f/255.f blue:194.f/255.f alpha:1.f].CGColor;
    self.titleEdgeInsets = UIEdgeInsetsMake(0, 10.f, 0, 10.f);
}

@end

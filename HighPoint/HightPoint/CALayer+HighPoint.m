//
// Created by Eugene on 29.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "CALayer+HighPoint.h"


@implementation CALayer (HighPoint)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
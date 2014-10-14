//
//  HPRoundView.m
//  HighPoint
//
//  Created by Eugene on 10/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRoundView.h"

@implementation HPRoundView

- (void)drawRect:(CGRect)rect{
    self.layer.cornerRadius = self.cornerRadius;
}

@end

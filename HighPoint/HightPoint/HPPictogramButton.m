//
//  HPPictogramButton.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 22.10.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPictogramButton.h"

@implementation HPPictogramButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.alpha = 0.4f;
    } else {
        self.alpha = 1.0f;
    }
}

@end

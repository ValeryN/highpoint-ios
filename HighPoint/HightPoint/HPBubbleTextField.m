//
//  HPBubbleTextField.m
//  HighPoint
//
//  Created by Andrey Anisimov on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBubbleTextField.h"

@implementation HPBubbleTextField
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        @weakify(self);
        self.backSpaceSignal = [RACSubject subject];
    }

    return self;
}



- (void)deleteBackward {
    [self.backSpaceSignal sendNext:@YES];
    [super deleteBackward];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

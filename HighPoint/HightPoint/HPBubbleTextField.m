//
//  HPBubbleTextField.m
//  HighPoint
//
//  Created by Andrey Anisimov on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBubbleTextField.h"

@implementation HPBubbleTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)deleteBackward {
    [super deleteBackward];
    
    if ([_backSpaceDelegate respondsToSelector:@selector(backSpaceTap)]){
        [_backSpaceDelegate backSpaceTap];
    }
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

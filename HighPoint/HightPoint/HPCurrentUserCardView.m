//
//  HPCurrentUserCardView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserCardView.h"
#import "User.h"
#import "UIView+HighPoint.h"

#define USERCARD_ROUND_RADIUS 5

@implementation HPCurrentUserCardView {
    User *currentUser;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) initObjects
{
    [self.avatarBgImageView hp_roundViewWithRadius: USERCARD_ROUND_RADIUS];
}


- (IBAction)pointBtnTap:(id)sender {
    NSLog(@"profile tap");
    if (_delegate == nil)
        return;
    [_delegate switchButtonPressed];
}

@end

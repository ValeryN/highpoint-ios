//
//  HPSpinnerView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 22.10.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSpinnerView.h"

@implementation HPSpinnerView

- (void)drawRect:(CGRect)rect {
    UIView *refreshLoadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    refreshLoadingView.backgroundColor = [UIColor clearColor];
    UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Spinner"]];
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0.0;
    rotationAnimation.toValue = @(M_PI * 2.0f);
    rotationAnimation.duration = 1.0f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    [spinner.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [refreshLoadingView addSubview:spinner];
    [self addSubview:refreshLoadingView];
}


@end

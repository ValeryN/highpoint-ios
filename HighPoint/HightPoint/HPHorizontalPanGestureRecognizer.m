//
// Created by Eugene on 12.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPHorizontalPanGestureRecognizer.h"


@implementation HPHorizontalPanGestureRecognizer

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = self;
    }

    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view];
    return fabs(velocity.y) < fabs(velocity.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
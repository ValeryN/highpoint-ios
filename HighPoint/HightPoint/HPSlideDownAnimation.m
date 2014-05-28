//
//  HPSlideDownAnimation.m
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSlideDownAnimation.h"
@interface HPSlideDownAnimation() {
    CGFloat _startScale, _completionSpeed;
    id<UIViewControllerContextTransitioning> _context;
    UIView *_transitioningView;
    UIPinchGestureRecognizer *_pinchRecognizer;
}
@end
@implementation HPSlideDownAnimation
@synthesize viewForInteraction = _viewForInteraction;

-(instancetype)initWithNavigationController:(UINavigationController *)controller {
    self = [super init];
    if (self) {
        self.navigationController = controller;
        _completionSpeed = 0.2;
        
        
    }
    return self;
}
-(void)setViewForInteraction:(UIView *)viewForInteraction {
    if (_viewForInteraction && [_viewForInteraction.gestureRecognizers containsObject:_pinchRecognizer]) [_viewForInteraction removeGestureRecognizer:_pinchRecognizer];
    
    _viewForInteraction = viewForInteraction;
    //[_viewForInteraction addGestureRecognizer:_pinchRecognizer];
}
#pragma mark - Animated Transitioning

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //Get references to the view hierarchy
   }

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}

-(void)animationEnded:(BOOL)transitionCompleted {
    self.interactive = NO;
}

@end


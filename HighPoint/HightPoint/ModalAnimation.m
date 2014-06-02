//
//  ModalDismissAnimation.m
//  TransitionTest
//
//  Created by Tyler Tillage on 7/3/13.
//  Copyright (c) 2013 CapTech. All rights reserved.
//

//==============================================================================

#import "ModalAnimation.h"

//==============================================================================

@implementation ModalAnimation {
    UIView *_coverView;
    NSArray *_constraints;
}

//==============================================================================

#pragma mark - Animated Transitioning

//==============================================================================

- (void) animateTransition: (id<UIViewControllerContextTransitioning>)transitionContext
{
    //The view controller's view that is presenting the modal view
    UIView *containerView = [transitionContext containerView];

    switch (self.type)
    {
        case AnimationTypePresent:
        {
            //The modal view itself
            UIView *modalView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
            //Using autolayout to position the modal view
            modalView.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:modalView];

            //Move off of the screen so we can slide it up
            CGRect endFrame = modalView.frame;
            modalView.frame = CGRectMake(endFrame.origin.x, containerView.frame.size.height, endFrame.size.width, endFrame.size.height);
            [containerView bringSubviewToFront:modalView];
            
            //Animate using spring animation
            [UIView animateWithDuration: 0.9
                                  delay: 0.0
                 usingSpringWithDamping: 0.8
                  initialSpringVelocity: 1.0
                                options: 0
                             animations: ^
                                    {
                                        modalView.frame = endFrame;
                                    }
                             completion: ^(BOOL finished)
                                    {
                                        [transitionContext completeTransition:YES];
                                    }];
        }
        break;
            
        case AnimationTypeDismiss:
        {
            //The modal view itself
            UIView *modalView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
            
            //Grab a snapshot of the modal view for animating
            UIView *snapshot = [modalView snapshotViewAfterScreenUpdates:NO];
            snapshot.frame = modalView.frame;
            [containerView addSubview:snapshot];
            [containerView bringSubviewToFront:snapshot];
            [modalView removeFromSuperview];

            //Animate using keyframe animation
            CGRect endFrame = snapshot.frame;
            endFrame = CGRectMake(endFrame.origin.x, 568.0, endFrame.size.width, endFrame.size.height);
            [containerView bringSubviewToFront:modalView];
            
            //Animate using spring animation
            [UIView animateWithDuration:0.9 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:0 animations:^{
                snapshot.frame = endFrame;
            } completion:^(BOOL finished) {
                [snapshot removeFromSuperview];
                [transitionContext completeTransition:YES];
            }];
        }
    }
}

//==============================================================================

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.type == AnimationTypePresent) return 1.0;
    else if (self.type == AnimationTypeDismiss) return 1.75;
    else return [super transitionDuration:transitionContext];
}

//==============================================================================

@end

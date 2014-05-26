//
//  ScaleAnimation.h
//  HighPoint
//
//  Created by Andrey Anisimov on 15.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "BaseAnimation.h"

@interface ScaleAnimation : BaseAnimation <UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign) UINavigationController *navigationController;
@property (nonatomic, strong) UIView *viewForInteraction;

-(instancetype)initWithNavigationController:(UINavigationController *)controller;
-(void)handlePinch:(UIPinchGestureRecognizer *)pinch;

@end

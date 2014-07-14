//
//  HPCurrentUserCardOrPoint.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserCardOrPoint.h"
#import "HPCurrentUserPointView.h"
#import "HPCurrentUserCardView.h"

@implementation HPCurrentUserCardOrPoint

- (id) init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    _isUserPointView = YES;
    
    return self;
}

//==============================================================================

- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPCurrentUserPointView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPCurrentUserPointView class]] == NO)
        return nil;
    
    HPCurrentUserPointView* newPoint = (HPCurrentUserPointView*)nibs[0];
    newPoint.delegate = delegate;
  //  [newPoint initObjects];
    return newPoint;
}

//==============================================================================

- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPCurrentUserCardView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPCurrentUserCardView class]] == NO)
        return nil;
    
    HPCurrentUserCardView* newCard = (HPCurrentUserCardView*)nibs[0];
   newCard.delegate = delegate;
  //  [newCard initObjects];
    
    return newCard;
}

//==============================================================================

- (BOOL) switchUserPoint
{
    _isUserPointView = !_isUserPointView;
    return _isUserPointView;
}

//==============================================================================

- (BOOL) isUserPoint
{
    return _isUserPointView;
}

//==============================================================================


@end

//
//  HPUserCardOrPoint.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardOrPoint.h"

//==============================================================================

@implementation HPUserCardOrPoint

//==============================================================================

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
    _isUserPointView = YES;
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPUserPointView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPUserPointView class]] == NO)
        return nil;
    
    HPUserPointView* newPoint = (HPUserPointView*)nibs[0];
    newPoint.delegate = delegate;
    [newPoint initObjects];

    return newPoint;
}

//==============================================================================

- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    _isUserPointView = NO;
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPUserCardView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPUserCardView class]] == NO)
        return nil;
    
    HPUserCardView* newCard = (HPUserCardView*)nibs[0];
    newCard.delegate = delegate;
    [newCard initObjects];

    return newCard;
}

//==============================================================================

- (BOOL) isUserPoint
{
    return _isUserPointView;
}

//==============================================================================

@end

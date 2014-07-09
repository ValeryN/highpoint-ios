//
//  HPUserCardOrPoint.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardOrPoint.h"
#import "UserPoint.h"

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

- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPUserPointView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPUserPointView class]] == NO)
        return nil;
    
    HPUserPointView* newPoint = (HPUserPointView*)nibs[0];
    newPoint.delegate = delegate;
    newPoint.pointDelegate = delegate;
    newPoint.name.text = user.name;
    newPoint.details.text = [NSString stringWithFormat:@"%@ %@", user.dateOfBirth, user.cityId];
    UserPoint *point = user.point;
    newPoint.pointText.text = point.pointText;
    [newPoint initObjects];

    return newPoint;
}

//==============================================================================

- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPUserCardView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPUserCardView class]] == NO)
        return nil;
    
    HPUserCardView* newCard = (HPUserCardView*)nibs[0];
    newCard.delegate = delegate;
    newCard.name.text = user.name;
    newCard.details.text = [NSString stringWithFormat:@"%@ %@", user.dateOfBirth, user.cityId];
    [newCard initObjects];

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

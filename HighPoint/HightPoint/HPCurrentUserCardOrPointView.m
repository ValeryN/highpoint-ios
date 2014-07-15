//
//  HPCurrentUserCardOrPointView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserCardOrPointView.h"

@implementation HPCurrentUserCardOrPointView

- (id) initWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    self = [super init];
    if (self == nil)
        return nil;
    
    [self switchSidesWithCardOrPoint: cardOrPoint delegate: delegate user: (User*) user];
    
    return self;
}

//==============================================================================

- (void) switchSidesWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    if (cardOrPoint == nil)
        return;
    
    [_childContainerView removeFromSuperview];
    if (![cardOrPoint isUserPoint])
        _childContainerView = [cardOrPoint userCardWithDelegate: delegate user:user];
    else
        _childContainerView = [cardOrPoint userPointWithDelegate: delegate user:user];
    [self addSubview: _childContainerView];
}


@end

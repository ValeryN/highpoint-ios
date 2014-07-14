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
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    self = [super init];
    if (self == nil)
        return nil;
    
    [self switchSidesWithCardOrPoint: cardOrPoint delegate: delegate];
    
    return self;
}

//==============================================================================

- (void) switchSidesWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    if (cardOrPoint == nil)
        return;
    
    [_childContainerView removeFromSuperview];
    if (![cardOrPoint isUserPoint])
        _childContainerView = [cardOrPoint userCardWithDelegate: delegate];
    else
        _childContainerView = [cardOrPoint userPointWithDelegate: delegate];
    [self addSubview: _childContainerView];
}


@end

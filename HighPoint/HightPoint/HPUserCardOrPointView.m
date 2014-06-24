//
//  HPUserCardOrPointView.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardOrPointView.h"

//==============================================================================

@implementation HPUserCardOrPointView

//==============================================================================

- (id) initWithCardOrPoint: (HPUserCardOrPoint*) cardOrPoint
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    self = [super init];
    if (self == nil)
        return nil;

    [self switchSidesWithCardOrPoint: cardOrPoint delegate: delegate];

    return self;
}

//==============================================================================

- (void) switchSidesWithCardOrPoint: (HPUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    if (cardOrPoint == nil)
        return;
    
    [_childContainerView removeFromSuperview];
    if ([cardOrPoint isUserPoint])
        _childContainerView = [cardOrPoint userCardWithDelegate: delegate];
    else
        _childContainerView = [cardOrPoint userPointWithDelegate: delegate];

    [self addSubview: _childContainerView];
    CGRect rect = _childContainerView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    _childContainerView.frame = rect;
    
    rect = self.frame;
    rect.size = _childContainerView.frame.size;
    self.frame = rect;
}

//==============================================================================

@end

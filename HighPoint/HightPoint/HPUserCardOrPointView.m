//
//  HPUserCardOrPointView.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardOrPointView.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

#define CONSTRAINT_HEIGHT_FOR_BGIMAGE 340

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

    [self fixUserCardConstraint];

    [self addSubview: _childContainerView];
    [self fixFrame];
}

//==============================================================================

- (void) fixFrame
{
    CGRect rect = _childContainerView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0;
    _childContainerView.frame = rect;
    
    rect = self.frame;
    rect.size = _childContainerView.frame.size;
    self.frame = rect;
}

//==============================================================================

- (void) fixUserCardConstraint
{
    if ((![UIDevice hp_isWideScreen]) &&
        ([_childContainerView isKindOfClass:[HPUserCardView class]]))
    {
        HPUserCardView* v = (HPUserCardView*)_childContainerView;
        NSArray* cons = v.backgroundAvatar.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if (consIter.firstAttribute == NSLayoutAttributeHeight)
                consIter.constant = CONSTRAINT_HEIGHT_FOR_BGIMAGE;
        }
    }
}

//==============================================================================

@end

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
#define CONSTRAINT_TOP_FOR_AVATAR 68
#define CONSTRAINT_TOP_FOR_AVATAR_GROUP 28

//==============================================================================

@implementation HPUserCardOrPointView

//==============================================================================

- (id) initWithCardOrPoint: (HPUserCardOrPoint*) cardOrPoint user:(User *) user
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    self = [super init];
    if (self == nil)
        return nil;

    [self switchSidesWithCardOrPoint: cardOrPoint user:user delegate: delegate];

    return self;
}

//==============================================================================

- (void) switchSidesWithCardOrPoint: (HPUserCardOrPoint*) cardOrPoint user: (User *) user
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    if (cardOrPoint == nil)
        return;
    
    [_childContainerView removeFromSuperview];
    if ([cardOrPoint isUserPoint])
        _childContainerView = [cardOrPoint userCardWithDelegate: delegate user:user];
    else
        _childContainerView = [cardOrPoint userPointWithDelegate: delegate user:user];

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
    if (![UIDevice hp_isWideScreen])
        rect.size.height = CONSTRAINT_HEIGHT_FOR_BGIMAGE;
    _childContainerView.frame = rect;
        
    rect = self.frame;
    rect.size = _childContainerView.frame.size;
    self.frame = rect;
}

//==============================================================================

- (void) fixUserCardConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        if ([_childContainerView isKindOfClass:[HPUserCardView class]])
        {
            HPUserCardView* v = (HPUserCardView*)_childContainerView;
            NSArray* cons = v.backgroundAvatar.constraints;
            for (NSLayoutConstraint* consIter in cons)
            {
                if (consIter.firstAttribute == NSLayoutAttributeHeight)
                    consIter.constant = CONSTRAINT_HEIGHT_FOR_BGIMAGE;
            }
        }
        if ([_childContainerView isKindOfClass:[HPUserPointView class]])
        {
            HPUserPointView* v = (HPUserPointView*)_childContainerView;
            NSArray* cons = v.constraints;
            for (NSLayoutConstraint* consIter in cons)
            {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == v.avatarGroup) &&
                (consIter.secondItem == v)
                )
                consIter.constant = CONSTRAINT_TOP_FOR_AVATAR_GROUP;
            }
        }
    }
}

//==============================================================================

@end

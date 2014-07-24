//
//  HPCurrentUserCardOrPointView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserCardOrPointView.h"
#import "UIDevice+HighPoint.h"
#import "HPCurrentUserCardView.h"
#import "HPCurrentUserPointView.h"

#define CONSTRAINT_HEIGHT_FOR_BGIMAGE 340
#define CONSTRAINT_TOP_FOR_AVATAR 68
#define CONSTRAINT_TOP_FOR_AVATAR_GROUP 28

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


- (void) switchSidesWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    if (cardOrPoint == nil)
        return;
    
    [_childContainerView removeFromSuperview];
    if (![cardOrPoint isUserPoint]) {
        self.frame =CGRectMake(self.frame.origin.x, _childContainerView.frame.origin.y, self.frame.size.width, 416);
        _childContainerView = [cardOrPoint userCardWithDelegate: delegate user:user];
    } else {
        self.frame =CGRectMake(self.frame.origin.x, _childContainerView.frame.origin.y, self.frame.size.width, 602);
        _childContainerView = [cardOrPoint userPointWithDelegate: delegate user:user];
        _childContainerView.frame = CGRectMake(_childContainerView.frame.origin.x, _childContainerView.frame.origin.y, _childContainerView.frame.size.width, _childContainerView.frame.size.height + 251);
        
    }
    [self fixUserCardConstraint];
    [self addSubview: _childContainerView];
    [self fixFrame];
}

#pragma mark - modal views
- (void) addPointOptionsViewToCard : (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate
{
    [cardOrPoint addPointInfoView:delegate];
}


#pragma mark - constrains

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


- (void) fixUserCardConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        if ([_childContainerView isKindOfClass:[HPCurrentUserCardView class]])
        {
            HPCurrentUserCardView* v = (HPCurrentUserCardView*)_childContainerView;
            NSArray* cons = v.avatarBgImageView.constraints;
            for (NSLayoutConstraint* consIter in cons)
            {
                if (consIter.firstAttribute == NSLayoutAttributeHeight)
                    consIter.constant = CONSTRAINT_HEIGHT_FOR_BGIMAGE;
            }
        }
        if ([_childContainerView isKindOfClass:[HPCurrentUserPointView class]])
        {
            HPCurrentUserPointView* v = (HPCurrentUserPointView*)_childContainerView;
            NSArray* cons = v.constraints;
            for (NSLayoutConstraint* consIter in cons)
            {
                if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == v.avatar) &&
                    (consIter.secondItem == v)
                    )
                    consIter.constant = CONSTRAINT_TOP_FOR_AVATAR_GROUP;
            }
        }
    }
}

@end

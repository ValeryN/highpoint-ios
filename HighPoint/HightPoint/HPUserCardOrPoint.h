//
//  HPUserCardOrPoint.h
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <Foundation/Foundation.h>

#import "HPUserCardView.h"
#import "HPUserPointView.h"
#import "User.h"

//==============================================================================

@interface HPUserCardOrPoint : NSObject
{
    BOOL _isUserPointView;
}

- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user;
- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user;
- (BOOL) isUserPoint;
- (BOOL) switchUserPoint;

@end

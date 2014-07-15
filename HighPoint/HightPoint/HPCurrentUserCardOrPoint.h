//
//  HPCurrentUserCardOrPoint.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCardOrPointProtocol.h"
#import "User.h"

@interface HPCurrentUserCardOrPoint : NSObject
{
    BOOL _isUserPointView;
}

- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user;
- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user;
- (BOOL) isUserPoint;
- (BOOL) switchUserPoint;



@end

//
//  HPCurrentUserCardOrPoint.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCardOrPointProtocol.h"

@interface HPCurrentUserCardOrPoint : NSObject
{
    BOOL _isUserPointView;
}

- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate;
- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate;
- (BOOL) isUserPoint;
- (BOOL) switchUserPoint;



@end

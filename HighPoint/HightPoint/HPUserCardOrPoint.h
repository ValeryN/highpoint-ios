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

//==============================================================================

@interface HPUserCardOrPoint : NSObject
{
    BOOL _isUserPointView;
}

- (HPUserCardView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate;
- (HPUserPointView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate;
- (BOOL) isUserPoint;

@end

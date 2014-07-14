//
//  HPCurrentUserCardOrPointView.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPCurrentUserCardOrPoint.h"
#import "UserCardOrPointProtocol.h"

@interface HPCurrentUserCardOrPointView : UIView
{
    UIView* _childContainerView;
}

- (id) initWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate;

- (void) switchSidesWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate;


@end

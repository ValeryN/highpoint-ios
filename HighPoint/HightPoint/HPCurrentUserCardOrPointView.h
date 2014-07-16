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
#import "User.h"

@interface HPCurrentUserCardOrPointView : UIView
{
    UIView* _childContainerView;
}

- (id) initWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user;

- (void) switchSidesWithCardOrPoint: (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user;

- (void) addPointOptionsViewToCard : (HPCurrentUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate;

@end

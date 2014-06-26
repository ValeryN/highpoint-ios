//
//  HPUserCardOrPointView.h
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

#import "HPUserCardOrPoint.h"

//==============================================================================

@interface HPUserCardOrPointView : UIView
{
    UIView* _childContainerView;
}

- (id) initWithCardOrPoint: (HPUserCardOrPoint*) cardOrPoint
                  delegate: (NSObject<UserCardOrPointProtocol>*) delegate;

- (void) switchSidesWithCardOrPoint: (HPUserCardOrPoint*) cardOrPoint
                           delegate: (NSObject<UserCardOrPointProtocol>*) delegate;

@end

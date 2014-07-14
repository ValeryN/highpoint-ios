//
//  HPCurrentUserCardView.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardOrPointProtocol.h"

@interface HPCurrentUserCardView : UIView

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;


@end

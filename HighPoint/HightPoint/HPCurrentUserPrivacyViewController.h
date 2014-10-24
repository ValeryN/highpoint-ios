//
//  HPCurrentUserUICollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "City.h"

@class HPCurrentUserViewController;


@interface HPCurrentUserPrivacyViewController : UIViewController
@property (nonatomic, retain) User* currentUser;
@end

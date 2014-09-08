//
//  HPAvatar.h
//  HighPoint
//
//  Created by Michael on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

@class User;

//==============================================================================

@interface HPAvatarView : UIView
+ (HPAvatarView *)avatarViewWithUser:(User *)user;

@property (nonatomic, weak) User* user;
@end

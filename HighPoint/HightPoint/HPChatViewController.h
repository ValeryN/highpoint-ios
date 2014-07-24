//
//  HPChatViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatarLittleView.h"

@interface HPChatViewController : UIViewController


@property (strong, nonatomic) HPAvatarLittleView *avatar;
@property (strong, nonatomic) UIView *avatarView;
@property (strong, nonatomic) UITextField *searchTextField;

@end

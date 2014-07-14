//
//  HPCurrentUserPointView.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardOrPointProtocol.h"

@interface HPCurrentUserPointView : UIView

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;


@property (weak, nonatomic) IBOutlet UIButton *userProfileBtn;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UIView *avatar;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;
@property (weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgAvatarImageView;


@end

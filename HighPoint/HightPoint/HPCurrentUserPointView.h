//
//  HPCurrentUserPointView.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardOrPointProtocol.h"
#import "HPAvatarView.h"

@interface HPCurrentUserPointView : UIView <UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;

@property (nonatomic, weak) HPAvatarView* avatar;
@property (weak, nonatomic) IBOutlet UIView *avatarView;
@property (weak, nonatomic) IBOutlet UIButton *userProfileBtn;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;
@property (weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgAvatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *publishPointBtn;
@property (weak, nonatomic) IBOutlet UIButton *deletePointBtn;

//add point
@property (weak, nonatomic) IBOutlet UIView *pointOptionsView;
@property (weak, nonatomic) IBOutlet UISlider *pointTimeSlider;
@property (weak, nonatomic) IBOutlet UILabel *pointTimeInfo;
@property (weak, nonatomic) IBOutlet UIButton *sharePointBtn;

//delete point
@property (weak, nonatomic) IBOutlet UIView *deletePointView;
@property (weak, nonatomic) IBOutlet UILabel *deletePointInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletePointModalBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelDeleteModalBtn;




- (void) initObjects;
- (void) setBlurForAvatar;
- (void) setCropedAvatar :(UIImage *)image;

@end

//
//  HPCurrentUserPointViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPCurrentUserPointViewController : UIViewController <UIGestureRecognizerDelegate, UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *userProfileBtn;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UIView *avatar;
@property (weak, nonatomic) IBOutlet UITextView *pointTextView;
@property (weak, nonatomic) IBOutlet UILabel *pointInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgAvatarImageView;


- (IBAction)userProfileBtnTap:(id)sender;

@end

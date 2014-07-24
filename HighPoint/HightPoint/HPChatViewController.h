//
//  HPChatViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatarLittleView.h"

@interface HPChatViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic) HPAvatarLittleView *avatar;
@property (strong, nonatomic) UIView *avatarView;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;



//bottom view
@property (weak, nonatomic) IBOutlet UIView *msgBottomView;
@property (weak, nonatomic) IBOutlet UIButton *msgAddBtn;
@property (weak, nonatomic) IBOutlet UITextView *msgTextView;


@end

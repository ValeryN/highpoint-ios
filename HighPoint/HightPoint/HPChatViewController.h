//
//  HPChatViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 24.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatarLittleView.h"
#import "User.h"
#import "HPUserInfoViewController.h"
#import "RACFetchedTableViewController.h"


@interface HPChatViewController : RACFetchedTableViewController <UITextViewDelegate>
@property (strong, nonatomic) Contact *contact;
@property (nonatomic) CGFloat offsetX;

@end

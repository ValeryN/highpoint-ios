//
//  HPChatListViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPChatTableViewCell.h"

@interface HPChatListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, HPChatTableViewCellDelegate>


@property (weak, nonatomic) IBOutlet UITableView *chatListTableView;
@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UIView *coverView;


@end

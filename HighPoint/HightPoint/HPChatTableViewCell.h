//
//  HPChatTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLSwipeForOptionsCell.h"
#import "HPAvatarView.h"
#import "HPAvatarLittleView.h"
#import "Contact.h"
#import "RACTableViewController.h"


@interface HPChatTableViewCell : TLSwipeForOptionsCell <UIScrollViewDelegate,RACTableViewCellProtocol>
@property(nonatomic, strong) UITapGestureRecognizer *tap_Gesture;

- (IBAction)deleteBtnTap:(id)sender;


@end

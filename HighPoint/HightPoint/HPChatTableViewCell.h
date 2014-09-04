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


@protocol HPChatTableViewCellDelegate <TLSwipeForOptionsCellDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

- (void)deleteChat:(TLSwipeForOptionsCell *)cell;
- (void)cellDidTap:(TLSwipeForOptionsCell *)cell;

@end

@interface HPChatTableViewCell : TLSwipeForOptionsCell <UIScrollViewDelegate,RACTableViewCellProtocol>



- (void) fillCell : (Contact *) contact;
- (void) setup;

@end

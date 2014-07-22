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

@protocol HPChatTableViewCellDelegate <TLSwipeForOptionsCellDelegate>

- (void)deleteChat:(TLSwipeForOptionsCell *)cell;

@end

@interface HPChatTableViewCell : TLSwipeForOptionsCell <UIScrollViewDelegate>

@property (nonatomic, weak) id<HPChatTableViewCellDelegate> delegate;



@property (nonatomic, weak) HPAvatarView* avatar;
@property (weak, nonatomic) IBOutlet UIView *avatarView;


@property (weak, nonatomic) IBOutlet UIView *msgToYouView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeAndLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentMsgLabel;

@property (weak, nonatomic) IBOutlet UIView *msgCountView;

@property (nonatomic, weak) HPAvatarLittleView* myAvatar;
@property (weak, nonatomic) IBOutlet UIView *msgFromMyself;
@property (weak, nonatomic) IBOutlet UILabel *currentUserMsgLabel;
@property (weak, nonatomic) IBOutlet UIView *myAvatarView;


- (void) configureCell;

@end

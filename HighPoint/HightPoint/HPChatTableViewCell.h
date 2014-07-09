//
//  HPChatTableViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLSwipeForOptionsCell.h"

@protocol HPChatTableViewCellDelegate <TLSwipeForOptionsCellDelegate>

- (void)deleteChat:(TLSwipeForOptionsCell *)cell;

@end

@interface HPChatTableViewCell : TLSwipeForOptionsCell <UIScrollViewDelegate>

@property (nonatomic, weak) id<HPChatTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIView *msgCountView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userAgeAndLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentMsgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserImageView;
@property (weak, nonatomic) IBOutlet UILabel *currentUserMsgLabel;

@end

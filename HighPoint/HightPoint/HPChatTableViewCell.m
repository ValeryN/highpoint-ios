//
//  HPChatTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatTableViewCell.h"
#import "UILabel+HighPoint.h"
#import "UIButton+HighPoint.h"


@implementation HPChatTableViewCell

- (void)awakeFromNib
{
    [self setup];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setup {
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + [self returnCatchWidth], CGRectGetHeight(self.bounds));
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *scrollViewButtonView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - [self returnCatchWidth], 0, [self returnCatchWidth], CGRectGetHeight(self.bounds))];
    self.scrollViewButtonView = scrollViewButtonView;
    [self.scrollView addSubview:scrollViewButtonView];
    
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    // Set up our buttons
    
    UIView *buttonBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self returnCatchWidth], CGRectGetHeight(self.bounds))];
    buttonBackView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1.0f];
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.exclusiveTouch = YES;
    
    [deleteButton setTitle:NSLocalizedString(@"DELETE_BTN_TITLE", nil) forState:UIControlStateNormal];
    [deleteButton setTitle:NSLocalizedString(@"DELETE_BTN_TITLE", nil) forState:UIControlStateHighlighted];
    
    deleteButton.frame = CGRectMake(0, 0, [self returnCatchWidth], CGRectGetHeight(self.bounds));
    [deleteButton addTarget:self action:@selector(deleteChat:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBackView addSubview:deleteButton];
    [deleteButton hp_tuneForDeleteBtnInContactList];
    [self.scrollViewButtonView addSubview:buttonBackView];

    UIView *scrollViewContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];//CGRectGetHeight(self.bounds)
    [self.scrollView addSubview:scrollViewContentView];
    scrollViewContentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0f];
    self.scrollViewContentView = scrollViewContentView;

    
    [self.avatarView removeFromSuperview];
    [self.scrollViewContentView addSubview: self.avatarView];
    
    [self.msgCountView removeFromSuperview];
    [self.scrollViewContentView addSubview: self.msgCountView];
    
    [self.msgToYouView removeFromSuperview];
    [self.scrollViewContentView addSubview: self.msgToYouView];
    
    [self.msgFromMyself removeFromSuperview];
    [self.scrollViewContentView addSubview:self.msgFromMyself];
    }

- (int) returnCatchWidth {
    return 120;
}
-(void)prepareForReuse {
    [super prepareForReuse];
    //[self removePanGesture];
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)deleteChat:(TLSwipeForOptionsCell *)cell {
    NSLog(@"delete");
}


- (void) configureCell {
    [self.userNameLabel hp_tuneForUserNameInContactList];
    [self.userAgeAndLocationLabel hp_tuneForUserDetailsInContactList];
    [self.currentMsgLabel hp_tuneForMessageInContactList];
    [self.currentUserMsgLabel hp_tuneForMessageInContactList];
    self.avatar = [HPAvatarView createAvatar: [UIImage imageNamed:@"img_sample1.png"]];
    [self.avatarView addSubview: self.avatar];
    self.currentMsgLabel.hidden = YES;
    self.myAvatar = [HPAvatarLittleView createAvatar: [UIImage imageNamed:@"img_sample1.png"]];
    [self.myAvatarView addSubview: self.myAvatar];
    [self fixAvatarConstraint];
    
}

#pragma mark - constrains

- (void) fixAvatarConstraint
{
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.avatarView addConstraint:[NSLayoutConstraint constraintWithItem: self.avatarView
                                                                attribute: NSLayoutAttributeWidth
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: nil
                                                                attribute: NSLayoutAttributeNotAnAttribute
                                                               multiplier: 1.0
                                                                 constant: self.avatarView.frame.size.width]];
    
    [self.avatarView addConstraint:[NSLayoutConstraint constraintWithItem: self.avatarView
                                                                attribute: NSLayoutAttributeHeight
                                                                relatedBy: NSLayoutRelationEqual
                                                                   toItem: nil
                                                                attribute: NSLayoutAttributeNotAnAttribute
                                                               multiplier: 1.0
                                                                 constant: self.avatarView.frame.size.height]];
}

@end

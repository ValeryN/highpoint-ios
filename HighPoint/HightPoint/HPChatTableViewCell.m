//
//  HPChatTableViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPChatTableViewCell.h"
#import "UILabel+HighPoint.h"
#import "User.h"
#import "Message.h"
#import "City.h"
#import "DataStorage.h"

@interface HPChatTableViewCell ()
@property(nonatomic, weak) id <HPChatTableViewCellDelegate> delegate;

@property(nonatomic, strong) UITapGestureRecognizer *tap_Gesture;


@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, weak) IBOutlet UIView *scrollViewContentView;
@property(nonatomic, weak) IBOutlet UIView *scrollViewButtonView;

@property(weak, nonatomic) IBOutlet HPAvatarView *avatarView;

@property(weak, nonatomic) IBOutlet UIView *msgToYouView;
@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *userAgeAndLocationLabel;
@property(weak, nonatomic) IBOutlet UILabel *currentMsgLabel;

@property(weak, nonatomic) IBOutlet UIView *msgCountView;
@property(weak, nonatomic) IBOutlet UILabel *msgCountLabel;

@property(nonatomic, weak) IBOutlet HPAvatarView *myAvatar;
@property(weak, nonatomic) IBOutlet UIView *msgFromMyself;
@property(weak, nonatomic) IBOutlet UILabel *currentUserMsgLabel;

@property(strong, nonatomic) IBOutlet UIView *sepTop;
@property(strong, nonatomic) IBOutlet UIView *sepBottom;
@end

@implementation HPChatTableViewCell

- (void)awakeFromNib {
    [self setup];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setup {
    self.scrollView.delegate = self;

    [self addPanGesture];
}

- (int)returnCatchWidth {
    return 120;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.sepTop.hidden = YES;
    self.sepBottom.hidden = YES;
    if (self.scrollView.contentOffset.x != 0) {
        [self.scrollView setContentOffset:CGPointZero animated:NO];
    }

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 120) {
        self.sepTop.hidden = YES;
        self.sepBottom.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.sepTop.hidden = NO;
    self.sepBottom.hidden = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.x == 0.0) {
        self.sepTop.hidden = YES;
        self.sepBottom.hidden = YES;
    }
}


- (void)deleteChat:(TLSwipeForOptionsCell *)cell {
    NSLog(@"delete");
    if ([self.delegate respondsToSelector:@selector(deleteChat:)]) {
        [self.delegate deleteChat:self];
    }
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}


- (void)fillCell:(Contact *)contact {
    [self.userNameLabel hp_tuneForUserNameInContactList];
    [self.userAgeAndLocationLabel hp_tuneForUserDetailsInContactList];
    [self.currentMsgLabel hp_tuneForMessageInContactList];
    [self.currentUserMsgLabel hp_tuneForMessageInContactList];
    [self.msgCountLabel hp_tuneForMessageCountInContactList];
    self.msgCountView.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:102.0 / 255.0 blue:112.0 / 255.0 alpha:1.0f];
    self.msgCountView.layer.cornerRadius = 12;
    self.avatarView.user = contact.user;
    self.myAvatar.user = [[DataStorage sharedDataStorage] getCurrentUser];
    self.userNameLabel.text = contact.user.name;
    NSString *cityName = contact.user.city.cityName ? contact.user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userAgeAndLocationLabel.text = [NSString stringWithFormat:@"%@ лет, %@", contact.user.age, cityName];
    if ([contact.user.userId intValue] == [contact.lastmessage.destinationId intValue]) {
        self.currentMsgLabel.hidden = YES;
        self.msgFromMyself.hidden = NO;
        self.currentMsgLabel.text = contact.lastmessage.text;
    } else {
        self.currentMsgLabel.hidden = NO;
        self.msgFromMyself.hidden = YES;
        self.currentUserMsgLabel.text = contact.lastmessage.text;
    }

}


#pragma mark -
#pragma mark - UITapGestureRecognizer Methods

- (void)addPanGesture {
    if (self.tap_Gesture == nil) {
        self.tap_Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];

        self.tap_Gesture.cancelsTouchesInView = NO;
        self.tap_Gesture.numberOfTouchesRequired = 1;
        self.tap_Gesture.numberOfTapsRequired = 1;
        [self.tap_Gesture setDelegate:self];
        [self.contentView addGestureRecognizer:self.tap_Gesture];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    CGPoint p = [recognizer locationInView:self.scrollViewButtonView];
    if (p.x < 0) {
        if ([self.delegate respondsToSelector:@selector(cellDidTap:)])
            [self.delegate cellDidTap:self];
    }
}


- (void)bindViewModel:(Contact *)viewModel {
    [self fillCell:viewModel];
}


@end

//
//  HPMainViewListTableViewCell.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatarView.h"
#import "UserPoint.h"


@class User;
@interface HPMainViewListTableViewCell : UITableViewCell <UIGestureRecognizerDelegate> {
    BOOL handleLongTap;
}

+ (void) makeCellReleased;

- (void) configureCell:(User*) user;
- (void) vibrateThePoint;
- (void) showPoint;
- (void) hidePoint;

@property (nonatomic, weak) IBOutlet UIImageView *showPointButton;
@property (nonatomic, weak) IBOutlet UIView *showPointGroup;


@property (nonatomic, weak) IBOutlet UIImageView *userImage;
@property (nonatomic, weak) IBOutlet UIImageView *userImageBorder;
@property (nonatomic, weak) IBOutlet UILabel *firstLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondLabel;
@property (nonatomic, weak) IBOutlet UILabel *point;
@property (nonatomic, weak) IBOutlet UIView *mainInfoGroup;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;

@property (nonatomic, strong) IBOutlet HPAvatarView *avatar;

@property (weak, nonatomic) IBOutlet UIView *topSeparatorView;
@property (weak, nonatomic) IBOutlet UIView *bottomSeparatorView;

@end

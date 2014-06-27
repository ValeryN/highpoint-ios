//
//  HPMainViewListTableViewCell.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatar.h"

@class User;
@interface HPMainViewListTableViewCell : UITableViewCell

+ (void) makeCellReleased;

- (void) makeAnonymous;
- (void) configureCell:(User*) user;
- (void) vibrateThePoint;
- (void) showPoint;
- (void) hidePoint;

@property (nonatomic, strong) IBOutlet UIImageView *showPointButton;
@property (nonatomic, strong) IBOutlet UIView *showPointGroup;

@property (nonatomic, strong) IBOutlet HPAvatar *avatar;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;
@property (nonatomic, strong) IBOutlet UILabel *point;
@property (nonatomic, strong) IBOutlet UIView *mainInfoGroup;

@end

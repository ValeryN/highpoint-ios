//
//  HPMainViewListTableViewCell.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@interface HPMainViewListTableViewCell : UITableViewCell

+ (void) makeCellReleased;

- (void) makeAnonymous;
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

@end

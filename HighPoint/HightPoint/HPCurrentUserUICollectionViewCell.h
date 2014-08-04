//
//  HPCurrentUserUICollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "City.h"

@interface HPCurrentUserUICollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *yourProfilelabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *userInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *visibleBtn;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UIButton *invisibleBtn;
@property (weak, nonatomic) IBOutlet UILabel *visibilityInfoLabel;



- (void) configureCell : (User *) user ;

@end

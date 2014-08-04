//
//  HPCurrentUserUICollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserUICollectionViewCell.h"
#import "UILabel+HighPoint.h"
#import <QuartzCore/QuartzCore.h>


@implementation HPCurrentUserUICollectionViewCell



- (void) configureCell : (User *) user {
    self.yourProfilelabel.text = NSLocalizedString(@"YOUR_PROFILE", nil);
    [self.yourProfilelabel hp_tuneForUserCardName];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    [self.userInfoLabel hp_tuneForUserCardName];
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    [self setVisibility:user.visibility];
    
}


- (void) setVisibility : (NSNumber *) visibility {
    if ([visibility isEqualToNumber:@1]) {
        self.visibleBtn.selected = YES;
        self.invisibleBtn.selected = NO;
        self.lockBtn.selected = NO;
        self.visibilityInfoLabel.hidden = NO;
    }
    if ([visibility isEqualToNumber:@2]) {
        self.visibleBtn.selected = NO;
        self.invisibleBtn.selected = YES;
        self.lockBtn.selected = NO;
        self.visibilityInfoLabel.hidden = NO;
        [self.visibilityInfoLabel hp_tuneForUserVisibilityInfo];
        self.visibilityInfoLabel.text = NSLocalizedString(@"VISIBILITY_INFO_LABEL", nil);
        self.userInfoLabel.text = NSLocalizedString(@"YOUR_PROFILE_INVISIBLE", nil);
        
    }
    if ([visibility isEqualToNumber:@3]) {
        self.visibleBtn.selected = NO;
        self.invisibleBtn.selected = NO;
        self.lockBtn.selected = YES;
        self.visibilityInfoLabel.hidden = NO;
        [self.visibilityInfoLabel hp_tuneForUserVisibilityInfo];
        self.visibilityInfoLabel.text = NSLocalizedString(@"VISIBILITY_INFO_LABEL", nil);
        self.userInfoLabel.text = NSLocalizedString(@"YOUR_PROFILE_LOCKED", nil);
    }
}

- (IBAction)visibleBtnTap:(id)sender {
    NSLog(@"visible");
}
- (IBAction)lockBtnTap:(id)sender {
    NSLog(@"locked");
}
- (IBAction)invisibleBtnTap:(id)sender {
    NSLog(@"invisible");
}


@end

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
#import "UIImage+HighPoint.h"
#import "UIDevice+HighPoint.h"

#define AVATAR_BLUR_RADIUS 10.0
#define CONSTRAINT_AVATAR_TOP 5.0
#define CONSTRAINT_USERINFO_TOP_INVISIBLE 225.0
#define CONSTRAINT_USERINFO_TOP_VISIBLE 270.0
#define CONSTRAINT_VISIBILITY_BNTS_TOP 325.0
#define CONSTRAINT_VISIBILITY_INFO_TOP 250.0

@implementation HPCurrentUserUICollectionViewCell



- (void) configureCell : (User *) user {

    [self fixUserCardConstraint:user];
    self.yourProfilelabel.text = NSLocalizedString(@"YOUR_PROFILE", nil);
    [self.yourProfilelabel hp_tuneForUserCardName];
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    [self.userInfoLabel hp_tuneForUserCardName];
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.userInfoLabel.text = [NSString stringWithFormat:@"%@, %@ лет, %@", user.name, user.age, cityName];
    [self setAvatarVisibilityBlur:user];
    [self setVisibility:user.visibility];
    
}

- (void) setAvatarVisibilityBlur :(User *) user {
    if (([user.visibility intValue] == 2) || ([user.visibility intValue] == 3)) {
        self.avatarImageView.image = [self.avatarImageView.image hp_imageWithGaussianBlur: AVATAR_BLUR_RADIUS];
    }
}

- (void) setVisibility : (NSNumber *) visibility {
    if ([visibility isEqualToNumber:@1]) {
        self.visibleBtn.selected = YES;
        self.invisibleBtn.selected = NO;
        self.lockBtn.selected = NO;
        self.visibilityInfoLabel.hidden = NO;
        self.visibilityInfoLabel.hidden = YES;
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

#pragma mark - visibility btns

- (IBAction)visibleBtnTap:(id)sender {
    NSLog(@"visible");
}
- (IBAction)lockBtnTap:(id)sender {
    NSLog(@"locked");
}
- (IBAction)invisibleBtnTap:(id)sender {
    NSLog(@"invisible");
}

#pragma mark - constraint
- (void) fixUserCardConstraint : (User *) user
{
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.avatarImageView))
                consIter.constant = CONSTRAINT_AVATAR_TOP;
            
            
            if (([user.visibility intValue] == 2) || ([user.visibility intValue] == 3)) {
                if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.userInfoLabel))
                    consIter.constant = CONSTRAINT_USERINFO_TOP_INVISIBLE;

            } else {
                if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                    (consIter.firstItem == self.userInfoLabel))
                    consIter.constant = CONSTRAINT_USERINFO_TOP_VISIBLE;
            }
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.visibilityInfoLabel))
                consIter.constant = CONSTRAINT_VISIBILITY_INFO_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.visibleBtn))
                consIter.constant = CONSTRAINT_VISIBILITY_BNTS_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.lockBtn))
                consIter.constant = CONSTRAINT_VISIBILITY_BNTS_TOP;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.invisibleBtn))
                consIter.constant = CONSTRAINT_VISIBILITY_BNTS_TOP;
        }
    }
}




@end

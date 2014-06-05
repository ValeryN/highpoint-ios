//
//  HPMainViewListTableViewCell.m
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPMainViewListTableViewCell.h"
#import "UIImage+HighPoint.h"
#import "UILabel+HighPoint.h"

//==============================================================================

#define HALFHIDE_MAININFO_DURATION 0.1
#define SHOWPOINT_COMPLETELY_DURATION 0.2
#define SHOWPOINT_VIBRATE_DURATION 0.4

//==============================================================================

@implementation HPMainViewListTableViewCell

//==============================================================================

- (void) makeAnonymous
{
    [_secondLabel hp_tuneForUserListCellAnonymous];
    [_firstLabel hp_tuneForUserListCellAnonymous];
    [self blurUserImage];
}

//==============================================================================

- (void) configureCell
{
    UIImage* userAvatar = [UIImage imageNamed: @"img_sample1"];
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    self.userImage.image = userAvatarWithMask;
    self.userImageBorder.image = [UIImage imageNamed: @"Userpic Shape Green"];

    [self.firstLabel hp_tuneForUserListCellName];
    self.firstLabel.text = @"Анастасия Шляпова";
    
    [self.secondLabel hp_tuneForUserListCellAgeAndCity];
    self.secondLabel.text = @"99 лет, Когалым";
    
    [self.point hp_tuneForUserListCellPointText];
    self.point.text = @"У нас тут очень весело. Если кто не боится таких развлечений, пишите!";

    [self addGestureRecognizer];
}

//==============================================================================

- (void) blurUserImage
{
    UIImage* userAvatar = [UIImage imageNamed: @"img_sample1"];
    userAvatar = [userAvatar hp_applyBlurWithRadius: 5.0];
    UIImage* userAvatarWithMask = [userAvatar hp_maskImageWithPattern: [UIImage imageNamed: @"Userpic Mask"]];
    self.userImage.image = userAvatarWithMask;
}

//==============================================================================

#pragma mark - show point animation -

//==============================================================================

- (void) vibrateThePoint
{
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice Tap"];
    
    [UIView animateWithDuration: SHOWPOINT_VIBRATE_DURATION / 2
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         CGRect rect = self.mainInfoGroup.frame;
         rect.origin.x = 0;
         self.mainInfoGroup.frame = rect;
     }
                     completion: ^(BOOL finished)
     {
         [UIView animateWithDuration: SHOWPOINT_VIBRATE_DURATION / 2
                               delay: 0
                             options: UIViewAnimationOptionCurveLinear
                          animations: ^
          {
              CGRect rect = self.mainInfoGroup.frame;
              rect.origin.x = 12;
              self.mainInfoGroup.frame = rect;
          }
                          completion: ^(BOOL finished)
          {
              self.showPointButton.image = [UIImage imageNamed: @"Point Notice"];
          }];
     }];
}

//==============================================================================

- (void) showPoint
{
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice Tap"];
    
    [UIView animateWithDuration: HALFHIDE_MAININFO_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         [self halfhideMaininfo];
     }
                     completion: ^(BOOL finished)
     {
         [self showpointCompletely];
     }];
}

//==============================================================================

- (void) hidePoint
{
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice"];
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         [self fadeawayPointText];
     }
                     completion: ^(BOOL finished)
     {
         [self showMainInfo];
     }];
}

//==============================================================================

#pragma mark - private methods -

//==============================================================================

- (void) showpointCompletely
{
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         [self fullhideMaininfo];
     }
                     completion: ^(BOOL finished)
     {
     }];
}

//==============================================================================

- (void) halfhideMaininfo
{
    CGRect rect = self.mainInfoGroup.frame;
    rect.origin.x = -(rect.size.width + rect.origin.x) / 2.0;
    self.mainInfoGroup.frame = rect;
}

//==============================================================================

- (void) fullhideMaininfo
{
    self.point.alpha = 1.0;
    
    CGRect rect = self.mainInfoGroup.frame;
    rect.origin.x = 2 * rect.origin.x;
    self.mainInfoGroup.frame = rect;
}

//==============================================================================

- (void) fadeawayPointText
{
    self.point.alpha = 0.5;
}

//==============================================================================

- (void) showMainInfo
{
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         self.point.alpha = 0.0;
         
         CGRect rect = self.mainInfoGroup.frame;
         rect.origin.x = 12;
         self.mainInfoGroup.frame = rect;
     }
                     completion: ^(BOOL finished)
     {
     }];
}

//==============================================================================

#pragma mark - Gesture recognizers -

//==============================================================================

- (void) addGestureRecognizer
{
    UILongPressGestureRecognizer* longtapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongTap:)];
    [self.showPointGroup addGestureRecognizer: longtapRecognizer];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [self.showPointGroup addGestureRecognizer: tapRecognizer];
}

//==============================================================================

- (void) cellTap: (id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]] == NO)
        return;

    [self vibrateThePoint];
}

//==============================================================================

- (void) cellLongTap: (id)sender
{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]] == NO)
        return;
    
    UILongPressGestureRecognizer* recognizer = sender;
    if (recognizer.state == UIGestureRecognizerStateBegan)
        [self showPoint];
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self hidePoint];
}

//==============================================================================

@end

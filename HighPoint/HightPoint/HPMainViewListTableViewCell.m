//
//  HPMainViewListTableViewCell.m
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import "HPMainViewListTableViewCell.h"
#import "UIImage+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "HPMainViewListTableViewCell+HighPoint.h"
#import "User.h"
#import "City.h"
#import "DataStorage.h"


#define HALFHIDE_MAININFO_DURATION 0.1
#define SHOWPOINT_COMPLETELY_DURATION 0.2
#define SHOWPOINT_VIBRATE_DURATION 0.4
#define CONSTRAINT_TOP_FOR_AVATAR 8


static HPMainViewListTableViewCell* _prevCell;

@implementation HPMainViewListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self createAvatar];
    }
    return self;
}

- (void) configureCell:(User*) user
{
    /*
    [self.firstLabel hp_tuneForUserListCellName];
    self.firstLabel.text = user.name;
    [self.secondLabel hp_tuneForUserListCellAgeAndCity];
    ;
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    self.secondLabel.text = [NSString stringWithFormat:@"%@ лет, %@", user.age, cityName];
    [self.point hp_tuneForUserListCellPointText];
    [self.privacyLabel hp_tuneForUserListCellAnonymous];
    if (user.point.pointText.length > 0) {
        self.point.text = user.point.pointText;
        [self.showPointGroup setHidden:NO];
    } else  {
        [self.showPointGroup setHidden:YES];
    }
    self.point.text = user.point.pointText;

    self.avatar.user = user;

    [self addGestureRecognizer];
    if (([user.visibility intValue] == 2) || ([user.visibility intValue] == 3)) {
        self.privacyLabel.hidden = NO;
        self.secondLabel.hidden = YES;
        self.firstLabel.hidden = YES;
        [self setPrivacyText:user];
    } else {
        self.privacyLabel.hidden = YES;
        self.secondLabel.hidden = NO;
        self.firstLabel.hidden = NO;
    }
    */
}


- (void) setPrivacyText :(User *) user {
    if ([user.visibility intValue] == 2) {
        if ([user.gender intValue] == 1) {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HIS_PROFILE", nil);
        } else {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HER_PROFILE", nil);
        }
    }
    
    if ([user.visibility intValue] == 3) {
        if ([user.gender intValue] == 1) {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HER_NAME", nil);
        } else {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HIS_NAME", nil);
        }
    }
}

- (void) createAvatar
{
    _avatar = [HPAvatarView avatarViewWithUser:[[DataStorage sharedDataStorage] getCurrentUser]];
    [_mainInfoGroup addSubview: _avatar];
    _avatar.translatesAutoresizingMaskIntoConstraints = NO;

    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem: _avatar
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: _avatar.frame.size.width]];

    [_avatar addConstraint:[NSLayoutConstraint constraintWithItem: _avatar
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: _avatar.frame.size.height]];

   [_mainInfoGroup addConstraint:[NSLayoutConstraint constraintWithItem: _mainInfoGroup
                                                         attribute: NSLayoutAttributeBottom
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: _avatar
                                                         attribute: NSLayoutAttributeBottom
                                                        multiplier: 1.0
                                                          constant: CONSTRAINT_TOP_FOR_AVATAR]];
}


#pragma mark - show point animation -


- (void) vibrateThePoint
{
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice Tap"];
    @weakify(self);
    [UIView animateWithDuration: SHOWPOINT_VIBRATE_DURATION / 2
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         @strongify(self);
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
              @strongify(self);
              CGRect rect = self.mainInfoGroup.frame;
              rect.origin.x = 12;
              self.mainInfoGroup.frame = rect;
          }
                          completion: ^(BOOL finished)
          {
              @strongify(self);
              self.showPointButton.image = [UIImage imageNamed: @"Point Notice"];
          }];
     }];
}


- (void) showPoint
{
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice Tap"];
    @weakify(self);
    [UIView animateWithDuration: HALFHIDE_MAININFO_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         @strongify(self);
         [self halfhideMaininfo];
     }
                     completion: ^(BOOL finished)
     {
         @strongify(self);
         [self showpointCompletely];
     }];
}


- (void) hidePoint
{
    @weakify(self);
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice"];
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         @strongify(self);
         [self fadeawayPointText];
     }
                     completion: ^(BOOL finished)
     {
         @strongify(self);
         [self showMainInfo];
         [HPMainViewListTableViewCell makeCellReleased];
     }];
}


#pragma mark - private methods -


- (void) showpointCompletely
{
    @weakify(self);
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         @strongify(self);
         [self fullhideMaininfo];
     }
                     completion: ^(BOOL finished)
     {
     }];
}


- (void) halfhideMaininfo
{
    CGRect rect = self.mainInfoGroup.frame;
    rect.origin.x = -(rect.size.width + rect.origin.x) / 2.0;
    self.mainInfoGroup.frame = rect;
}


- (void) fullhideMaininfo
{
    self.point.alpha = 1.0;
    
    CGRect rect = self.mainInfoGroup.frame;
    rect.origin.x = 2 * rect.origin.x;
    self.mainInfoGroup.frame = rect;
}


- (void) fadeawayPointText
{
    self.point.alpha = 0.5;
}


- (void) showMainInfo
{
    @weakify(self);
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         @strongify(self);
         self.point.alpha = 0.0;
         
         CGRect rect = self.mainInfoGroup.frame;
         rect.origin.x = 12;
         self.mainInfoGroup.frame = rect;
     }
                     completion: ^(BOOL finished)
     {
     }];
}


#pragma mark - Gesture recognizers -


- (void) addGestureRecognizer
{
    UILongPressGestureRecognizer* longtapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongTap:)];
    [self.showPointGroup addGestureRecognizer: longtapRecognizer];
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [self.showPointGroup addGestureRecognizer: tapRecognizer];
}


- (void) cellTap: (id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]] == NO)
        return;

    [self vibrateThePoint];
}


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


#pragma mark - UIView touches processing -


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (_prevCell)
        [_prevCell hp_tuneForUserListReleasedCell];
    _prevCell = self;
    [self hp_tuneForUserListPressedCell];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self hp_tuneForUserListReleasedCell];
    NSLog(@"touch ended");
}


+ (void) makeCellReleased
{
    if (_prevCell)
        [_prevCell hp_tuneForUserListReleasedCell];
}


@end

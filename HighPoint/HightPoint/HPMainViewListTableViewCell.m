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


#define HALFHIDE_MAININFO_DURATION 0.2
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
    self.avatar.user = user;
    
    [self.firstLabel hp_tuneForUserListCellName];
    self.firstLabel.text = user.name;
    UIColor *onlineUserNameColor = [UIColor colorWithRed: 64.0 / 255.0
                                                   green: 199.0 / 255.0
                                                    blue: 79.0 / 255.0
                                                   alpha: 1.0];
    
    UIColor *offlineUserNameColor = [UIColor colorWithRed: 255.0 / 255.0
                                                   green: 153.0 / 255.0
                                                    blue: 0.0 / 255.0
                                                   alpha: 1.0];
    
    if ([user.online boolValue]) {
        self.firstLabel.textColor = onlineUserNameColor;
    } else {
        self.firstLabel.textColor = offlineUserNameColor;
    }
    
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

    
    [self addGestureRecognizer];
    if (([user.visibility intValue] == UserVisibilityBlur) || ([user.visibility intValue] == UserVisibilityHidden)) {
        self.privacyLabel.hidden = NO;
        self.secondLabel.hidden = YES;
        self.firstLabel.hidden = YES;
        [self setPrivacyText:user];
    } else {
        self.privacyLabel.hidden = YES;
        self.secondLabel.hidden = NO;
        self.firstLabel.hidden = NO;
    }

}


- (void) setPrivacyText :(User *) user {
    if ([user.visibility intValue] == UserVisibilityHidden) {
        if ([user.gender intValue] == UserGenderMale) {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HIS_PROFILE", nil);
        } else {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HER_PROFILE", nil);
        }
    }
    
    if ([user.visibility intValue] == UserVisibilityBlur) {
        if ([user.gender intValue] == UserGenderMale) {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HIS_NAME", nil);
        } else {
            self.privacyLabel.text = NSLocalizedString(@"HIDE_HER_NAME", nil);
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
    CGRect rect = self.mainInfoGroup.frame;
    rect.origin.x = -320;//-(rect.size.width + rect.origin.x) /1.5;
    self.showPointButton.image = [UIImage imageNamed: @"Point Notice Tap"];
    @weakify(self);
    [UIView animateWithDuration: HALFHIDE_MAININFO_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
     {
         @strongify(self);
         self.mainInfoGroup.frame = rect;
         self.point.alpha = 1.0;
     }
                     completion: ^(BOOL finished)
     {
         
     }];
}


- (void) hidePoint
{
    if(!handleLongTap) {
        @weakify(self);
        CGRect rect = self.mainInfoGroup.frame;
        rect.origin.x = 12;
        self.showPointButton.image = [UIImage imageNamed: @"Point Notice"];
        [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             @strongify(self);
             self.point.alpha = 0.0;
             self.mainInfoGroup.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
             [HPMainViewListTableViewCell makeCellReleased];
         }];
    }
}


#pragma mark - private methods -

- (void) moveMainFrameToLeft
{
    
}
#pragma mark - Gesture recognizers -


- (void) addGestureRecognizer
{
    UILongPressGestureRecognizer* longtapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongTap:)];
    longtapRecognizer.minimumPressDuration = 0.3;
    longtapRecognizer.delegate = self;
    [self.showPointGroup addGestureRecognizer: longtapRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipeLeft:)];
    swipeLeftRecognizer.cancelsTouchesInView = YES;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.contentView addGestureRecognizer:swipeLeftRecognizer];
    
    UISwipeGestureRecognizer *swipeRightRecognizer  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwipeRight:)];
    swipeRightRecognizer.cancelsTouchesInView = YES;
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.contentView addGestureRecognizer:swipeRightRecognizer];
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [self.showPointGroup addGestureRecognizer: tapRecognizer];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void) cellTap: (id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]] == NO || handleLongTap)
        return;

    [self vibrateThePoint];
}


- (void) cellLongTap: (id)sender
{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]] == NO)
        return;

    UILongPressGestureRecognizer* recognizer = sender;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        handleLongTap = YES;
        if(!self.showPointGroup.isHidden)
        [self showPoint];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        handleLongTap = NO;
        if(!self.showPointGroup.isHidden)
        [self hidePoint];
    }
}
- (void) cellSwipeLeft: (UISwipeGestureRecognizer *)recognizer {
     if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
         if(!self.showPointGroup.isHidden)
             [self showPoint];
    }
}
- (void) cellSwipeRight: (UISwipeGestureRecognizer *)recognizer {
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if(!self.showPointGroup.isHidden)
            [self hidePoint];
    }
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

}


+ (void) makeCellReleased
{
    if (_prevCell) {
        
        [_prevCell hp_tuneForUserListReleasedCell];
    }
}


@end

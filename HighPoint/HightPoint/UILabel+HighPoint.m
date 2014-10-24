//
//  UILabel+HighPoint.m
//  HighPoint
//
//  Created by Michael on 04.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import "UILabel+HighPoint.h"


@implementation UILabel (HighPoint)


#pragma mark - users list

- (void) hp_tuneForUserListCellName
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
}


- (void) hp_tuneForUserListCellAgeAndCity
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
}


- (void) hp_tuneForUserListCellPointText
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
}

- (void) hp_tuneForUserVisibilityText
{
    self.font = [UIFont fontWithName: @"FuturaPT-Medium" size: 17.0];
}

- (void) hp_tuneForUserListCellAnonymous
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}



- (void) hp_tuneForUserCardDetails
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size:16.0f];
}



- (void) hp_tuneForUserCardPhotoIndex
{
    [self hp_tuneForUserCardDetails];
}


- (void) hp_tuneForUserVisibilityInfo {
    self.font = self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}

- (void) hp_tuneForSymbolCounterWhite
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size:17.0f];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}

- (void) hp_tuneForSymbolCounterRed
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size:17.0f];
    self.textColor = [UIColor colorWithRed: 255.0 / 255.0
                                     green: 102.0 / 255.0
                                      blue: 112.0 / 255.0
                                     alpha: 1.0];
}


- (void) hp_tuneForDeletePointInfo {
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size:16.0f];
    self.textColor = [UIColor colorWithRed: 255.0 / 255.0
                                     green: 102.0 / 255.0
                                      blue: 112.0 / 255.0
                                     alpha: 1.0];
}

#pragma mark - contact list
- (void) hp_tuneForUserNameInContactList {
    self.font = self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 18.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}

- (void) hp_tuneForUserDetailsInContactList {
    self.font = self.font = [UIFont fontWithName: @"FuturaPT-Medium" size: 15.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}



- (void) hp_tuneForMessageInContactList
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 16.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}

- (void) hp_tuneForMessageCountInContactList
{
    self.font = [UIFont fontWithName: @"FuturaPT-Book" size: 16.0];
    self.textColor = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
}


#pragma mark - chat view
- (void) hp_tuneForHeaderAndInfoInMessagesList
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 14.0];
    self.textColor = [UIColor colorWithRed: 216.0 / 255.0
                                     green: 216.0 / 255.0
                                      blue: 216.0 / 255.0
                                     alpha: 1.0];
}

#pragma mark - current point
- (void) hp_tuneForCurrentPointInfo
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 17.0];
    self.textColor = [UIColor colorWithRed: 216.0 / 255.0
                                     green: 216.0 / 255.0
                                      blue: 216.0 / 255.0
                                     alpha: 0.6];
}


#pragma mark - user info
- (void) hp_tuneForProfileHiddenlabel
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 18.0];
    self.textColor = [UIColor colorWithRed: 216.0 / 255.0
                                     green: 216.0 / 255.0
                                      blue: 216.0 / 255.0
                                     alpha: 0.6];
}

- (void) hp_tuneForPrivacyInfolabel
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 16.0];
    self.textColor = [UIColor colorWithRed: 216.0 / 255.0
                                     green: 216.0 / 255.0
                                      blue: 216.0 / 255.0
                                     alpha: 0.6];
}

@end

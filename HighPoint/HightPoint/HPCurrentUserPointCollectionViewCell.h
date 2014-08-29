//
//  HPCurrentUserPointCollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPSlider.h"

@class User;
@class HPCurrentUserViewController;

@protocol HPCurrentUserPointCollectionViewCellDelegate <NSObject>
@required

- (UINavigationItem *) navigationItem;
- (UINavigationController *) navigationController;
- (void)resetNavigationBarButtons;
- (void) createPointWithPointText:(NSString*) text andTime:(NSNumber*) time forUser:(User *) user;
- (void) deleteCurrentUserPointForUser:(User *) user;
@end


@interface HPCurrentUserPointCollectionViewCell : UICollectionViewCell <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) HPCurrentUserViewController* delegate;
@property (nonatomic) BOOL editUserPointMode;
@property (nonatomic, retain) User* currentUser;

@end

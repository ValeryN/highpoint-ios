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

@class HPCurrentUserViewController;

@protocol HPCurrentUserUICollectionViewCellDelegate <NSObject>
@required
- (void) updateUserVisibility:(UserVisibilityType) visibilityType forUser:(User*) user;
@end

@interface HPCurrentUserUICollectionViewCell : UICollectionViewCell
@property (nonatomic, retain) User* currentUser;
@property (nonatomic, weak) HPCurrentUserViewController* delegate;

@end

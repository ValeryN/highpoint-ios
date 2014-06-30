//
//  HPUserPointVC.h
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

#import "UserCardOrPointProtocol.h"
#import "HPAvatarView.h"

//==============================================================================

@interface HPUserPointView : UIView

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;

@property (nonatomic, weak) HPAvatarView* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* backgroundAvatar;
@property (nonatomic, weak) IBOutlet UILabel* details;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UIView* avatarGroup;

- (void) initObjects;
- (IBAction) pointButtonPressed: (id)sender;

@end

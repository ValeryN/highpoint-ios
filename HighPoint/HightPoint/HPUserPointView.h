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

@protocol PointViewProtocol <NSObject>

- (void) heartTapped;

@end

//==============================================================================

@interface HPUserPointView : UIView

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;
@property (nonatomic, weak) NSObject<PointViewProtocol>* pointDelegate;

@property (nonatomic, weak) HPAvatarView* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* backgroundAvatar;
@property (nonatomic, weak) IBOutlet UILabel* details;
@property (nonatomic, weak) IBOutlet UILabel* name;
@property (nonatomic, weak) IBOutlet UIView* avatarGroup;
@property (nonatomic, weak) IBOutlet UITextView* pointText;

- (void) initObjects;
- (IBAction) pointButtonPressed: (id)sender;
- (IBAction) heartButtonPressed: (id)sender;

@end

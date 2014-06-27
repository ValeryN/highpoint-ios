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
#import "HPAvatar.h"

//==============================================================================

@interface HPUserPointView : UIView

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;

@property (nonatomic, weak) IBOutlet HPAvatar* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* backgroundAvatar;
@property (nonatomic, weak) IBOutlet UILabel* details;
@property (nonatomic, weak) IBOutlet UILabel* name;

- (void) initObjects;
- (IBAction) pointButtonPressed: (id)sender;

@end

//
//  HPRootViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

#import "HPSwitchViewController.h"
#import "HPFilterSettingsViewController.h"
#import "ScaleAnimation.h"
#import "CrossDissolveAnimation.h"
#import "HPUserCardViewController.h"

//==============================================================================

@interface HPRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UserImageStartAnimationDelegate, HPSwitchProtocol>
{
    ScaleAnimation *_scaleAnimationController;
    CrossDissolveAnimation *_crossDissolveAnimationController;
    HPSwitchViewController *_bottomSwitch;
}

@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) IBOutlet UITableView *mainListTable;
@property (nonatomic, assign) CGRect savedFrame;

- (IBAction) filterButtonTap:(id)sender;

@end

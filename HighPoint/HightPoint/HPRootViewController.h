//
//  HPRootViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPSwitchViewController.h"
#import "HPUserCardViewController.h"
#import "HPFilterSettingsViewController.h"

@interface HPRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UserImageStartAnimationDelegate>
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, strong) IBOutlet UITableView *mainListTable;
@property (nonatomic, strong) HPSwitchViewController *bottomSwitch;
@property (nonatomic, assign) CGRect savedFrame;

- (IBAction) filterButtonTap:(id)sender;
- (IBAction) cellLongTap:(id)sender; 

@end

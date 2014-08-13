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

@interface HPRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, HPSwitchProtocol, NSFetchedResultsControllerDelegate>
{
    ScaleAnimation *_scaleAnimationController;
    CrossDissolveAnimation *_crossDissolveAnimationController;
    HPSwitchViewController *_bottomSwitch;
}

@property (nonatomic, weak) IBOutlet UIButton* chatsListButton;
@property (nonatomic, weak) IBOutlet UIView* filterGroupView;
@property (nonatomic, weak) IBOutlet UITableView *mainListTable;
@property (nonatomic, strong) NSFetchedResultsController *allUsers;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, assign) CGRect savedFrame;

- (IBAction) filterButtonTap:(id)sender;
- (IBAction) profileButtonPressedStart: (id) sender;
- (IBAction) bubbleButtonPressedStart: (id) sender;

@end

//
//  HPRootViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "HPSwitchViewController.h"
#import "HPFilterSettingsViewController.h"
#import "ScaleAnimation.h"
#import "CrossDissolveAnimation.h"
#import "HPUserCardViewController.h"
#import "HPSpinnerView.h"
#import "RACTableViewController.h"


@interface HPRootViewController : RACTableViewController <UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, HPSwitchProtocol, NSFetchedResultsControllerDelegate, HPUserCardViewControllerDelegate>
{
    CrossDissolveAnimation *_crossDissolveAnimationController;
    
}

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *sendFilterBtn;

@property (nonatomic, strong) CABasicAnimation* rotationAnimation;
@property (nonatomic, weak) IBOutlet UIButton* chatsListButton;
@property (nonatomic, weak) IBOutlet UIView* filterGroupView;
@property (nonatomic, weak) IBOutlet UITableView *mainListTable;
@property (nonatomic, strong) NSFetchedResultsController *allUsers;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, assign) CGRect savedFrame;
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bottomActivityView;
@property (assign, nonatomic) BOOL isNeedScrollToIndex;
@property (assign, nonatomic) int currentIndex;
@property (weak, nonatomic) IBOutlet UIButton *lensBtn;

@property (strong, nonatomic) HPFilterSettingsViewController *filterController;
@property (weak, nonatomic) IBOutlet HPSpinnerView *bottomSpinnerView;
@property (weak, nonatomic) IBOutlet UIImageView *blendImageView;
@property (nonatomic, retain) IBOutlet HPSwitchViewController *bottomSwitch;

- (IBAction) filterButtonTap:(id)sender;
- (IBAction) profileButtonPressedStart: (id) sender;
- (IBAction) bubbleButtonPressedStart: (id) sender;
- (void) syncronizePosition : (NSInteger) currentPosition;

@end

//
//  HPFilterSettingsViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"
#import "UIImage+HighPoint.h"

@protocol HPFilterSettingsViewControllerDelegate <NSObject>

- (void) showActivity;

@end



@interface HPFilterSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) id<HPFilterSettingsViewControllerDelegate> delegate;


@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UILabel *filterLabel;
@property (nonatomic, weak) IBOutlet UISwitch *womenSw;
@property (nonatomic, weak) IBOutlet UISwitch *menSw;
@property (nonatomic, weak) IBOutlet UILabel *menLabel;
@property (nonatomic, weak) IBOutlet UILabel *womenLabel;
@property (nonatomic, weak) IBOutlet UILabel *oldLabel;
@property (weak, nonatomic) IBOutlet UISwitch *townSwitch;

@property (nonatomic, weak) IBOutlet UILabel *townLabel;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel1;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel2;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel3;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel4;


@property (nonatomic, weak) id savedDelegate;
@property (nonatomic, weak) IBOutlet UILabel *oldLabelVal;
@property (nonatomic, strong) IBOutlet NMRangeSlider *oldRangeSlider;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, assign) BOOL menSwitchState;
@property (nonatomic, assign) BOOL womenSwitchState;

@property (weak, nonatomic) IBOutlet UITableView *townsTableView;
@property (strong, nonatomic) UIImage *screenShoot;
@property (strong, nonatomic) UIView *darkBgView;
@property (weak, nonatomic) IBOutlet UIImageView *backGroundView;

- (IBAction) menSwitchTap:(id)sender;
- (IBAction) womenSwitchTap:(id)sender;

- (IBAction) closeButtonTap:(id)sender;
- (IBAction) townSwitchTap:(id)sender;

@end

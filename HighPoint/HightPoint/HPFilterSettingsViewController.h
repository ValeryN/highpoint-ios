//
//  HPFilterSettingsViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 22.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMRangeSlider.h"
@interface HPFilterSettingsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *profileButton;
@property (nonatomic, weak) IBOutlet UIButton *messageButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UILabel *filterLabel;
@property (nonatomic, weak) IBOutlet UISwitch *womenSw;
@property (nonatomic, weak) IBOutlet UISwitch *menSw;
@property (nonatomic, weak) IBOutlet UILabel *menLabel;
@property (nonatomic, weak) IBOutlet UILabel *womenLabel;
@property (nonatomic, weak) IBOutlet UILabel *oldLabel;

@property (nonatomic, weak) IBOutlet UILabel *townLabel;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel1;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel2;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel3;
@property (nonatomic, weak) IBOutlet UILabel *guideLabel4;

@property (nonatomic, weak) IBOutlet UILabel *cityLabel;
@property (nonatomic, weak) IBOutlet UIButton *selectTownButton;
@property (nonatomic, weak) id savedDelegate;
@property (nonatomic, weak) IBOutlet UILabel *oldLabelVal;
@property (nonatomic, strong) IBOutlet NMRangeSlider *oldRangeSlider;
@property (nonatomic, strong) UIView *notificationView;
@property (nonatomic, assign) BOOL menSwitchState;
@property (nonatomic, assign) BOOL womenSwitchState;

@property (nonatomic, weak) IBOutlet UIView *sepView1;
- (IBAction) menSwitchTap:(id)sender;
- (IBAction) womenSwitchTap:(id)sender;
- (IBAction) profileButtonTap:(id)sender;
- (IBAction) messageButtonTap:(id)sender;
- (IBAction) closeButtonTap:(id)sender;
- (IBAction) townSwitchTap:(id)sender;
- (IBAction) townSelectTap:(id)sender;
@end

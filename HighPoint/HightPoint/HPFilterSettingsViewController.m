//
//  HPFilterSettingsViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 22.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPFilterSettingsViewController.h"
#import "HPSelectTownViewController.h"
#import "Utils.h"
@interface HPFilterSettingsViewController ()

@end

@implementation HPFilterSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    self.womenSw.layer.cornerRadius = 16.0;
    self.menSw.layer.cornerRadius = 16.0;
    
    [self.profileButton setBackgroundImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateNormal];
    [self.profileButton setBackgroundImage:[UIImage imageNamed:@"Profile Tap.png"] forState:UIControlStateHighlighted];
    
    //[self.profileButton addTarget:self action:@selector(profileButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    [self.messageButton addSubview:self.notificationView];
    
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"Bubble.png"] forState:UIControlStateNormal];
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"Bubble Tap.png"] forState:UIControlStateHighlighted];
    
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"Close Tap.png"] forState:UIControlStateHighlighted];
    
    self.filterLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.filterLabel.textColor = [UIColor whiteColor];
    
    self.menLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.menLabel.textColor = [UIColor whiteColor];
    self.womenLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.womenLabel.textColor = [UIColor whiteColor];
    self.oldLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.oldLabel.textColor = [UIColor whiteColor];
    
    self.oldLabelVal.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.oldLabelVal.textColor = [UIColor whiteColor];
    
    self.townLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.townLabel.textColor = [UIColor whiteColor];
    
    self.cityLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.cityLabel.textColor = [UIColor whiteColor];
    self.cityLabel.hidden = YES;
    self.selectTownButton.hidden = YES;
    self.guideLabel1.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel1.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    self.guideLabel2.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel2.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    self.guideLabel3.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel3.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    self.guideLabel4.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel4.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    
    [self.womenSw setOn:YES];
    [self.menSw setOn:NO];
    
    //self.oldRangeSlider.lowerValue = 18;
    self.oldRangeSlider.minimumValue = 18;
    self.oldRangeSlider.maximumValue = 60;
    
    self.oldRangeSlider.tintColor = [UIColor colorWithRed:93.0/255.0 green:186.0/255.0 blue:164.0/255.0 alpha:1.0];
    //self.oldRangeSlider.trackBackgroundImage = [UIImage imageNamed: @"Progress Line"];
    //self.oldRangeSlider.lowerValue = 50.0;
    //self.oldRangeSlider.upperValue = 55.0;    //self.oldRangeSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(12, 208.0, 295.0, 31.0)];
    //self.oldRangeSlider.tintColor = [UIColor redColor];
    //[self.view addSubview:self.oldRangeSlider];
    //[self.messageButton addTarget:self action:@selector(messageButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.oldRangeSlider.minimumValue = 18;
    self.oldRangeSlider.maximumValue = 60;
    //self.oldRangeSlider.minimumRange = 1;
    self.oldRangeSlider.lowerValue = 40.0;
    self.oldRangeSlider.upperValue = 60.0;
    [self updateSliderLabels];
}
#pragma mark -
#pragma mark controller button tap handler
- (IBAction) profileButtonTap:(id)sender {
    
}
- (IBAction) messageButtonTap:(id)sender {
    
}
- (IBAction) closeButtonTap:(id)sender {
    self.navigationController.delegate = self.savedDelegate;
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction) menSwitchTap:(id)sender {
    if(![self.menSw isOn] && ![self.womenSw isOn]) {
        [self.womenSw setOn:YES animated:YES];
    }
}
- (IBAction) womenSwitchTap:(id)sender {
    
    if(![self.menSw isOn] && ![self.womenSw isOn]) {
        [self.menSw setOn:YES animated:YES];
    }

}
- (IBAction) townSwitchTap:(id)sender {
    if([sender isOn]) {
        [UIView transitionWithView:[self navigationController].view
            duration:0.2
            options:UIViewAnimationOptionTransitionCrossDissolve //any animation
            animations:^ {
                self.guideLabel1.hidden = YES;
                self.guideLabel2.hidden = YES;
                self.guideLabel3.hidden = YES;
                self.guideLabel4.hidden = YES;
                self.cityLabel.hidden = NO;
                self.selectTownButton.hidden = NO;
            }
            completion:^(BOOL finished){
                            
        }];
        } else {
        
        [UIView transitionWithView:[self navigationController].view
            duration:0.2
            options:UIViewAnimationOptionTransitionCrossDissolve //any animation
            animations:^ {
                self.guideLabel1.hidden = NO;
                self.guideLabel2.hidden = NO;
                self.guideLabel3.hidden = NO;
                self.guideLabel4.hidden = NO;
                self.cityLabel.hidden = YES;
                self.selectTownButton.hidden = YES;
            }
            completion:^(BOOL finished){
                            
            }];
        }
}
- (IBAction) townSelectTap:(id)sender {
    UIStoryboard *storyBoard;
    //self.view.userInteractionEnabled = NO;
    storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    HPSelectTownViewController *town = [storyBoard instantiateViewControllerWithIdentifier:@"HPSelectTownViewController"];
    self.savedDelegate = self.navigationController.delegate;
    self.navigationController.delegate = nil;
    //_crossDissolveAnimationController.viewForInteraction = filter.view;
    [self.navigationController pushViewController:town animated:YES];
}
- (void) updateSliderLabels {
    NSString *left = [NSString stringWithFormat:@"%.0f", self.oldRangeSlider.lowerValue];
    NSString *right = [NSString stringWithFormat:@"%.0f", self.oldRangeSlider.upperValue];
    if(self.oldRangeSlider.lowerValue == self.oldRangeSlider.minimumValue && self.oldRangeSlider.upperValue == self.oldRangeSlider.maximumValue) {
        self.oldLabelVal.text = @"Не важно";
        return;
    }
    
    if(self.oldRangeSlider.lowerValue != self.oldRangeSlider.upperValue) {
        NSMutableString *str = [NSMutableString stringWithString:left];
        [str appendString:@"-"];
        [str appendString:right];
        self.oldLabelVal.text = str;
    } else {
        self.oldLabelVal.text = left;
    }

}
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender   {
    [self updateSliderLabels];
}

@end

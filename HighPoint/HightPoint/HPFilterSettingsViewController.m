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
#import "DataStorage.h"
#import "HPBaseNetworkManager.h"
#import "Gender.h"
#import "HPCityTableViewCell.h"
#import "NotificationsConstants.h"
#import "UIDevice+HighPoint.h"


#define CONSTRAINT_TOP_FOR_CLOSE_BTN 434


@interface HPFilterSettingsViewController ()

@end

@implementation HPFilterSettingsViewController {
    NSArray *allCities;
}

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
    
    //[self.profileButton addTarget:self action:@selector(profileButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"Close Tap.png"] forState:UIControlStateHighlighted];
    
    self.filterLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.filterLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    self.menLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.menLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.womenLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.womenLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.oldLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.oldLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    self.oldLabelVal.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.oldLabelVal.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    self.townLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
    self.townLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
    
    
    self.guideLabel1.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel1.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    self.guideLabel2.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel2.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    self.guideLabel3.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel3.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    self.guideLabel4.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    self.guideLabel4.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.6];
    
    [self.womenSw setOn:NO];
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
    
    self.townsTableView.delegate = self;
    self.townsTableView.dataSource = self;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fixSelfConstraint];
    [self registerNotification];
    
    [self.navigationController setNavigationBarHidden:YES];
    self.oldRangeSlider.minimumValue = 18;
    self.oldRangeSlider.maximumValue = 60;
    //self.oldRangeSlider.minimumRange = 1;
    [self updateViewValues];
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
    
}



#pragma mark - constraint
- (void) fixSelfConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        
        NSArray* cons = self.view.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.closeButton))
                consIter.constant = CONSTRAINT_TOP_FOR_CLOSE_BTN;
        }
    }
}

#pragma mark -
#pragma mark controller button tap handler

- (IBAction) closeButtonTap:(id)sender {
    //save filter entity and make user filter request

    [self saveFilter];
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
                self.townsTableView.hidden = NO;
            }
            completion:^(BOOL finished){
              self.townLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
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
                self.townsTableView.hidden = YES;
            }
            completion:^(BOOL finished){
                self.townLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
            }];
        }
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

#pragma mark - notifications

- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewValues) name:kNeedUpdateCurrentUserData object:nil];

}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateCurrentUserData object:nil];
}


#pragma mark - update view 

- (void) updateViewValues {
    //set values from DB
    UserFilter *userFilter = [[DataStorage sharedDataStorage] getUserFilter];
    NSLog(@"Current user filter = %@", userFilter.description);
    if (userFilter) {
        self.oldRangeSlider.lowerValue = [userFilter.minAge floatValue];
        self.oldRangeSlider.upperValue = [userFilter.maxAge floatValue];
        for (Gender *num in [userFilter.gender allObjects]) {
            NSLog(@"num = %@ -- %@", num, [num class]);
            if ([num.genderType intValue] == 2) {
                [self.womenSw setOn:YES];
            }
            if ([num.genderType intValue] == 1) {
                [self.menSw setOn:YES];
            }
        }
    } else {
        [self.womenSw setOn:YES];
        self.oldRangeSlider.lowerValue = 20.0;
        self.oldRangeSlider.upperValue = 30.0;
    }
    [self updateSliderLabels];
    allCities = [userFilter.city allObjects];
    [self.townsTableView reloadData];
}



#pragma mark - save filters 

- (void) saveFilter {
    NSMutableArray *genderArr = [[NSMutableArray alloc] init];
    if (self.womenSw.isOn) {
        [genderArr addObject:[NSNumber numberWithFloat:2]];
    }
    if (self.menSw.isOn) {
        [genderArr addObject:[NSNumber numberWithFloat:1]];
    }
    //TODO: view type ?
    UserFilter *userFilter = [[DataStorage sharedDataStorage] getUserFilter];
    NSArray *citiesArr = [userFilter.city allObjects];
    NSString *cityIds = @"";
    for (int i = 0; i < citiesArr.count; i++) {
        if ([((City*)[citiesArr objectAtIndex:i]).cityId stringValue].length >0) {
            cityIds = [[cityIds stringByAppendingString:[((City*)[citiesArr objectAtIndex:i]).cityId stringValue]] stringByAppendingString:@","];
        }
    }
    if ([cityIds length] > 0) {
        cityIds = [cityIds substringToIndex:[cityIds length] - 1];
    }
    NSDictionary *filterParams = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat:self.oldRangeSlider.upperValue], @"maxAge",[NSNumber numberWithFloat:self.oldRangeSlider.lowerValue], @"minAge", [NSNumber numberWithFloat:0], @"viewType", genderArr, @"genders",cityIds, @"cityIds", nil];
    [[DataStorage sharedDataStorage] createAndSaveUserFilterEntity:filterParams withComplation:nil];
    [[HPBaseNetworkManager sharedNetworkManager] makeUpdateCurrentUserFilterSettingsRequest:filterParams];
}

#pragma mark - table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *townCellIdentifier = @"FilterCityCellIdentif";
    HPCityTableViewCell *townCell = (HPCityTableViewCell *)[tableView dequeueReusableCellWithIdentifier:townCellIdentifier];
    
    if (townCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPCityTableViewCell" owner:self options:nil];
        townCell = [nib objectAtIndex:0];
    }
    
    if (allCities.count > 0) {
        City *city = [allCities objectAtIndex:indexPath.row];
        [townCell configureCell:city];
    } else {
        [townCell configureCell:nil];
    }
    
    return townCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HPSelectTownViewController *town = [[HPSelectTownViewController alloc] initWithNibName: @"HPSelectTown" bundle: nil];
    self.savedDelegate = self.navigationController.delegate;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:town animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


@end

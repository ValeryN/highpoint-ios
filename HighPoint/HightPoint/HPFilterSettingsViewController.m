//
//  HPFilterSettingsViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 22.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPFilterSettingsViewController.h"
#import "Utils.h"
#import "DataStorage.h"
#import "HPBaseNetworkManager+CurrentUser.h"
#import "Gender.h"
#import "HPCityTableViewCell.h"
#import "NotificationsConstants.h"
#import "UIDevice+HighPoint.h"
#import "HPSelectPopularCityViewController.h"

#define CONSTRAINT_TOP_FOR_CLOSE_BTN 434


@interface HPFilterSettingsViewController () {
    UserFilter *uf;
    //old values
    NSNumber *oldMinAge;
    NSNumber *oldMaxAge;
    NSNumber * oldFilterCityId;
    BOOL oldIsMale;
    BOOL oldIsFemale;
}

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
    uf = [[DataStorage sharedDataStorage] getUserFilter];
    [self initOldFilterValues];
    self.womenSw.layer.cornerRadius = 16.0;
    self.menSw.layer.cornerRadius = 16.0;
    //self.notificationView = [Utils getNotificationViewForText:@"8"];
    
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
    self.oldRangeSlider.exclusiveTouch = YES;
    self.oldRangeSlider.stepValueContinuously = NO;
    
    self.oldRangeSlider.lowerValue = 18;
    self.oldRangeSlider.upperValue = 60;
    self.oldRangeSlider.minimumValue = 18;
    self.oldRangeSlider.maximumValue = 60;
    self.oldRangeSlider.tintColor = [UIColor colorWithRed:93.0/255.0 green:186.0/255.0 blue:164.0/255.0 alpha:1.0];
    self.townsTableView.delegate = self;
    self.townsTableView.dataSource = self;
}
- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    uf = [[DataStorage sharedDataStorage] getUserFilter];
    [self fixSelfConstraint];
    [self registerNotification];
    self.oldRangeSlider.minimumValue = 18;
    self.oldRangeSlider.maximumValue = 60;
    [self updateViewValues];
    [self setBgBlur];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
    
}


- (void) setBgBlur {
    self.backGroundView.image = [self.screenShoot hp_applyBlurWithRadius:2];
    [self.view insertSubview:self.backGroundView atIndex:0];
    self.darkBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.backGroundView.frame.size.width, self.backGroundView.frame.size.height)];
    self.darkBgView.backgroundColor = [UIColor colorWithRed:30.f / 255.f green:29.f / 255.f blue:48.f / 255.f alpha:0.9];
    [self.backGroundView addSubview:self.darkBgView];
    
}

- (void) hideView {
    self.darkBgView = nil;
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

#pragma mark - old values 
- (void) initOldFilterValues {
    if (uf) {
        oldMinAge = uf.minAge;
        oldMaxAge = uf.maxAge;
        oldFilterCityId = uf.city.cityId;
        
        for (Gender *num in [uf.gender allObjects]) {
            if ([num.genderType intValue] == 2) {
                [self.womenSw setOn:YES];
                oldIsFemale = YES;
            }
            if ([num.genderType intValue] == 1) {
                oldIsMale = YES;
            }
        }
    } else {
        oldMinAge = @(0);
        oldMaxAge = @(0);
        oldFilterCityId = @(0);
        oldIsFemale = NO;
        oldIsMale = NO;
    }
}

- (BOOL) isFilterValuesChanged {
    if (!(oldIsFemale == self.womenSw.isOn)) {
        return YES;
    }
    if (!(oldIsMale == self.menSw.isOn)) {
        return YES;
    }
    if (![oldMinAge isEqualToNumber:[NSNumber numberWithLong:lroundf(self.oldRangeSlider.lowerValue)]]) {
        return YES;
    }
    if (![oldMaxAge isEqualToNumber:[NSNumber numberWithLong:lroundf(self.oldRangeSlider.upperValue)]]) {
        return YES;
    }
    if (oldFilterCityId != uf.city.cityId) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark controller button tap handler

- (IBAction) closeButtonTap:(id)sender {
    //save filter entity and make user filter request

    if ([self isFilterValuesChanged]) {
         [self saveFilter];
        self.navigationController.delegate = self.savedDelegate;
        //[[self navigationController] setNavigationBarHidden:NO animated:NO];
        [self hideView];
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(showActivity)]) {
            [self.delegate showActivity];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
                [self saveFilterToDB];
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
                [self saveFilterToDB];
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
    if (uf) {
        self.oldRangeSlider.lowerValue = [uf.minAge floatValue];
        self.oldRangeSlider.upperValue = [uf.maxAge floatValue];
        for (Gender *num in [uf.gender allObjects]) {
            if ([num.genderType intValue] == 2) {
                [self.womenSw setOn:YES];
            }
            if ([num.genderType intValue] == 1) {
                [self.menSw setOn:YES];
            }
        }
        if (uf.city) {
            [self.townSwitch setOn:YES];
            self.guideLabel1.hidden = YES;
            self.guideLabel2.hidden = YES;
            self.guideLabel3.hidden = YES;
            self.guideLabel4.hidden = YES;
            self.townsTableView.hidden = NO;
            self.townLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        } else {
            [self.townSwitch setOn:NO];
            self.guideLabel1.hidden = NO;
            self.guideLabel2.hidden = NO;
            self.guideLabel3.hidden = NO;
            self.guideLabel4.hidden = NO;
            self.townsTableView.hidden = YES;
            self.townLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
        }
    } else {
        [self.womenSw setOn:YES];
        self.oldRangeSlider.lowerValue = 20.0;
        self.oldRangeSlider.upperValue = 30.0;
    }
    [self updateSliderLabels];
    [self.townsTableView reloadData];
}



#pragma mark - save filters 


- (NSDictionary *) saveFilterToDB {
    NSMutableArray *genderArr = [[NSMutableArray alloc] init];
    if (self.womenSw.isOn) {
        [genderArr addObject:[NSNumber numberWithFloat:2]];
    }
    if (self.menSw.isOn) {
        [genderArr addObject:[NSNumber numberWithFloat:1]];
    }
    NSArray *filterCities;
    if (self.townSwitch.isOn) {
        filterCities = [NSArray arrayWithObjects: uf.city.cityId, nil];
    } else {
        filterCities = nil;
    }

    NSDictionary *filterParams = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithLong:lroundf(self.oldRangeSlider.upperValue)], @"maxAge",[NSNumber numberWithLong:lroundf(self.oldRangeSlider.lowerValue)], @"minAge", [NSNumber numberWithFloat:0], @"viewType", genderArr, @"genders", filterCities, @"cityIds", nil];
    [[DataStorage sharedDataStorage] updateUserFilterEntity:filterParams];
    return filterParams;
}

- (void) saveFilter {
    NSDictionary *param = [self saveFilterToDB];
    [[HPBaseNetworkManager sharedNetworkManager] makeUpdateCurrentUserFilterSettingsRequest:param];
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
    if (uf.city) {
        [townCell configureCell:uf.city];
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
    [self saveFilterToDB];
    HPSelectPopularCityViewController *cityVC = [[HPSelectPopularCityViewController alloc] initWithNibName: @"HPSelectPopularCityViewController" bundle: nil];
    self.savedDelegate = self.navigationController.delegate;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:cityVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


@end

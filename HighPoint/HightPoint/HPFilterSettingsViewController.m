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
#import "NMRangeSlider.h"

#define CONSTRAINT_TOP_FOR_CLOSE_BTN 434


@interface HPFilterSettingsViewController () {
    
    //old values
    NSNumber *oldMinAge;
    NSNumber *oldMaxAge;
    NSNumber * oldFilterCityId;
    BOOL oldIsMale;
    BOOL oldIsFemale;
}
@property (nonatomic, retain) UserFilter *uf;

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

@property (strong, nonatomic) UIToolbar* bgToolbar;

- (IBAction) menSwitchTap:(id)sender;
- (IBAction) womenSwitchTap:(id)sender;

- (IBAction) closeButtonTap:(id)sender;
- (IBAction) townSwitchTap:(id)sender;
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
    self.uf = [[DataStorage sharedDataStorage] getUserFilter];
    [self initOldFilterValues];
    self.womenSw.layer.cornerRadius = 16.0;
    self.menSw.layer.cornerRadius = 16.0;
    
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
    [self configureOutlets];
}

- (void) configureOutlets{
    RAC(self,gender) = [RACObserve(self, uf.gender) map:^id(NSSet* globalValue) {
        if(globalValue.count == 1)
        {
            return @(((Gender*)[globalValue anyObject]).genderType.intValue);
        }
        return @(UserGenderNone);
    }];
    RAC(self,city) = RACObserve(self, uf.city);
    RAC(self,fromAge) = RACObserve(self, uf.minAge);
    RAC(self,toAge) = RACObserve(self, uf.maxAge);
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
    
    self.bgToolbar = [[UIToolbar alloc] initWithFrame:self.view.frame];
    self.bgToolbar.barStyle = UIBarStyleBlack;
    self.bgToolbar.translucent = YES;
    [self.view insertSubview:self.bgToolbar atIndex:0];
    
    
    [self fixSelfConstraint];
    [self registerNotification];
    self.oldRangeSlider.minimumValue = 18;
    self.oldRangeSlider.maximumValue = 60;
    [self updateViewValues];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [self saveFilterToDB];
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

#pragma mark - old values 
- (void) initOldFilterValues {
    if (self.uf) {
        oldMinAge = self.uf.minAge;
        oldMaxAge = self.uf.maxAge;
        oldFilterCityId = self.uf.city.cityId;
        
        for (Gender *num in [self.uf.gender allObjects]) {
            if ([num.genderType intValue] == UserGenderFemale) {
                [self.womenSw setOn:YES];
                oldIsFemale = YES;
            }
            if ([num.genderType intValue] == UserGenderMale) {
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
    if (oldFilterCityId != self.uf.city.cityId) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark controller button tap handler

- (IBAction) closeButtonTap:(id)sender {
    //save filter entity and make user filter request

    if ([self isFilterValuesChanged]) {
        [self saveFilterToDB];
    } else {

    }
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
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
    if (self.uf) {
        self.oldRangeSlider.lowerValue = [self.uf.minAge floatValue];
        self.oldRangeSlider.upperValue = [self.uf.maxAge floatValue];
        for (Gender *num in [self.uf.gender allObjects]) {
            if ([num.genderType intValue] == UserGenderFemale) {
                [self.womenSw setOn:YES];
            }
            if ([num.genderType intValue] == UserGenderMale) {
                [self.menSw setOn:YES];
            }
        }
        if (self.uf.city) {
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
        [genderArr addObject:[NSNumber numberWithFloat:UserGenderFemale]];
    }
    if (self.menSw.isOn) {
        [genderArr addObject:[NSNumber numberWithFloat:UserGenderMale]];
    }
    NSArray *filterCities;
    if (self.townSwitch.isOn) {
        filterCities = [NSArray arrayWithObjects: self.uf.city.cityId, nil];
    } else {
        filterCities = nil;
    }

    NSDictionary *filterParams = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithLong:lroundf(self.oldRangeSlider.upperValue)], @"maxAge",[NSNumber numberWithLong:lroundf(self.oldRangeSlider.lowerValue)], @"minAge", [NSNumber numberWithFloat:0], @"viewType", genderArr, @"genders", filterCities, @"cityIds", nil];
    [[DataStorage sharedDataStorage] updateUserFilterEntity:filterParams];
    return filterParams;
}

- (void) saveFilter {
    NSString *genderStr = @"";
    if (self.womenSw.isOn) {
        genderStr = [genderStr stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)UserGenderFemale]];
    }
    if (self.menSw.isOn) {
        if (self.womenSw.isOn) {
            genderStr = [genderStr stringByAppendingString:@","];
        }
         genderStr = [genderStr stringByAppendingString:[NSString stringWithFormat:@"%lu", (unsigned long)UserGenderMale]];
    }
    NSString *filterCities = @"";
    if (self.townSwitch.isOn) {
        filterCities =  [filterCities stringByAppendingString:[NSString stringWithFormat:@"%@", self.uf.city.cityId]];
    } else {
        filterCities = @"";
    }
    NSDictionary *filterParams = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithLong:lroundf(self.oldRangeSlider.upperValue)], @"maxAge",[NSNumber numberWithLong:lroundf(self.oldRangeSlider.lowerValue)], @"minAge", [NSNumber numberWithFloat:0], @"viewType", genderStr, @"genders", filterCities, @"cityIds", nil];
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
    if (self.uf.city) {
        [townCell configureCell:self.uf.city];
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
    
    self.savedDelegate = self.navigationController.delegate;
    self.navigationController.delegate = nil;
    HPSelectPopularCityViewController *cityVC = [[HPSelectPopularCityViewController alloc] initWithNibName: @"HPSelectPopularCityViewController" bundle: nil];
    [self.navigationController pushViewController:cityVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


@end

//
//  HPSelectTownViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 23.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSelectTownViewController.h"
#import "Utils.h"
#import "HPTownTableViewCell.h"
#import "HPBaseNetworkManager.h"
#import "NotificationsConstants.h"
#import "DataStorage.h"

@interface HPSelectTownViewController ()

@end

@implementation HPSelectTownViewController


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
    self.townsTableView.delegate = self;
    self.townsTableView.dataSource = self;
    self.townsTableView.backgroundColor = [UIColor clearColor];
    self.townSearchBar.delegate = self;
    self.allCities = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Utils configureNavigationBar:self.navigationController];
    [self configureNavButton];
    [self.navigationController setNavigationBarHidden:NO];
    [self registerNotification];
    [self updateCurrentView];
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DataStorage sharedDataStorage] deleteAllTempCities];
    [self unregisterNotification];
}

- (void) configureNavButton {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 12, 23)];
    [leftButton setContentMode:UIViewContentModeScaleAspectFit];
    
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Back Tap.png"] forState:UIControlStateHighlighted];
    
    [leftButton addTarget:self action:@selector(backButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    //[leftButton addTarget:self action:@selector(profileButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton_ = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = 0;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftButton_, nil]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [self.navigationItem setLeftBarButtonItem:leftButton_];
    }

}
- (void) backButtonTap:(UIButton *)sender {
    //[self showNotification];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - notifications 
- (void) registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView) name:kNeedUpdateCitiesListView object:nil];
}

- (void) unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateCitiesListView object:nil];
}

#pragma mark - update current view

- (void) updateCurrentView
{
    self.allCities = [[[[DataStorage sharedDataStorage] allTempCitiesFetchResultsController] fetchedObjects] mutableCopy];
    [self.townsTableView reloadData];
}


#pragma mark - table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *townCellIdentifier = @"PaymentCellIdentif";
    HPTownTableViewCell *townCell = (HPTownTableViewCell *)[tableView dequeueReusableCellWithIdentifier:townCellIdentifier];
    
    if (townCell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HPTownTableViewCell" owner:self options:nil];
        townCell = [nib objectAtIndex:0];
    }
    City *city = [self.allCities objectAtIndex:indexPath.row];
    [townCell configureCell:city];
    return townCell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allCities.count;
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
    City *city = [self.allCities objectAtIndex:indexPath.row];
    [[DataStorage sharedDataStorage] setCityNotTemp:city.cityId];
    [[DataStorage sharedDataStorage] setCityToUserFilter:city];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - search bar

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 0) {
        [[DataStorage sharedDataStorage] deleteAllTempCities];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:searchText,@"query",@"20",@"limit",nil];
        [[HPBaseNetworkManager sharedNetworkManager] findGeoLocation:dict];
    } else {
        [[DataStorage sharedDataStorage] deleteAllTempCities];
        [self.allCities removeAllObjects];
        [self.townsTableView reloadData];
    }
}

@end

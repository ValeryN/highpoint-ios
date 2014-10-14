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
#import "HPBaseNetworkManager+Geo.h"
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
    //self.townSearchBar.delegate = self;
    self.allCities = [[NSMutableArray alloc] init];
    self.townSearchBar.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    self.townSearchBar.textAlignment = NSTextAlignmentLeft;
    self.townSearchBar.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.townsTableView addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Utils configureNavigationBar:self.navigationController];
    [self configureNavButton];
    [self.navigationController setNavigationBarHidden:NO];
    [self registerNotification];
    //[self addTownsListFromFilter];
    [self.townsTableView reloadData];
    [[UITextField appearance] setTintColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1]];
    [self.townSearchBar becomeFirstResponder];
     self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterNotification];
}

- (void) configureNavButton {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
    [leftButton setContentMode:UIViewContentModeScaleAspectFit];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 23)];
    [rightButton setContentMode:UIViewContentModeScaleAspectFit];
    
    
    leftButton.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16];
    [leftButton setTitle:@"Отменить" forState:UIControlStateNormal];
    [leftButton setTitle:@"Отменить" forState:UIControlStateHighlighted];
    
    rightButton.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Medium" size:16];
    [rightButton setTitle:@"Готово" forState:UIControlStateNormal];
    [rightButton setTitle:@"Готово" forState:UIControlStateHighlighted];
    
    [leftButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    
    [rightButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    //[leftButton setBackgroundImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
    //[leftButton setBackgroundImage:[UIImage imageNamed:@"Back Tap.png"] forState:UIControlStateHighlighted];
    
    [leftButton addTarget:self action:@selector(backButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(readyButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    //[leftButton addTarget:self action:@selector(profileButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton_ = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    UIBarButtonItem *rightButton_ = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -25;
        UIBarButtonItem *negativeSpacerRight = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacerRight.width = -30;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftButton_, nil]];
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacerRight, rightButton_, nil]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [self.navigationItem setLeftBarButtonItem:leftButton_];
        [self.navigationItem setRightBarButtonItem:rightButton_];
    }

}
- (void) backButtonTap:(UIButton *)sender {
    //[self showNotification];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) readyButtonTap:(UIButton *)sender {
    if(self.selectedPath) {
        City *city = [self.allCities objectAtIndex:self.selectedPath.row];
        //[self showNotification];
        [self.navigationController popViewControllerAnimated:YES];
        if([self.delegate respondsToSelector:@selector(newTownSelected:)]) {
            [self.delegate newTownSelected:city];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - hide keyboard
- (void) hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - notifications 
- (void) registerNotification {
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurrentView:) name:kNeedUpdateCitiesListView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldTextChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void) unregisterNotification {
  //  [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedUpdateCitiesListView object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
//


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
    //townCell.isSelectedImgView.hidden = ![self checkAddedMark:city];
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
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //[[DataStorage sharedDataStorage] removeCitiesFromUserFilter];
    //city = [[DataStorage sharedDataStorage] insertCityObjectToContext:city];
    //[[DataStorage sharedDataStorage] setCityToUserFilter:city];
    City *city = [self.allCities objectAtIndex:indexPath.row];
    self.townSearchBar.text = city.cityName;
    self.selectedPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - search bar

- (void) textFieldTextChange {
    if (self.townSearchBar.text.length > 0) {
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:self.townSearchBar.text,@"query",@"20",@"limit",nil];
        [[HPBaseNetworkManager sharedNetworkManager] findGeoLocation:dict];
    } else {
        [self.allCities removeAllObjects];
       // [self addTownsListFromFilter];
        [self.townsTableView reloadData];
    }
}



@end

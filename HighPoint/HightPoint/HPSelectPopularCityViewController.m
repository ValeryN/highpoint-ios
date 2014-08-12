//
//  HPSelectPopularCityViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 12.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSelectPopularCityViewController.h"
#import "HPTownTableViewCell.h"
#import "DataStorage.h"
#import "City.h"

@interface HPSelectPopularCityViewController ()

@end

@implementation HPSelectPopularCityViewController

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
    self.citiesTableView.delegate = self;
    self.citiesTableView.dataSource = self;
    [self createNavigationItem];
    self.navigationItem.title = NSLocalizedString(@"POPULAR_CITIES_TITLE", nil);
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.popularCities = [[[DataStorage sharedDataStorage] getPopularCities] fetchedObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - navigation bar
- (void) createNavigationItem
{
    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Back.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Back Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, 11, 22);
    [newButton setBackgroundImage: image forState: UIControlStateNormal];
    [newButton setBackgroundImage: highlighedImage forState: UIControlStateHighlighted];
    [newButton addTarget: self
                  action: action
        forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    return newbuttonItem;
}

- (void) backbuttonTaped: (id) sender
{
    [self.navigationController popViewControllerAnimated: YES];
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
    City *city = [self.popularCities objectAtIndex:indexPath.row];
    [townCell configureCell:city];
    return townCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.popularCities.count;
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
    NSLog(@"index object = %@",((City *)[self.popularCities objectAtIndex:indexPath.row]).cityName);
    City *cityForFilter = [self.popularCities objectAtIndex:indexPath.row];
    [[DataStorage sharedDataStorage]  setCityToUserFilter:cityForFilter];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}


@end

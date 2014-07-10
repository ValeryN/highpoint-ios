//
//  HPUserInfoViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoViewController.h"
#import "HPTownTableViewCell.h"

@interface HPUserInfoViewController ()

@end

@implementation HPUserInfoViewController

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
    [self createSegmentedController];
    [self createNavigationItem];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation bar switch

- (void) createSegmentedController
{
    if (!navSegmentedController)
    {
        navSegmentedController = [[UISegmentedControl alloc]initWithItems:@[@"Фотоальбом",@"Информация"]];
        [navSegmentedController setSegmentedControlStyle:UISegmentedControlStyleBar];
        [navSegmentedController sizeToFit];
        [navSegmentedController addTarget:self action:@selector(segmentedControlValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [navSegmentedController setSelectedSegmentIndex:0];
        self.infoTableView.hidden = YES;
        self.navigationItem.titleView = navSegmentedController;
    }
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //open photo
            self.infoTableView.hidden = YES;
            break;}
        case 1:{
            //open info
            self.infoTableView.hidden = NO;
            break;}
    }
}

#pragma mark - create navigation item
- (void) createNavigationItem
{

    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Down.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Down Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
}
- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
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
    townCell.townNameLabel.text = self.user.name;
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
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end

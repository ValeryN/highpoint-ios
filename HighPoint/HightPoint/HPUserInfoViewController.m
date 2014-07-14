//
//  HPUserInfoViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoViewController.h"
#import "HPTownTableViewCell.h"
#import "HPAddPhotoMenuViewController.h"


#define GREEN_BUTTON_BOTTOM 20
#define PHOTOS_NUMBER 4
#define SPACE_BETWEEN_PHOTOS 20


@interface HPUserInfoViewController ()
{
    HPAddPhotoMenuViewController *addPhotoViewController;
}

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
    [self createGreenButton];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
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
            self.carousel.hidden = NO;
            
            break;}
        case 1:{
            //open info
            self.infoTableView.hidden = NO;
            self.carousel.hidden = YES;
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


#pragma mark - green button 
- (void) createGreenButton
{
    HPGreenButtonVC* sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
    sendMessage.view.translatesAutoresizingMaskIntoConstraints = NO;
    sendMessage.delegate = self;
    
    CGRect rect = sendMessage.view.frame;
    CGRect bounds = [UIScreen mainScreen].bounds;
    rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f;
    rect.origin.y = bounds.size.height - rect.size.height - GREEN_BUTTON_BOTTOM;
    sendMessage.view.frame = rect;
    
    [self addChildViewController: sendMessage];
    [self.view addSubview: sendMessage.view];
    
    [self createGreenButtonsConstraint: sendMessage];
}


- (void) createGreenButtonsConstraint: (HPGreenButtonVC*) sendMessage
{
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.width]];
    
    [sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: sendMessage.view.frame.size.height]];
}


- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    NSLog(@"Green button pressed");
}


#pragma mark - add photo 


- (IBAction)addPhotoBtnTap:(id)sender {
    [self addPhotoMenuShow];
}


- (void) addPhotoMenuShow {
    if (!addPhotoViewController) {
        addPhotoViewController = [[HPAddPhotoMenuViewController alloc] initWithNibName: @"HPAddPhotoMenuViewController" bundle: nil];
    }
    [[[[[UIApplication sharedApplication]delegate] window] rootViewController].view addSubview:addPhotoViewController.view];
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



#pragma mark - iCarousel data source -

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return PHOTOS_NUMBER;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    view = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"img_sample"]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    view.frame = rect;
    return view;
}

#pragma mark - iCarousel delegate -

- (CGFloat)carousel: (iCarousel *)carousel valueForOption: (iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionFadeMin:
            return -1;
        case iCarouselOptionFadeMax:
            return 1;
        case iCarouselOptionFadeRange:
            return 2.0;
       case iCarouselOptionCount:
            return 10;
        case iCarouselOptionSpacing:
            return value * 1.3;
        default:
            return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
        return 320;
}


@end

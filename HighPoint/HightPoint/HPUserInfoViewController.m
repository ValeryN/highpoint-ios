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
#import "Utils.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"

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
    
    self.topBarView.translatesAutoresizingMaskIntoConstraints = YES;
    self.infoTableView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self createPhotoCountView];
    //self.view.backgroundColor = [UIColor greenColor];
    //self.carousel.hidden = YES;
    //self.infoTableView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation bar switch

- (void) createSegmentedController
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"FuturaPT-Light" size:15], UITextAttributeFont,
                                [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0], UITextAttributeTextColor, nil];
    
    NSDictionary *highlightedAttributes = [NSDictionary
                                           dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FuturaPT-Light" size:15], UITextAttributeFont, [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:193.0/255.0 alpha:1.0], UITextAttributeTextColor, nil];
    
    [self.navSegmentedController setTitleTextAttributes:highlightedAttributes  forState:UIControlStateNormal];
    [self.navSegmentedController setTitleTextAttributes: attributes forState:UIControlStateSelected];
    
}

-(IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //open photo
            self.infoTableView.hidden = YES;
            self.carousel.hidden = NO;
            self.photoCountView.hidden = NO;
            [self createGreenButton];
            break;}
        case 1:{
            //open info
            self.infoTableView.hidden = NO;
            self.carousel.hidden = YES;
            self.photoCountView.hidden = YES;
            NSLog(@"%@", self.user);
            [self removeGreenButton];
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
- (void) createPhotoCountView {
    self.photoCountView.backgroundColor = [UIColor clearColor];
    self.photoCountView.translatesAutoresizingMaskIntoConstraints = YES;
    UIView *temp = [Utils getFhotoCountViewForText:@"1/1"];
    CGRect fr = self.photoCountView.frame;
    fr.size.width = temp.frame.size.width;
    fr.size.height = temp.frame.size.height;
    self.photoCountView.frame = fr;
    [self.photoCountView addSubview:temp];
    
    //self.photoCountView.hidden = YES;
}
- (IBAction) backbuttonTaped: (id) sender
{
    if([self.delegate respondsToSelector:@selector(profileWillBeHidden)]) {
        [self.delegate profileWillBeHidden];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - green button
- (void) removeGreenButton {
    [self.sendMessage.view removeFromSuperview];
    [self.sendMessage removeFromParentViewController];
    self.sendMessage = nil;
}
- (void) createGreenButton
{
    if(!self.sendMessage) {
        self.sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
        self.sendMessage.view.translatesAutoresizingMaskIntoConstraints = YES;
        self.sendMessage.delegate = self;
        [self.sendMessage initObjects:@"Написать ей"];
        CGRect rect = self.sendMessage.view.frame;
        CGRect bounds = [UIScreen mainScreen].bounds;
        rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f;
        rect.origin.y = bounds.size.height - rect.size.height - GREEN_BUTTON_BOTTOM;
        self.sendMessage.view.frame = rect;
        [self addChildViewController: self.sendMessage];
        [self.view addSubview: self.sendMessage.view];
        [self.sendMessage didMoveToParentViewController:self];
        [self createGreenButtonsConstraint];
    }
}
- (void) createGreenButtonsConstraint
{
    [self.sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: self.sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: self.sendMessage.view.frame.size.width]];
    
    [self.sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: self.sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: self.sendMessage.view.frame.size.height]];
}
#pragma mark - component animation

- (void) moveGreenButtonDown
{
    if(self.sendMessage) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.sendMessage.view.frame;
             rect.origin.y = rect.origin.y + 100;
             self.sendMessage.view.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}

//==============================================================================

- (void) moveGreenButtonUp
{
    if(self.sendMessage) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.sendMessage.view.frame;
             rect.origin.y = rect.origin.y - 100;
             self.sendMessage.view.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}
- (void) movePhotoViewToLeft
{
    if(self.photoCountView) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.photoCountView.frame;
             rect.origin.x = rect.origin.x - 150;
             self.photoCountView.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}

//==============================================================================

- (void) movePhotoViewToRight
{
    if(self.photoCountView) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.photoCountView.frame;
             rect.origin.x = rect.origin.x + 150;
             self.photoCountView.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}
- (void) hideTopBar {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}
- (void) showTopBar {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}
//==============================================================================


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
    UITableViewCell *townCell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:townCellIdentifier];
    if (townCell == nil) {
        townCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:townCellIdentifier];
    }
    townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    if(indexPath.row == 0) {
        return [self configureFirstCell:townCell];
    }
    else if (indexPath.row == 1) {
        return [self configureSecondCell:townCell];
    }
    else if (indexPath.row == 2) {
        return [self configureThirdCell:townCell];
    }
    else if (indexPath.row == 3) {
        return [self configureFourCell:townCell];
    }
    else if (indexPath.row == 4) {
        return [self configureFifthCell:townCell];
    }
    else return townCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return [self getFirstRowHeight];
    }
    else if(indexPath.row == 1) {
        return [self getSecondRowHeight];
    }
    else if(indexPath.row == 2) {
        return [self getThirdRowHeight];
    }
    else if(indexPath.row == 4) {
        return [self getFourRowHeight];
    }
    else if(indexPath.row == 5) {
        return [self getFifthRowHeight];
    }
    else return 100;
}
- (UITableViewCell*) configureFirstCell:(UITableViewCell*) cell {
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, cell.contentView.frame.size.width - 26, cell.contentView.frame.size.height)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.numberOfLines = 0;
    textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    textLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    textLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:textLabel];
    NSMutableString *text;
    if([self.user.gender intValue] == 2) {
        text = [NSMutableString stringWithString:@"Привыкла"];
    } else {
        text = [NSMutableString stringWithString:@"Привык"];
    }
    [text appendFormat:@" тратить на развлечения от $%d до $%d за вечер",[self.user.minentertainment.amount intValue],  [self.user.maxentertainment.amount intValue] ] ;//[Utils currencyConverter: self.user.minentertainment.currency]
    textLabel.text = text;
    [cell addSubview:textLabel];
    return cell;
}
- (UITableViewCell*) configureSecondCell:(UITableViewCell*) cell {
    UIView *t = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 40.0)];
    t.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:t];
    
    //textLabel.text = text;
    return cell;
    
}
- (UITableViewCell*) configureThirdCell:(UITableViewCell*) cell {
    return cell;
}
- (UITableViewCell*) configureFourCell:(UITableViewCell*) cell {
    return cell;
}
- (UITableViewCell*) configureFifthCell:(UITableViewCell*) cell {
    return cell;
}
- (CGFloat) getFirstRowHeight {
    return 100.0;
}
- (CGFloat) getSecondRowHeight {
    return 100.0;
}
- (CGFloat) getThirdRowHeight {
    return 100.0;
}
- (CGFloat) getFourRowHeight {
    return 100.0;
}
- (CGFloat) getFifthRowHeight {
    return 100.0;
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
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    self.tapState = !self.tapState;
    if(self.tapState) {
        [self moveGreenButtonDown];
        [self movePhotoViewToLeft];
        [self hideTopBar];
    } else {
        [self moveGreenButtonUp];
        [self movePhotoViewToRight];
        [self showTopBar];
    }
    
    
}
- (UITapGestureRecognizer*) addTapGesture
{
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGest.cancelsTouchesInView = NO;
    tapGest.numberOfTouchesRequired = 1;
    [tapGest setDelegate:self];
    return tapGest;
}
- (void)tapGesture:(UIPanGestureRecognizer *)recognizer {
    [self moveGreenButtonDown];
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

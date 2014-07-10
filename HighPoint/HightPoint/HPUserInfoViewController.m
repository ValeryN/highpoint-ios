//
//  HPUserInfoViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoViewController.h"

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
        self.navigationItem.titleView = navSegmentedController;
    }
}

-(void)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //open photo
            break;}
        case 1:{
            //open info
            break;}
    }
}

#pragma mark - create navigation item
- (void) createNavigationItem
{

    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Close.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Close Tap.png"]
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

@end

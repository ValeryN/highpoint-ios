//
//  HPSelectTownViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 23.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSelectTownViewController.h"
#import "Utils.h"
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
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Utils configureNavigationBar:self.navigationController];
    [self configureNavButton];
    [self.navigationController setNavigationBarHidden:NO];
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

@end

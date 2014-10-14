//
//  HPMakeAvatarViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPMakeAvatarViewController.h"
#import "Utils.h"
#import "UINavigationController+HighPoint.h"

#define ScreenBound       ([[UIScreen mainScreen] bounds])
#define ScreenHeight      (ScreenBound.size.height)


#define CONSTRAINT_GREENBUTTON_FROM_BOTTOM 47.0

@interface HPMakeAvatarViewController ()

@end

@implementation HPMakeAvatarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.cropRect = CGRectMake(0,0,120,120);
        self.minimumScale = 0.2;
        self.maximumScale = 10;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    
    //[self reset:YES];
    
    // Do any additional setup after loading the view from its nib.
    //self.sourceImage = [UIImage imageNamed:@"10.jpg"];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Utils configureNavigationBar:self.navigationController];
    [self configureNavButton];
    [self.navigationController setNavigationBarHidden:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //[self configureImage];
    [self configureGreenButton];
    self.cropRect = CGRectMake((self.frameView.frame.size.width-304)/2.0f, (self.frameView.frame.size.height-304)/2.0f, 304, 304);
    [self reset:YES];
    
}
- (void) configureNavButton {
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [leftButton setContentMode:UIViewContentModeScaleAspectFit];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Close.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Close Tap.png"] forState:UIControlStateHighlighted];
    
    [leftButton addTarget:self action:@selector(backButtonTap:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton_ = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    //UIBarButtonItem *rightButton_ = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = 0;
        
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, leftButton_, nil]];
        //[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacerRight, rightButton_, nil]];
    } else {
        // Just set the UIBarButtonItem as you would normally
        [self.navigationItem setLeftBarButtonItem:leftButton_];
        //[self.navigationItem setRightBarButtonItem:rightButton_];
    }
    self.navigationItem.title = @"Кадрируйте фотографию";
}

- (void) configureGreenButton {
    if(!self.greenButton && !self.tappedGreenButton) {
        self.greenButton = [Utils getViewForGreenButtonForText:@"  Готово"  andTapped:NO];
        self.tappedGreenButton = [Utils getViewForGreenButtonForText:@"  Готово"  andTapped:YES];
        CGRect rect = self.greenButton.frame;
        rect.origin.x = 320.0 / 2 - self.greenButton.frame.size.width / 2;
        rect.origin.y = ScreenHeight - CONSTRAINT_GREENBUTTON_FROM_BOTTOM;
        self.greenButton.frame = rect;
        self.tappedGreenButton.frame = rect;
        
        
        UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
        newButton.frame = rect;
        [newButton addTarget: self
                      action: @selector(avatarReadyDown)
            forControlEvents: UIControlEventTouchDown];
        [newButton addTarget: self
                      action: @selector(avatarReadyUp)
            forControlEvents: UIControlEventTouchUpInside];
        self.tappedGreenButton.hidden = YES;
        [self.view addSubview:self.greenButton];
        [self.view addSubview:self.tappedGreenButton];
        [self.view addSubview:newButton];
    }
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void) backButtonTap:(id) sender {
    [self cancelAction:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) avatarReadyDown {
    self.greenButton.hidden = YES;
    self.tappedGreenButton.hidden = NO;
}
- (void) avatarReadyUp {
    self.greenButton.hidden = NO;
    self.tappedGreenButton.hidden = YES;
    [self doneAction:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

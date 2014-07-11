//
//  HPCurrentUserViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserViewController.h"
#import "HPChatListViewController.h"
#import "HPCurrentUserPointViewController.h"
#import "HPCurrentUserCardViewController.h"
#import "HPConciergeViewController.h"

@interface HPCurrentUserViewController ()

@end

@implementation HPCurrentUserViewController {
    HPCurrentUserPointViewController *userPointController;
}

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
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backButtonTap:(id)sender {
    [self.navigationController popViewControllerAnimated: YES];
}

- (IBAction)bubbleButtonTap:(id)sender {
    HPChatListViewController* chatList = [[HPChatListViewController alloc] initWithNibName: @"HPChatListViewController" bundle: nil];
    [self.navigationController pushViewController:chatList animated:YES];
}



#pragma mark - iCarousel data source -

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return 3;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    
    if (index == 0) {
        userPointController = [[HPCurrentUserPointViewController alloc] initWithNibName:@"HPCurrentUserPointViewController" bundle:nil];
        view = userPointController.view;
    }
    if (index == 1) {
        view = [[HPConciergeViewController alloc] initWithNibName:@"HPConciergeViewController" bundle:nil].view;
    }
    if (index == 2) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 264, 416)];
        view.backgroundColor = [UIColor whiteColor];
    }
    CGRect rect = CGRectMake(14, 0, [UIScreen mainScreen].bounds.size.width - 30, 380);
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

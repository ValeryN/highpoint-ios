//
//  HPRootViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPRootViewController.h"
#import "HPBaseNetworkManager.h"
#import "HPMainViewListTableViewCell.h"
#import "Utils.h"
#import "UIImage+HighPoint.h"

//==============================================================================

#define CELL_HEIGHT 104
#define CELLS_COUNT 20  //  for test purposes only remove on production

//==============================================================================

@implementation HPRootViewController

//==============================================================================

#pragma mark - controller view delegate -

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    UIStoryboard *storyBoard;
    storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    if(!self.bottomSwitch)
    {
        self.bottomSwitch = [[HPSwitchViewController alloc] initWithNibName: @"HPSwitch" bundle: nil];
        [self addChildViewController:self.bottomSwitch];
        [self.view insertSubview:self.bottomSwitch.view atIndex:2];
        [self.bottomSwitch didMoveToParentViewController:self];
    }
    _crossDissolveAnimationController = [[CrossDissolveAnimation alloc] initWithNavigationController:self.navigationController];
    self.navigationController.delegate = self;
}

//==============================================================================

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

//==============================================================================

#pragma mark - Configure Navigation bar method -

//==============================================================================

- (void) configureNavigationBar {
    [Utils configureNavigationBar:[self navigationController]];
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [leftButton setContentMode:UIViewContentModeScaleAspectFit];
    
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Profile Tap.png"] forState:UIControlStateHighlighted];
    
    [leftButton addTarget:self action:@selector(profileButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];

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
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 25)];
    [rightButton setContentMode:UIViewContentModeScaleAspectFit];
    
    [rightButton addSubview:self.notificationView];
    
    [rightButton setBackgroundImage:[UIImage imageNamed:@"Bubble.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"Bubble Tap.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(bubbleButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton_ = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // Add a negative spacer on iOS >= 7.0
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = 0;
        
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, rightButton_, nil]];
        
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowColor: [UIColor clearColor]];
        [shadow setShadowOffset: CGSizeMake(0.0f, 0.0f)];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [UIFont fontWithName:@"FuturaPT-Light" size:18.0f], NSFontAttributeName,
                                                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                         shadow, NSShadowAttributeName,nil]];
        [self.navigationItem setTitle:@"Москва, девушки 80-100"];
        
    } else {
        
        [self.navigationItem setRightBarButtonItem:rightButton_];
        [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                                UITextAttributeTextColor: [UIColor whiteColor],
                                                                UITextAttributeTextShadowColor: [UIColor clearColor],
                                                                UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)],
                                                                UITextAttributeFont: [UIFont fontWithName:@"FuturaPT-Light" size:18.0f]
                                                                }];
        [self.navigationItem setTitle:@"Москва, девушки 80-100"];
    }
}

//==============================================================================

#pragma mark - Navigation bar button tap handler -

//==============================================================================

- (void) profileButtonPressedStart: (id) sender
{
    [self showNotification];
}
//==============================================================================

- (void) bubbleButtonPressedStart: (id) sender
{
    [self hideNotification];
}

//==============================================================================

#pragma mark - filter button tap handler -

//==============================================================================

- (IBAction) filterButtonTap: (id)sender
{
    UIStoryboard *storyBoard;
    //self.view.userInteractionEnabled = NO;
    storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    
    HPFilterSettingsViewController *filter = [storyBoard instantiateViewControllerWithIdentifier:@"HPFilterSettingsViewController"];
     
    _crossDissolveAnimationController.viewForInteraction = filter.view;
    [self.navigationController pushViewController:filter animated:YES];

}

//==============================================================================

#pragma mark - TableView and DataSource delegate -

//==============================================================================

- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}

//==============================================================================

- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return CELLS_COUNT;
}

//==============================================================================

- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    return CELL_HEIGHT;
}

//==============================================================================

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *mainCellId = @"maincell";
    HPMainViewListTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier:mainCellId];
    if (!mCell)
        mCell = [[HPMainViewListTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: mainCellId];

    UIImage* img =[UIImage imageNamed: @"img_sample1"];
    if (indexPath.row == 3)
        img = [img applyBlurWithRadius: 5.0];

    UIImage* img_ = [img maskImageWithPattern: [UIImage imageNamed:@"Userpic Mask"]];
    mCell.userImageBorder.autoresizingMask = UIViewAutoresizingNone;
    mCell.userImage.autoresizingMask = UIViewAutoresizingNone;
    mCell.userImage.image = img_;
    mCell.userImageBorder.image = [UIImage imageNamed:@"Userpic Shape Green"];
    
    mCell.firstLabel.textColor = [UIColor whiteColor];
    mCell.firstLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:18.0 ];
    mCell.firstLabel.text = @"Анастасия Шляпова";
    
    mCell.secondLabel.textColor = [UIColor whiteColor];
    mCell.secondLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0f];
    mCell.secondLabel.text = @"99 лет, Когалым";
    
    mCell.point.textColor = [UIColor whiteColor];
    mCell.point.font = [UIFont fontWithName:@"FuturaPT-Book" size:15.0f];
    mCell.point.text = @"У нас тут очень весело. Если кто не боится таких развлечений, пишите!";
    
    mCell.backgroundColor = [UIColor clearColor];
    [mCell addGestureRecognizer];

    return mCell;
}

//==============================================================================

- (void) tableView: (UITableView*) tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath
{
    HPMainViewListTableViewCell* cell = (HPMainViewListTableViewCell*)[self.mainListTable cellForRowAtIndexPath: indexPath];
    HPUserCardViewController* card = [[HPUserCardViewController alloc] initWithNibName: @"HPUserCard" bundle: nil];
    card.delegate = self;
    [card.navigationController setNavigationBarHidden: YES];

    CGRect test__ = [self.view convertRect: cell.frame
                                  fromView: self.mainListTable];

    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    card.userImage = [[UIImageView alloc] initWithImage:img];
    card.userImage.frame = CGRectMake(0, 0, 264.0, 356.0);
    card.userImage.center = CGPointMake(test__.origin.x + 45, test__.origin.y + 40);
    self.savedFrame = card.userImage.frame;
    card.userImage.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [card.view addSubview:card.userImage];

    [UIView animateWithDuration: 0.7
                          delay: 0
                        options: UIViewAnimationOptionTransitionNone
                     animations: ^
                            {
                                card.userImage.frame = CGRectMake(card.view.center.x - card.userImage.frame.size.width/2.0, 257.0, card.userImage.frame.size.width, card.userImage.frame.size.height);
                                card.userImage.transform = CGAffineTransformIdentity;
                            }
                     completion: ^(BOOL finished)
                            {
                                [card.userImage removeFromSuperview];
                                card.carouselView.hidden = NO;
                                card.carouselView.currentItemView.hidden = NO;
                            }];
    
    _crossDissolveAnimationController.viewForInteraction = card.view;
    [self.navigationController pushViewController: card animated: YES];
}

//==============================================================================

- (void) startAnimation:(UIImageView *)image
{
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    UIImageView *temp = [[UIImageView alloc] initWithImage:img];
    
    
    temp.frame = CGRectMake(self.view.center.x - temp.frame.size.width/2.0, self.view.center.y - temp.frame.size.height/2.0, temp.frame.size.width, temp.frame.size.height);
    [self.view addSubview:temp];

    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        temp.frame = self.savedFrame;
        temp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];
}

//==============================================================================

#pragma mark - Notification view hide/show method -

//==============================================================================

- (void) hideNotification
{
    [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.notificationView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];

}

//==============================================================================

- (void) showNotification
{
    [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.notificationView.hidden = NO;
                    }
                    completion:^(BOOL finished){
                        
                    }];
}

//==============================================================================

#pragma mark - Navigation Controller Delegate -

//==============================================================================

- (id<UIViewControllerAnimatedTransitioning>) navigationController: (UINavigationController *)navigationController
                                   animationControllerForOperation: (UINavigationControllerOperation)operation
                                                fromViewController: (UIViewController *)fromVC
                                                  toViewController: (UIViewController *)toVC
{
    BaseAnimation *animationController;
    animationController = _crossDissolveAnimationController;
    switch (operation) {
        case UINavigationControllerOperationPush:
            animationController.type = AnimationTypePresent;
            return  animationController;
        case UINavigationControllerOperationPop:
            animationController.type = AnimationTypeDismiss;
            return animationController;
        default: return nil;
    }
}

//==============================================================================

@end

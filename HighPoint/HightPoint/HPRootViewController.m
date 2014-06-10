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
#import "UINavigationController+HighPoint.h"
#import "UIDevice+HighPoint.h"
#import "UILabel+HighPoint.h"

//==============================================================================

#define CELLS_COUNT 20  //  for test purposes only remove on production
#define BOTTOM_SHIFT 20

//==============================================================================

@implementation HPRootViewController

//==============================================================================

#pragma mark - controller view delegate -

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    self.view.backgroundColor = [UIColor colorWithRed: 30.0 / 255.0
                                                green: 29.0 / 255.0
                                                 blue: 48.0 / 255.0
                                                alpha: 1.0];
    
    [self createSwitch];
    _crossDissolveAnimationController = [[CrossDissolveAnimation alloc] initWithNavigationController:self.navigationController];
    self.navigationController.delegate = self;
}

//==============================================================================

- (void) createSwitch
{
    if (!_bottomSwitch)
    {
        _bottomSwitch = [[HPSwitchViewController alloc] initWithNibName: @"HPSwitch" bundle: nil];
        _bottomSwitch.delegate = self;
        [self addChildViewController: _bottomSwitch];
        [self.view addSubview: _bottomSwitch.view];

        CGRect rect = [UIScreen mainScreen].bounds;
        CGFloat shift = [UIDevice hp_isIOS7] ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
        rect = CGRectMake(fabs(rect.size.width - _bottomSwitch.view.frame.size.width) / 2,
                         rect.size.height - _bottomSwitch.view.frame.size.height - BOTTOM_SHIFT - shift,
                         _bottomSwitch.view.frame.size.width,
                         _bottomSwitch.view.frame.size.height);
        [_bottomSwitch positionSwitcher: rect];
    }
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

- (UIBarButtonItem*) createLeftButton
{
    UIButton* leftButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 26, 26)];
    [leftButton setContentMode: UIViewContentModeScaleAspectFit];
    [leftButton setBackgroundImage:[UIImage imageNamed: @"Profile.png"] forState: UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed: @"Profile Tap.png"] forState: UIControlStateHighlighted];
    [leftButton addTarget: self action: @selector(profileButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView: leftButton];
}

//==============================================================================

- (UIBarButtonItem*) createRightButton
{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 25)];
    [rightButton setContentMode: UIViewContentModeScaleAspectFit];
    
    [rightButton addSubview: self.notificationView];
    
    [rightButton setBackgroundImage:[UIImage imageNamed: @"Bubble.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed: @"Bubble Tap.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(bubbleButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView: rightButton];
}

//==============================================================================

- (void) configureNavigationBar
{
    [self.navigationController hp_configureNavigationBar];
    UIBarButtonItem *profileButton = [self createLeftButton];
    [self.navigationItem setLeftBarButtonItem: profileButton];
    
    self.notificationView = [Utils getNotificationViewForText: @"8"];
    
    UIBarButtonItem* chatsButton = [self createRightButton];
    [self.navigationItem setRightBarButtonItem: chatsButton];
    
    UIColor* color = [UIColor colorWithRed: 230.0 / 255.0
                                     green: 236.0 / 255.0
                                      blue: 242.0 / 255.0
                                     alpha: 1.0];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            UITextAttributeTextColor: color,
                                                            UITextAttributeTextShadowColor: [UIColor clearColor],
                                                            UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)],
                                                            UITextAttributeFont: [UIFont fontWithName:@"FuturaPT-Light" size:18.0f]
                                                            }];
    [self.navigationItem setTitle: @"Москва, девушки 80-100"];
}

//==============================================================================

#pragma mark - Navigation bar button tap handler -

//==============================================================================

- (void) profileButtonPressedStart: (id) sender
{
    [self showNotificationBadge];
}
//==============================================================================

- (void) bubbleButtonPressedStart: (id) sender
{
    [self hideNotificationBadge];
}

//==============================================================================

#pragma mark - filter button tap handler -

//==============================================================================

- (IBAction) filterButtonTap: (id)sender
{
    HPFilterSettingsViewController* filter = [[HPFilterSettingsViewController alloc] initWithNibName:@"HPFilterSettings" bundle:nil];
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

- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *mainCellId = @"maincell";
    HPMainViewListTableViewCell *mCell = [tableView dequeueReusableCellWithIdentifier: mainCellId];
    if (!mCell)
        mCell = [[HPMainViewListTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: mainCellId];

    [mCell configureCell];
    if (indexPath.row == 3)
        [mCell makeAnonymous];
    
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

- (void) hideNotificationBadge
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

- (void) showNotificationBadge
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

#pragma mark - HPSwitch Delegate -

//==============================================================================

- (void) switchedToLeft
{
    NSLog(@"switched into left");
}

//==============================================================================

- (void) switchedToRight
{
    NSLog(@"switched into right");
}

//==============================================================================

@end

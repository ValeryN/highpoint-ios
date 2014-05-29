//
//  HPRootViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRootViewController.h"
#import "HPBaseNetworkManager.h"
#import "HPMainViewListTableViewCell.h"
#import "Utils.h"

#import "ScaleAnimation.h"
#import "CrossDissolveAnimation.h"


#define HALFHIDE_MAININFO_DURATION 0.2
#define SHOWPOINT_COMPLETELY_DURATION 0.2

@interface HPRootViewController () {
    ScaleAnimation *_scaleAnimationController;
    CrossDissolveAnimation *_crossDissolveAnimationController;
}
@end

@implementation HPRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark -
#pragma mark controller view delegate
- (void)viewDidLoad {
    [super viewDidLoad];//34,45,77,90 30, 29, 48
    [self configureNavigationBar];
    self.view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    UIStoryboard *storyBoard;
    //self.view.userInteractionEnabled = NO;
    storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    if(!self.bottomSwitch) {
        self.bottomSwitch = [storyBoard instantiateViewControllerWithIdentifier:@"HPSwitchViewController"];
        [self addChildViewController:self.bottomSwitch];
        [self.view insertSubview:self.bottomSwitch.view atIndex:2];
        [self.bottomSwitch didMoveToParentViewController:self];
    }
    //_scaleAnimationController = [[ScaleAnimation alloc] initWithNavigationController:self.navigationController];
    _crossDissolveAnimationController = [[CrossDissolveAnimation alloc] initWithNavigationController:self.navigationController];
    //self.navigationItem.leftBarButtonItem = btnAdd_;
    // Do any additional setup after loading the view.
    self.navigationController.delegate = self;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    //[[HPBaseNetworkManager sharedNetworkManager] startNetworkStatusMonitor];
    //[[HPBaseNetworkManager sharedNetworkManager] setNetworkStatusMonitorCallback];
    
    
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark -
#pragma mark Configure Navigation bar method
- (void) configureNavigationBar {
    [Utils configureNavigationBar:[self navigationController]];
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[self navigationController].navigationBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
    } else {
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
        [[self navigationController].navigationBar setTintColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
    }
    */
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [leftButton setContentMode:UIViewContentModeScaleAspectFit];
    
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateNormal];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"Profile Tap.png"] forState:UIControlStateHighlighted];
    
    [leftButton addTarget:self action:@selector(profileButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
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
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 25)];
    [rightButton setContentMode:UIViewContentModeScaleAspectFit];
    
    [rightButton addSubview:self.notificationView];
    
    [rightButton setBackgroundImage:[UIImage imageNamed:@"Bubble.png"] forState:UIControlStateNormal];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"Bubble Tap.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(bubbleButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    //[rightButton addTarget:self action:@selector(bubbleButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
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
        //self.navigationController.navigationItem.title = @"Дэвушки";
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
#pragma mark -
#pragma mark Navigation bar button tap handler
- (void) profileButtonPressedStart:(id) sender {
    [self showNotification];
}
- (void) bubbleButtonPressedStart:(id) sender {
    [self hideNotification];
}
#pragma mark -
#pragma mark filter button tap handler
- (IBAction) filterButtonTap:(id)sender {
    UIStoryboard *storyBoard;
    //self.view.userInteractionEnabled = NO;
    storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    
    HPFilterSettingsViewController *filter = [storyBoard instantiateViewControllerWithIdentifier:@"HPFilterSettingsViewController"];
     
    _crossDissolveAnimationController.viewForInteraction = filter.view;
    [self.navigationController pushViewController:filter animated:YES];

}
#pragma mark -
#pragma mark TableView and DataSource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *emptyCell = nil;
    static NSString *cellId = @"cell";
    static NSString *mainCellId = @"maincell";
    
    emptyCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!emptyCell) {
        emptyCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    emptyCell.backgroundColor = [UIColor clearColor];
    
    HPMainViewListTableViewCell *mCell = nil;
    
    mCell = [tableView dequeueReusableCellWithIdentifier:mainCellId];
    if (!mCell) {
        mCell = [[HPMainViewListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mainCellId];
    }
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    if(indexPath.row == 3) {
        img = [Utils applyBlurOnImage:img withRadius:10.0];
    }
    //img = [Utils scaleImage:img toSize:CGSizeMake(176/2, 176/2)];
    UIImage *img_ = [Utils maskImage:img];
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

    [self addLongTapGestureRecognizer: mCell];
    
    return mCell;
}
//select some book from list
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HPMainViewListTableViewCell *cell = (HPMainViewListTableViewCell *)[self.mainListTable cellForRowAtIndexPath:indexPath];
    NSLog(@"frame %f", cell.frame.origin.x);
    NSLog(@"frame %f", cell.frame.origin.y);
    
    /*
    CGRect test__ = [self.view convertRect:cell.frame fromView:self.mainListTable];
    NSLog(@"frame_ %f", test__.origin.x);
    NSLog(@"frame_ %f", test__.origin.y);
    
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    UIImageView *test = [[UIImageView alloc] initWithImage:img];
    test.frame = CGRectMake(-20, test__.origin.y - 40.0, test.frame.size.width, test.frame.size.height);
    [self.view addSubview:test];
    test.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:3 delay:0.0 usingSpringWithDamping:8.8 initialSpringVelocity:1.0 options:0 animations:^{
        test.transform = CGAffineTransformIdentity;
        test.frame = CGRectMake(self.view.center.x - test.frame.size.width/2.0, self.view.center.y - test.frame.size.height/2.0, test.frame.size.width, test.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    /*
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    UIImageView *test = [[UIImageView alloc] initWithImage:img];
    test.frame = CGRectMake(-20, test__.origin.y - 40.0, test.frame.size.width, test.frame.size.height);
    [self.view addSubview:test];
    test.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:3.9 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        test.transform = CGAffineTransformIdentity;
        test.frame = CGRectMake(self.view.center.x - test.frame.size.width/2.0, self.view.center.y - test.frame.size.height/2.0, test.frame.size.width, test.frame.size.height);
    } completion:^(BOOL finished){
        
    }];
    */
    UIStoryboard *storyBoard;
    //self.view.userInteractionEnabled = NO;
    storyBoard = [UIStoryboard storyboardWithName:[Utils getStoryBoardName] bundle:nil];
    
    HPUserCardViewController *card = [storyBoard instantiateViewControllerWithIdentifier:@"HPUserCardViewController"];
    card.delegate = self;
    
     [card.navigationController setNavigationBarHidden:YES];
    
    CGRect test__ = [self.view convertRect:cell.frame fromView:self.mainListTable];
    NSLog(@"frame_ %f", test__.origin.x);
    NSLog(@"frame_ %f", test__.origin.y);
    
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    card.userImage = [[UIImageView alloc] initWithImage:img];
    card.userImage.frame = CGRectMake(0, 0, 264.0, 356.0);
    card.userImage.center = CGPointMake(test__.origin.x + 45, test__.origin.y + 40);
    self.savedFrame = card.userImage.frame;
    card.userImage.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [card.view addSubview:card.userImage];
    
    
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        
        card.userImage.frame = CGRectMake(card.view.center.x - card.userImage.frame.size.width/2.0, 257.0, card.userImage.frame.size.width, card.userImage.frame.size.height);
        card.userImage.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        [card.userImage removeFromSuperview];
        card.carouselView.hidden = NO;
        card.carouselView.currentItemView.hidden = NO;
        
    }];
    
    _crossDissolveAnimationController.viewForInteraction = card.view;
    [self.navigationController pushViewController:card animated:YES];
    
}
- (void) startAnimation:(UIImageView *)image {
    //card.userImage.frame = CGRectMake(-20, test__.origin.y - 40.0, card.userImage.frame.size.width, card.userImage.frame.size.height);
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    UIImageView *temp = [[UIImageView alloc] initWithImage:img];
    
    
    temp.frame = CGRectMake(self.view.center.x - temp.frame.size.width/2.0, self.view.center.y - temp.frame.size.height/2.0, temp.frame.size.width, temp.frame.size.height);
    //card.userImage.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [self.view addSubview:temp];
    
    //image.transform = CGAffineTransformIdentity; UIViewAnimationOptionCurveEaseOut
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        //image.transform = CGAffineTransformIdentity;
        temp.frame = self.savedFrame;
        temp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        //image.transform = CGAffineTransformMakeScale(2.0, 2.0);
        
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];

}

- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur withRadius: (CGFloat)blurRadius {
    
    CIImage *originalImage = [CIImage imageWithCGImage: imageToBlur.CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur" keysAndValues: kCIInputImageKey, originalImage, @"inputRadius", @(blurRadius), nil];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage: outputImage fromRect: [outputImage extent]];
    return [UIImage imageWithCGImage: outImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -
#pragma mark Notification view hide/show method
- (void) hideNotification {
    
    [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.notificationView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];

}
- (void) showNotification {
    [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.notificationView.hidden = NO;
                    }
                    completion:^(BOOL finished){
                        
                    }];
}
#pragma mark - Navigation Controller Delegate

-(id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
 
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//==============================================================================

#pragma mark - Gesture recognizers -

//==============================================================================

- (void) addLongTapGestureRecognizer: (UIView*) cell
{
    UILongPressGestureRecognizer* longtapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellLongTap:)];
    [cell addGestureRecognizer: longtapRecognizer];
}

//==============================================================================

- (IBAction) cellLongTap: (id)sender
{
    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]] == NO)
        return;
    UILongPressGestureRecognizer* recognizer = sender;

    if ([recognizer.view isKindOfClass:[HPMainViewListTableViewCell class]] == NO)
        return;
    HPMainViewListTableViewCell* cell = (HPMainViewListTableViewCell*)recognizer.view;

    if (recognizer.state == UIGestureRecognizerStateBegan)
        [self showPoint: cell];
    
    if (recognizer.state == UIGestureRecognizerStateEnded)
        [self hidePoint: cell];
}

//==============================================================================

#pragma mark - show point animation -

//==============================================================================

- (void) showPoint: (HPMainViewListTableViewCell*) cell
{
    cell.showPointButton.image = [UIImage imageNamed: @"Point Notice Tap"];
    
    [UIView animateWithDuration: HALFHIDE_MAININFO_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
                     {
                         [self halfhideMaininfo: cell];
                     }
                     completion: ^(BOOL finished)
                     {
                         [self showpointCompletely: cell];
                     }];
}

//==============================================================================
 
- (void) hidePoint: (HPMainViewListTableViewCell*) cell
{
    cell.showPointButton.image = [UIImage imageNamed: @"Point Notice"];
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
                     {
                        [self fadeawayPointText: cell];
                     }
                     completion: ^(BOOL finished)
                     {
                         [self showMainInfo: cell];
                     }];
}

//==============================================================================

- (void) showpointCompletely: (HPMainViewListTableViewCell*) cell
{
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                      animations: ^
                      {
                          [self fullhideMaininfo: cell];
                      }
                      completion: ^(BOOL finished)
                      {
                      }];
}

//==============================================================================

- (void) halfhideMaininfo: (HPMainViewListTableViewCell*) cell
{
    CGRect rect = cell.mainInfoGroup.frame;
    rect.origin.x = -(rect.size.width + rect.origin.x) / 2.0;
    cell.mainInfoGroup.frame = rect;
}

//==============================================================================

- (void) fullhideMaininfo: (HPMainViewListTableViewCell*) cell
{
    cell.point.alpha = 1;
    
    CGRect rect = cell.mainInfoGroup.frame;
    rect.origin.x = 2 * rect.origin.x;
    cell.mainInfoGroup.frame = rect;
}

//==============================================================================

- (void) fadeawayPointText: (HPMainViewListTableViewCell*) cell
{
    cell.point.alpha = 0.5;
}

//==============================================================================

- (void) showMainInfo: (HPMainViewListTableViewCell*) cell
{
    [UIView animateWithDuration: SHOWPOINT_COMPLETELY_DURATION
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^
                     {
                         cell.point.alpha = 0.0;
                         
                         CGRect rect = cell.mainInfoGroup.frame;
                         rect.origin.x = 12;
                         cell.mainInfoGroup.frame = rect;
                     }
                     completion: ^(BOOL finished)
                     {
                     }];
}

//==============================================================================

@end

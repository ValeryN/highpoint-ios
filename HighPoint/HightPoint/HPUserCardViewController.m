//
//  HPUserCardViewController.m
//  HightPoint
//
//  Created by Andrey Anisimov on 13.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserCardViewController.h"
#import "Utils.h"
//#import "Constants.h"
@interface HPUserCardViewController ()

@end

@implementation HPUserCardViewController

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
    self.carouselView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    [self.profileButton setBackgroundImage:[UIImage imageNamed:@"Profile.png"] forState:UIControlStateNormal];
    [self.profileButton setBackgroundImage:[UIImage imageNamed:@"Profile Tap.png"] forState:UIControlStateHighlighted];
    
    [self.profileButton addTarget:self action:@selector(profileButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    self.notificationView = [Utils getNotificationViewForText:@"8"];
    [self.messageButton addSubview:self.notificationView];
    
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"Bubble.png"] forState:UIControlStateNormal];
    [self.messageButton setBackgroundImage:[UIImage imageNamed:@"Bubble Tap.png"] forState:UIControlStateHighlighted];
    [self.messageButton addTarget:self action:@selector(messageButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"Close Round.png"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"Close Round Tap"] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(backButtonPressedStart:) forControlEvents: UIControlEventTouchUpInside];
    
    self.nameLabel.font = [UIFont fontWithName:@"YesevaOne" size:24.0f];
    self.nameLabel.text = @"Октябрина";
    
    self.detailLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:16.0f];
    self.detailLabel.text = @"99 лет, Когалым";
    
    self.carouselView.type = iCarouselTypeRotary;
    self.carouselView.decelerationRate = 0.7;
    //_carousel.bounceDistance = 0.1;
    self.carouselView.scrollEnabled = YES;
    self.carouselView.exclusiveTouch = YES;
    
    self.carouselView.delegate = self;
    self.carouselView.dataSource = self;
    self.carouselView.hidden = YES;
    // Do any additional setup after loading the view.
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES];
    self.carouselView.currentItemView.hidden = YES;
    self.carouselView.currentItemView.layer.cornerRadius = 5;
    self.carouselView.currentItemView.layer.masksToBounds = YES;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}
#pragma mark -
#pragma mark Navigation bar button tap handler
- (void) profileButtonPressedStart:(UIButton *)sender {
    //[self showNotification];
}
- (void) messageButtonPressedStart:(UIButton *)sender {
    //[self showNotification];
}
- (void) backButtonPressedStart:(id) sender {
    //[self showNotification];
    //[self.userImage removeFromSuperview];
    [self.delegate startAnimation:self.userImage];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) pointButtonTap:(id) sender {
    
    self.viewState = !self.viewState;
    //[UIView beginAnimations:nil context:NULL];
    //[UIView setAnimationDuration:0.75];
    // checks to see if the view is attached
    //[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
    //                       forView:self.carouselView.currentItemView
    //                         cache:YES];
    
    //[UIView commitAnimations];
    
    if(self.viewState) {
        //flip from right
        
        UIView *container = self.carouselView.currentItemView;
        UIView *viewToShow = [self getCardBottomSide];
        
        [UIView transitionWithView:container
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            
                            [self clearViewForIndex:self.carouselView.currentItemIndex andImage:YES];
                            [self.carouselView.currentItemView addSubview:viewToShow];
                            
                        }
                        completion:^(BOOL finished){
                    }];

    } else {
        //flip from right
        UIView *container = self.carouselView.currentItemView;
        UIView *viewToShow = [self getCardTopSide];
        
        [UIView transitionWithView:container
                          duration:0.5
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^{
                            
                            [self clearViewForIndex:self.carouselView.currentItemIndex andImage:YES];
                            [self.carouselView.currentItemView addSubview:[self getBackgroundImage]];
                            [self.carouselView.currentItemView addSubview:viewToShow];
                            
                        }
                        completion:^(BOOL finished){
                            
                        }];
        
    }
    self.carouselView.currentItemView.layer.cornerRadius = 3;
    self.carouselView.currentItemView.layer.masksToBounds = YES;

}
- (UIView*) getCardTopSide {
    UIView *temp = [[UIView alloc] initWithFrame:self.carouselView.currentItemView.frame];
    temp.backgroundColor = [UIColor clearColor];
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 312, 32.0, 32.0)];
    [infoButton setImage:[UIImage imageNamed:@"Info Tap"] forState:UIControlStateHighlighted];
    [infoButton setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
    [temp addSubview:infoButton];
    UIButton *pointButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0, 12, 32.0, 32.0)];
    [pointButton setImage:[UIImage imageNamed:@"Point Tap"] forState:UIControlStateHighlighted];
    [pointButton setImage:[UIImage imageNamed:@"Point"] forState:UIControlStateNormal];
    [pointButton addTarget:self action:@selector(pointButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [temp addSubview:pointButton];
    [self.messButtonView removeFromSuperview];
    self.messButtonView = nil;
    self.messButtonView = [Utils getViewForGreenButtonForText:@"Написать ей" andTapped:NO];
    self.messButtonView.frame = CGRectMake(self.carouselView.currentItemView.frame.size.width/2 - self.messButtonView.frame.size.width/2 , 312, self.messButtonView.frame.size.width, self.messButtonView.frame.size.height);
    [temp addSubview:self.messButtonView];
    UIButton *messButton = [[UIButton alloc] initWithFrame:self.messButtonView.frame];
    [messButton addTarget:self action:@selector(messButtonPressedStart:) forControlEvents: UIControlEventTouchDown];
    [messButton addTarget:self action:@selector(messButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    [temp addSubview:messButton];
    return temp;
}
- (UIView*) getCardBottomSide {
    UIView *temp = [[UIView alloc] initWithFrame:self.carouselView.currentItemView.frame];
    temp.backgroundColor = [UIColor clearColor];
    
    
    UIImage *blureImg = [Utils applyBlurOnImage:[Utils scaleImage:self.userImage.image toSize:CGSizeMake(264.0 + 90, 356.0 + 90)]  withRadius:30.0];
    UIImageView *blureImgView = [[UIImageView alloc] initWithImage:blureImg];
    blureImgView.frame = CGRectMake(0, 0, 264.0, 356.0);
    blureImgView.contentMode = UIViewContentModeScaleToFill;

    [temp addSubview:blureImgView];
    UIImage *img =[UIImage imageNamed:@"img_sample1"];
    UIImage *img_ = [Utils maskImage:img];
    UIImageView *avaImg = [[UIImageView alloc] initWithImage:img_];
    avaImg.frame = CGRectMake(84.0, 52, 92.0, 92.0);    //image size
    UIImageView *borderImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Userpic Shape Green"]];
    borderImg.frame = CGRectMake(2, 2, 88.0, 88.0);     //border size
    avaImg.autoresizingMask = UIViewAutoresizingNone;
    borderImg.autoresizingMask = UIViewAutoresizingNone;
    [avaImg addSubview:borderImg];
    [temp addSubview:avaImg];
    
    
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.carouselView.currentItemView.frame.size.width/2.0 - 200/2, 130, 200, 100.0)];
    pointLabel.backgroundColor = [UIColor clearColor];
    pointLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0f];
    pointLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    pointLabel.text = @"Предпочитаю вкладывать деньги в акции, нефть, газ, и разведение хомячков";
    pointLabel.numberOfLines = 5;
    pointLabel.textAlignment = NSTextAlignmentCenter;
    [temp addSubview:pointLabel];
    
    UILabel *timeMarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.carouselView.currentItemView.frame.size.width/2.0 - 100/2, 7, 100, 25.0)];
    timeMarkLabel.backgroundColor = [UIColor clearColor];
    timeMarkLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:16.0f];
    timeMarkLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    timeMarkLabel.text = @"Год назад:";
    timeMarkLabel.numberOfLines = 5;
    timeMarkLabel.textAlignment = NSTextAlignmentCenter;
    [temp addSubview:timeMarkLabel];
    
    
    UIButton *heartButton = [[UIButton alloc] initWithFrame:CGRectMake(self.carouselView.currentItemView.frame.size.width/2.0 - 12, 250.0, 24.0, 20.0)];
    [heartButton setImage:[UIImage imageNamed:@"Heart Tap"] forState:UIControlStateHighlighted];
    [heartButton setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateNormal];
    [temp addSubview:heartButton];
    
    
    UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(12.0, 312, 32.0, 32.0)];
    [infoButton setImage:[UIImage imageNamed:@"Info Tap"] forState:UIControlStateHighlighted];
    [infoButton setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
    [temp addSubview:infoButton];
    
    UIButton *pointButton = [[UIButton alloc] initWithFrame:CGRectMake(220.0, 12, 32.0, 32.0)];
    [pointButton setImage:[UIImage imageNamed:@"Point Tap"] forState:UIControlStateHighlighted];
    [pointButton setImage:[UIImage imageNamed:@"Point"] forState:UIControlStateNormal];
    [pointButton addTarget:self action:@selector(pointButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.messButtonView removeFromSuperview];
    self.messButtonView = nil;
    self.messButtonView = [Utils getViewForGreenButtonForText:@"Написать ей" andTapped:NO];
    self.messButtonView.frame = CGRectMake(self.carouselView.currentItemView.frame.size.width/2 - self.messButtonView.frame.size.width/2 , 312, self.messButtonView.frame.size.width, self.messButtonView.frame.size.height);
    [temp addSubview:self.messButtonView];
    UIButton *messButton = [[UIButton alloc] initWithFrame:self.messButtonView.frame];
    [messButton addTarget:self action:@selector(messButtonPressedStart:) forControlEvents: UIControlEventTouchDown];
    [messButton addTarget:self action:@selector(messButtonPressedStop:) forControlEvents:UIControlEventTouchUpInside];
    [temp addSubview:messButton];
    
    [temp addSubview:pointButton];
    return temp;
}
- (UIImageView*) getBackgroundImage {
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 264.0, 356.0)];
    [(UIImageView*) iv setContentMode:UIViewContentModeScaleToFill];
    [(UIImageView*) iv setImage:self.userImage.image];
    return iv;
}
- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return 264.0;
}
#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return 20;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
   if (view == nil)
    {
        //view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 264.0, 356.0)];
        //view.contentMode = UIViewContentModeScaleAspectFit;
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 264.0, 356.0)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 264.0, 356.0)];
        [(UIImageView*) iv setContentMode:UIViewContentModeScaleToFill];
        [(UIImageView*) iv setImage:self.userImage.image];
        [view addSubview:[self getBackgroundImage]];
        
        view.layer.cornerRadius = 3;
        view.layer.masksToBounds = YES;
        view.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    }
    return view;
}
- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
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
- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    //self.bannerView.contentOffset
    self.dragging = YES;
}
- (void) clearViewForIndex:(NSInteger) index andImage:(BOOL) clear  {
    UIView* prevView = [self.carouselView itemViewAtIndex:index];
    NSArray *subviews = [prevView subviews];
    for(UIView* v in subviews) {
        if(!clear) {
        if(![v isKindOfClass:[UIImageView class] ])
            [v removeFromSuperview];
        } else {
            [v removeFromSuperview];
        }
    }
}
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    
    //NSLog(@"%f", self.carouselView.currentItemView.frame.size.width);
    //NSLog(@"%f", self.carouselView.currentItemView.frame.size.height);
    [self clearViewForIndex:self.prevIndex andImage:NO];
    
    //if(self.carouselView.currentItemIndex > self.prevIndex) {
    //    NSLog(@"right to left");
    //} else {
    //    NSLog(@"left to right");
    //}
    if(self.dragging) {
        self.dragging = NO;
        UIView *animV =[self getCardTopSide];
        [UIView transitionWithView:[self navigationController].view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        
                        [self.carouselView.currentItemView addSubview:animV];
                        
                    }
                    completion:^(BOOL finished){
                        
                    }];
    } else {
        [self.carouselView.currentItemView addSubview:[self getCardTopSide]];
        
    }
    self.prevIndex = self.carouselView.currentItemIndex;
}
- (void) messButtonPressedStart:(UIButton *)sender{
    
    [self.messButtonView removeFromSuperview];
    self.messButtonView = nil;
    self.messButtonView = [Utils getViewForGreenButtonForText:@"Написать ей" andTapped:YES];
    self.messButtonView.frame = CGRectMake(self.carouselView.currentItemView.frame.size.width/2 - self.messButtonView.frame.size.width/2 , 312, self.messButtonView.frame.size.width, self.messButtonView.frame.size.height);
    [self.carouselView.currentItemView insertSubview:self.messButtonView belowSubview:sender];

}
- (void) messButtonPressedStop:(UIButton *)sender {
    
    [self.messButtonView removeFromSuperview];
    self.messButtonView = nil;
    self.messButtonView = [Utils getViewForGreenButtonForText:@"Написать ей" andTapped:NO];
    self.messButtonView.frame = CGRectMake(self.carouselView.currentItemView.frame.size.width/2 - self.messButtonView.frame.size.width/2 , 312, self.messButtonView.frame.size.width, self.messButtonView.frame.size.height);
    [self.carouselView.currentItemView insertSubview:self.messButtonView belowSubview:sender];

}
/*
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    
}
 */
- (void) showReceiptViewController:(NSString*) articleName {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end

//
//  HPUserInfoViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "iCarousel.h"
#import "HPGreenButtonVC.h"
#import "HEBubbleView.h"
#import "HEBubbleViewItem.h"
#import "HPChatViewController.h"


@interface HPUserInfoViewController : UIViewController <GreenButtonProtocol, UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource, UIGestureRecognizerDelegate, HEBubbleViewDataSource, HEBubbleViewDelegate, NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) User *user;


@end

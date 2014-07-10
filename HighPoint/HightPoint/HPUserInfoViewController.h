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

@interface HPUserInfoViewController : UIViewController <GreenButtonProtocol, UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource> {
    UISegmentedControl *navSegmentedController;
}

@property (weak, nonatomic) IBOutlet UITableView *infoTableView;
@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@property (strong, nonatomic) User *user;

@end

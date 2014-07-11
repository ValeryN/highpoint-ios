//
//  HPCurrentUserViewController.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"
#import "UserCardOrPointProtocol.h"

@interface HPCurrentUserViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UserCardOrPointProtocol>

- (IBAction)backButtonTap:(id)sender;
- (IBAction)bubbleButtonTap:(id)sender;

@property (weak, nonatomic) IBOutlet iCarousel *carousel;

@end
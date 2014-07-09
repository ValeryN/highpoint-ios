//
//  HPUserProfileViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

#import "HPGreenButtonVC.h"
#import "icarousel.h"

//==============================================================================

@interface HPUserProfileViewController : UIViewController<GreenButtonProtocol, iCarouselDataSource, iCarouselDelegate>

@property (weak, nonatomic) IBOutlet iCarousel* photoScroller;


@end

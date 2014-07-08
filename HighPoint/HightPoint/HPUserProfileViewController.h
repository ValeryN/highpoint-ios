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

//==============================================================================

@interface HPUserProfileViewController : UIViewController<GreenButtonProtocol>

@property (weak, nonatomic) IBOutlet UIScrollView* photoScroller;

- (IBAction)downButtonTap:(id)sender;

@end

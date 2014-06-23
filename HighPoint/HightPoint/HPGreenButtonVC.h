//
//  HPGreenButton.h
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@class HPGreenButtonVC;

@protocol GreenButtonProtocol <NSObject>

- (void) greenButtonPressed: (HPGreenButtonVC*) button;

@end

//==============================================================================

@interface HPGreenButtonVC : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView* centerPart;
@property (nonatomic, weak) NSObject<GreenButtonProtocol>* delegate;

@end

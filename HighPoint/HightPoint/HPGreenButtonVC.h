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

@property (nonatomic, weak) IBOutlet UIImageView* rightPart;
@property (nonatomic, weak) IBOutlet UIImageView* centerPart;
@property (nonatomic, weak) IBOutlet UIImageView* leftPart;

@property (nonatomic, weak) IBOutlet UIImageView* rightPartPressed;
@property (nonatomic, weak) IBOutlet UIImageView* centerPartPressed;
@property (nonatomic, weak) IBOutlet UIImageView* leftPartPressed;

@property (nonatomic, weak) NSObject<GreenButtonProtocol>* delegate;

- (IBAction) touchUpInside:(id)sender;
- (IBAction) touchDown:(id)sender;

@end

//
//  HPGreenButton.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPGreenButtonVC.h"
#import "UIButton+HighPoint.h"

//==============================================================================

@implementation HPGreenButtonVC

//==============================================================================

- (void)viewDidLoad
{
    [self initObjects];
}

//==============================================================================

- (void) initObjects
{
    UIImage *image = [UIImage imageNamed: @"Green-Button-C"];
    UIImage *resizableImage = [image resizableImageWithCapInsets: UIEdgeInsetsMake(0, image.size.width, image.size.height, image.size.width)];
    _centerPart.image = resizableImage;
    
    image = [UIImage imageNamed: @"Green-Button-Tap-C"];
    resizableImage = [image resizableImageWithCapInsets: UIEdgeInsetsMake(0, image.size.width, image.size.height, image.size.width)];
    _centerPartPressed.image = resizableImage;
    
    [_button hp_tuneFontForGreenButton];
}

//==============================================================================


- (IBAction) touchUpInside:(id)sender
{
    [self releaseButton];
}

//==============================================================================

- (IBAction) touchDown:(id)sender
{
    [self highlightButton];
}

//==============================================================================

- (void) highlightButton
{
    _centerPart.hidden = YES;
    _rightPart.hidden = YES;
    _leftPart.hidden = YES;
    
    _centerPartPressed.hidden = NO;
    _rightPartPressed.hidden = NO;
    _leftPartPressed.hidden = NO;
}

//==============================================================================

- (void) releaseButton
{
    _centerPart.hidden = NO;
    _rightPart.hidden = NO;
    _leftPart.hidden = NO;
    
    _centerPartPressed.hidden = YES;
    _rightPartPressed.hidden = YES;
    _leftPartPressed.hidden = YES;
    
    if (_delegate)
        [_delegate greenButtonPressed: self];
}

//==============================================================================

@end
//
//  HPGreenButton.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPGreenButtonVC.h"

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
}

//==============================================================================

@end

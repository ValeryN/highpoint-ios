//
//  HPUserProfileViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserProfileViewController.h"
#import "Utils.h"

//==============================================================================

@implementation HPUserProfileViewController

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed: 30.0/255.0
                                                green: 29.0/255.0
                                                 blue: 48.0/255.0
                                                alpha: 1.0];
}

//==============================================================================

- (IBAction)downButtonTap: (id)sender
{
    if ([self.delegate respondsToSelector: @selector(profileWillBeHidden)])
        [self.delegate profileWillBeHidden];

    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

//==============================================================================

@end

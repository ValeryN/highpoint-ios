//
//  HPMainViewListTableViewCell+HighPoint.m
//  HighPoint
//
//  Created by Michael on 16.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//


#import "HPMainViewListTableViewCell+HighPoint.h"



@implementation HPMainViewListTableViewCell (HighPoint)



- (void) hp_tuneForUserListPressedCell
{
    UIColor* color = [UIColor colorWithRed: 0xe6 / 255.0
                                                green: 0xec / 255.0
                                                 blue: 0xf2 / 255.0
                                                alpha: 0.08];

    self.backgroundColor = color;
}



- (void) hp_tuneForUserListReleasedCell
{
    self.backgroundColor = [UIColor clearColor];
}


@end

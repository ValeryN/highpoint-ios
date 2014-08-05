//
//  HPUserInfoFirstRowTableViewCell.m
//  HighPoint
//
//  Created by Andrey Anisimov on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileFirstRowTableViewCell.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
@implementation HPUserProfileFirstRowTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) configureSlider:(BOOL) hidden {
    //self.oldRangeSlider.translatesAutoresizingMaskIntoConstraints = YES;
    
    if(!hidden) {
        self.oldRangeSlider.backgroundColor = [UIColor clearColor];
        //self.oldRangeSlider.trackBackgroundImage = [UIImage imageNamed: @"Progress Line"];
        self.oldRangeSlider.minimumValue = 18;
        self.oldRangeSlider.maximumValue = 60;
        
        self.oldRangeSlider.lowerValue = [self.user.minentertainment.amount intValue];
        self.oldRangeSlider.upperValue = [self.user.maxentertainment.amount intValue];
        self.oldRangeSlider.tintColor = [UIColor colorWithRed:93.0/255.0 green:186.0/255.0 blue:164.0/255.0 alpha:1.0];
    } else {
        self.oldRangeSlider.hidden = hidden;
    }
}
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender {
    
    NSMutableString *text;
    if([self.user.gender intValue] == 2) {
        text = [NSMutableString stringWithString:@"Привыкла"];
    } else {
        text = [NSMutableString stringWithString:@"Привык"];
    }
    [text appendFormat:@" тратить на развлечения от $%d до $%d за вечер", (int) self.oldRangeSlider.lowerValue,  (int) self.oldRangeSlider.upperValue] ;//[Utils currencyConverter: self.user.minentertainment.currency]
    
    self.cellTextLabel.text = text;

    
}
- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

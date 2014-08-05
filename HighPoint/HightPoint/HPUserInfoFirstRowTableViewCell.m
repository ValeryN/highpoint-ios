//
//  HPUserInfoFirstRowTableViewCell.m
//  HighPoint
//
//  Created by Andrey Anisimov on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoFirstRowTableViewCell.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
@implementation HPUserInfoFirstRowTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
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

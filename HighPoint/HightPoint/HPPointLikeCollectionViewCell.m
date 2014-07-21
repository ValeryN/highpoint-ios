//
//  HPPointLikeCollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPointLikeCollectionViewCell.h"


@implementation HPPointLikeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) configureCell {
    self.avatar = [HPAvatarView createAvatar: [UIImage imageNamed:@"img_sample1.png"]];
    [self.avatarView addSubview: self.avatar];
    [self fixAvatarConstraint];
}


#pragma mark - constrains

- (void) fixAvatarConstraint
{
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.avatarView addConstraint:[NSLayoutConstraint constraintWithItem: self.avatarView
                                                        attribute: NSLayoutAttributeWidth
                                                        relatedBy: NSLayoutRelationEqual
                                                           toItem: nil
                                                        attribute: NSLayoutAttributeNotAnAttribute
                                                       multiplier: 1.0
                                                         constant: self.avatarView.frame.size.width]];
    
    [self.avatarView addConstraint:[NSLayoutConstraint constraintWithItem: self.avatarView
                                                        attribute: NSLayoutAttributeHeight
                                                        relatedBy: NSLayoutRelationEqual
                                                           toItem: nil
                                                        attribute: NSLayoutAttributeNotAnAttribute
                                                       multiplier: 1.0
                                                         constant: self.avatarView.frame.size.height]];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

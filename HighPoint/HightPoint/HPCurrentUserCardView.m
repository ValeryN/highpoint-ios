//
//  HPCurrentUserCardView.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserCardView.h"
#import "User.h"
#import "UIView+HighPoint.h"
#import "UIDevice+HighPoint.h"

#define USERCARD_ROUND_RADIUS 5
#define PHOTO_INDEX_ROUND_RADIUS 5
#define CONSTRAINT_TOP_FOR_NAMELABEL 276
#define CONSTRAINT_WIDTH_FOR_SELF 264
#define CONSTRAINT_WIDE_HEIGHT_FOR_SELF 416
#define CONSTRAINT_HEIGHT_FOR_SELF 340


@implementation HPCurrentUserCardView {
    User *currentUser;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) initObjects
{
    [self.avatarBgImageView hp_roundViewWithRadius: USERCARD_ROUND_RADIUS];
    [self fixUserCardConstraint];
}

- (void) fixUserCardConstraint
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem: self
                                                     attribute: NSLayoutAttributeWidth
                                                     relatedBy: NSLayoutRelationEqual
                                                        toItem: nil
                                                     attribute: NSLayoutAttributeNotAnAttribute
                                                    multiplier: 1.0
                                                      constant: CONSTRAINT_WIDTH_FOR_SELF]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem: self
                                                     attribute: NSLayoutAttributeHeight
                                                     relatedBy: NSLayoutRelationEqual
                                                        toItem: nil
                                                     attribute: NSLayoutAttributeNotAnAttribute
                                                    multiplier: 1.0
                                                      constant: CONSTRAINT_WIDE_HEIGHT_FOR_SELF]];
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.nameLabel))
                consIter.constant = CONSTRAINT_TOP_FOR_NAMELABEL;
            
            if ((consIter.firstAttribute == NSLayoutAttributeHeight) &&
                (consIter.firstItem == self))
                consIter.constant = CONSTRAINT_HEIGHT_FOR_SELF;
        }
    }
}


- (IBAction)pointBtnTap:(id)sender {
    NSLog(@"profile tap");
    if (_delegate == nil)
        return;
    [_delegate switchButtonPressed];
}

@end

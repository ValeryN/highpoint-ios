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
#import "UILabel+HighPoint.h"

#define USERCARD_ROUND_RADIUS 5
#define PHOTO_INDEX_ROUND_RADIUS 5
#define CONSTRAINT_WIDTH_FOR_SELF 264
#define CONSTRAINT_WIDE_HEIGHT_FOR_SELF 416
#define CONSTRAINT_HEIGHT_FOR_SELF 345
#define CONSTRAINT_HEIGHT_FOR_AVATAR 300
#define CONSTRAINT_TOP_FOR_PRIVACYLABEL 195
#define CONSTRAINT_TOP_FOR_PRIVACY_INFOLABEL 215
#define CONSTRAINT_TOP_FOR_NAMELABEL 230
#define CONSTRAINT_TOP_FOR_AGE_AND_CITY 260
#define CONSTRAINT_TOP_FOR_VISIBILITY_BTNS 310



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
    [self.nameLabel hp_tuneForUserCardName];
    [self.ageAndCitylabel hp_tuneForUserCardDetails];
    [self.visibilityLabel hp_tuneForUserVisibilityText];
    [self.visibilityInfoLabel hp_tuneForUserCardDetails];
}

- (void) fixUserCardConstraint
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat heightCarousel = CONSTRAINT_WIDE_HEIGHT_FOR_SELF;
    if (![UIDevice hp_isWideScreen])
        heightCarousel = CONSTRAINT_HEIGHT_FOR_SELF;
    
    
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
                                                      constant: heightCarousel]];
    if (![UIDevice hp_isWideScreen])
    {
        
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem: self.avatarBgImageView
                                                         attribute: NSLayoutAttributeHeight
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: nil
                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                        multiplier: 1.0
                                                          constant: CONSTRAINT_HEIGHT_FOR_AVATAR]];
        
        
        NSArray* cons = self.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.nameLabel))
                consIter.constant = CONSTRAINT_TOP_FOR_NAMELABEL;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.visibilityLabel))
                consIter.constant = CONSTRAINT_TOP_FOR_PRIVACYLABEL;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.ageAndCitylabel))
                consIter.constant = CONSTRAINT_TOP_FOR_AGE_AND_CITY;
            
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.visibilityInfoLabel))
                consIter.constant = CONSTRAINT_TOP_FOR_PRIVACY_INFOLABEL;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.visibleBtn))
                consIter.constant = CONSTRAINT_TOP_FOR_VISIBILITY_BTNS;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.invisibleBtn))
                consIter.constant = CONSTRAINT_TOP_FOR_VISIBILITY_BTNS;
            
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == self.lockBtn))
                consIter.constant = CONSTRAINT_TOP_FOR_VISIBILITY_BTNS;
            
            
            
        }
    }
}


- (IBAction)pointBtnTap:(id)sender {
    if (_delegate == nil)
        return;
    [_delegate switchButtonPressed];
}

@end

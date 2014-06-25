//
//  HPUserCardView.m
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardView.h"
#import "UIView+HighPoint.h"
#import "UILabel+HighPoint.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

#define USERCARD_ROUND_RADIUS 5
#define PHOTO_INDEX_ROUND_RADIUS 5
#define CONSTRAINT_TOP_FOR_NAMELABEL 276

//==============================================================================

@implementation HPUserCardView

//==============================================================================

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self == nil)
        return nil;

    [self initObjects];
    
    return self;
}

//==============================================================================

- (void) initObjects
{
    [_backgroundAvatar hp_roundViewWithRadius: USERCARD_ROUND_RADIUS];
    
    [_photoIndex hp_roundViewWithRadius: PHOTO_INDEX_ROUND_RADIUS];
    [_photoIndex hp_tuneForUserCardPhotoIndex];
    if (![UIDevice hp_isWideScreen])
        _photoIndex.hidden = YES;
    
    [_details hp_tuneForUserCardDetails];
    [_name hp_tuneForUserCardName];
    
    [self fixUserCardConstraint];
}

//==============================================================================

- (void) fixUserCardConstraint
{
    if (![UIDevice hp_isWideScreen])
    {
        NSArray* cons = self.constraints;
        for (NSLayoutConstraint* consIter in cons)
        {
            if ((consIter.firstAttribute == NSLayoutAttributeTop) &&
                (consIter.firstItem == _name))
                consIter.constant = CONSTRAINT_TOP_FOR_NAMELABEL;
        }
    }
}

//==============================================================================

- (IBAction) pointButtonPressed: (id)sender
{
    if (_delegate == nil)
        return;
    
    [_delegate switchButtonPressed];
}

//==============================================================================

@end

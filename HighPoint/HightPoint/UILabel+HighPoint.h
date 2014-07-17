//
//  UILabel+HighPoint.h
//  HighPoint
//
//  Created by Michael on 04.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@interface UILabel (HighPoint)

- (void) hp_tuneForUserListCellName;
- (void) hp_tuneForUserListCellAgeAndCity;
- (void) hp_tuneForUserListCellPointText;
- (void) hp_tuneForUserListCellAnonymous;
- (void) hp_tuneForUserCardName;
- (void) hp_tuneForUserCardDetails;
- (void) hp_tuneForUserCardPhotoIndex;
- (void) hp_tuneForSymbolCounterWhite;
- (void) hp_tuneForSymbolCounterRed;
- (void) hp_tuneForDeletePointInfo;

@end

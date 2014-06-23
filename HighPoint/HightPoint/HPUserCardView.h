//
//  HPUserCardView.h
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@interface HPUserCardView : UIView

@property (nonatomic, weak) IBOutlet UIImageView* backgroundAvatar;
@property (nonatomic, weak) IBOutlet UILabel* photoIndex;
@property (nonatomic, weak) IBOutlet UILabel* details;
@property (nonatomic, weak) IBOutlet UILabel* name;

- (void) initObjects;

@end

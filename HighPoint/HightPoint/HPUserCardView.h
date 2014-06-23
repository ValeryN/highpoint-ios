//
//  HPUserCardView.h
//  HighPoint
//
//  Created by Michael on 18.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

#import "UserCardOrPointProtocol.h"

//==============================================================================

@interface HPUserCardView : UIView

- (IBAction) pointButtonPressed: (id)sender;

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;

@property (nonatomic, weak) IBOutlet UIImageView* backgroundAvatar;
@property (nonatomic, weak) IBOutlet UILabel* photoIndex;
@property (nonatomic, weak) IBOutlet UILabel* details;
@property (nonatomic, weak) IBOutlet UILabel* name;

- (void) initObjects;

@end

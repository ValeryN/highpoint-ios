//
//  HPAvatar.h
//  HighPoint
//
//  Created by Michael on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import <UIKit/UIKit.h>

//==============================================================================

@interface HPAvatarView : UIView

+ (HPAvatarView*) createAvatar :(UIImage *) image;

@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* avatarBorder;

- (void) initObjects : (UIImage *) image;
- (void) makeOnline;
- (void) makeOffline;
- (void) privacyLevel;

@end

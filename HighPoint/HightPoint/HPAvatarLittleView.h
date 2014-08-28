//
//  HPAvatarLittleView.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 22.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPAvatarLittleView : UIView

+ (HPAvatarLittleView*) createAvatar :(UIImage *) image;

@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* avatarBorder;

- (void) initObjects : (UIImage *) image;
- (void) makeOnline;
- (void) makeOffline;

@end

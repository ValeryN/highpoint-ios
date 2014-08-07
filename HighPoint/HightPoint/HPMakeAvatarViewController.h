//
//  HPMakeAvatarViewController.h
//  HighPoint
//
//  Created by Andrey Anisimov on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HFImageEditorViewController.h"

@interface HPMakeAvatarViewController : HFImageEditorViewController
@property (nonatomic, strong) UIImage *cImg;
//@property (nonatomic, strong) IBOutlet UIImageView *sourceImage;
@property(nonatomic, strong) UIView *greenButton;
@property(nonatomic, strong) UIView *tappedGreenButton;
- (void) configureImage;
@end

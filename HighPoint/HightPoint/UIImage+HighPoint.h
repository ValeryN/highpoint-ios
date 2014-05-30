//
//  UIImage+HighPoint.h
//  HighPoint
//
//  Created by Michael on 30.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HighPoint)
- (UIImage*) maskImageWithPattern: (UIImage*) image;
- (UIImage*) applyBlurWithRadius: (CGFloat) blurRadius;
@end

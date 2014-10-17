//
//  UIImage+HighPoint.h
//  HighPoint
//
//  Created by Michael on 30.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//



#import <UIKit/UIKit.h>



@interface UIImage (HighPoint)
- (UIImage*) hp_maskImageWithPattern: (UIImage*) image;
- (UIImage*) hp_applyBlurWithRadius: (CGFloat) blurRadius;

- (UIImage *)addBlendToPhoto;

- (UIImage*) hp_imageWithGaussianBlur: (NSInteger) blurRadius;

- (UIImage *)resizeImageToSize:(CGSize)dstSize;
@end

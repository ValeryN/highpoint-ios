//
//  UIImage+HighPoint.m
//  HighPoint
//
//  Created by Michael on 30.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "UIImage+HighPoint.h"

//==============================================================================

@implementation UIImage (HighPoint)

//==============================================================================

- (UIImage*) maskImageWithPattern: (UIImage*) pattern
{
    CGImageRef sourceImage = self.CGImage;
    CGImageRef imageWithAlpha = sourceImage;

    CGImageRef maskRef = pattern.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
    return [UIImage imageWithCGImage: masked];
}

//==============================================================================

- (UIImage*) applyBlurWithRadius: (CGFloat) blurRadius
{
    CIImage* originalImage = [CIImage imageWithCGImage: self.CGImage];
    CIFilter* filter = [CIFilter filterWithName: @"CIGaussianBlur"
                                  keysAndValues: kCIInputImageKey, originalImage, @"inputRadius", @(blurRadius), nil];
    CIImage* outputImage = filter.outputImage;
    
    outputImage = [outputImage imageByCroppingToRect:(CGRect){
        .origin.x = blurRadius,
        .origin.y = blurRadius,
        .size.width = originalImage.extent.size.width - blurRadius * 2,
        .size.height = originalImage.extent.size.height - blurRadius * 2
    }];
    
    CIContext *context = [CIContext contextWithOptions: nil];
    CGImageRef cropColourImage = [context createCGImage: outputImage
                                               fromRect: [outputImage extent]];
    return [UIImage imageWithCGImage: cropColourImage];
}

//==============================================================================

@end

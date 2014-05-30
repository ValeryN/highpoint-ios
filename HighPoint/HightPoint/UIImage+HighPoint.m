//
//  UIImage+HighPoint.m
//  HighPoint
//
//  Created by Michael on 30.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UIImage+HighPoint.h"

@implementation UIImage (HighPoint)

CGContextRef createContextWithImage(CGImageRef sourceImage)
{
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    return offscreenContext;
}

//==============================================================================

CGImageRef CopyImageAndAddAlphaChannel(CGImageRef sourceImage)
{
    CGImageRef retVal = NULL;
    CGContextRef offscreenContext = createContextWithImage(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (offscreenContext != NULL)
    {
        size_t width = CGImageGetWidth(sourceImage);
        size_t height = CGImageGetHeight(sourceImage);
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return retVal;
}

//==============================================================================

- (UIImage*) maskImageWithPattern: (UIImage*) pattern
{
    CGImageRef sourceImage = self.CGImage;
    CGImageRef imageWithAlpha = sourceImage;
    if ((CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone)
        || (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNoneSkipFirst)
        || (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNoneSkipLast))
    {
        imageWithAlpha = CopyImageAndAddAlphaChannel(sourceImage);
    }
    
    CGImageRef maskRef = pattern.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
    return [UIImage imageWithCGImage:masked];
}

//==============================================================================

- (UIImage*) applyBlurWithRadius: (CGFloat) blurRadius
{
    CIImage *originalImage = [CIImage imageWithCGImage: self.CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur"
                                  keysAndValues: kCIInputImageKey, originalImage, @"inputRadius", @(blurRadius), nil];
    CIImage *outputImage = filter.outputImage;
    
    outputImage = [outputImage imageByCroppingToRect:(CGRect){
        .origin.x = blurRadius,
        .origin.y = blurRadius,
        .size.width = originalImage.extent.size.width - blurRadius*2,
        .size.height = originalImage.extent.size.height - blurRadius*2
    }];
    
//    CGContextRef context = createContextWithImage(sourceImage);
//    CGImageRef cropColourImage = [context createCGImage: outputImage
//                                               fromRect: [outputImage extent]];
    return [UIImage imageWithCIImage: outputImage];
}

//==============================================================================

@end

//
//  UIImage+HighPoint.m
//  HighPoint
//
//  Created by Michael on 30.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "UIImage+HighPoint.h"
#import "UIImage+StackBlur.h"
#import "UIDevice+HighPoint.h"

//==============================================================================

@implementation UIImage (HighPoint)

//==============================================================================

- (UIImage*) hp_maskImageWithPattern: (UIImage*) pattern
{
    if (pattern == nil)
        return nil;

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
    CGImageRelease(mask);
    UIImage *returnImage = [UIImage imageWithCGImage: masked];
    CGImageRelease(masked);
    return returnImage;
}

//==============================================================================

- (UIImage *)hp_applyBlurWithRadius:(CGFloat)blurRadius {
    CIImage *originalImage = [CIImage imageWithCGImage:self.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, originalImage, @"inputRadius", @(blurRadius), nil];
    CIImage *outputImage = filter.outputImage;

    outputImage = [outputImage imageByCroppingToRect:(CGRect) {
            .origin.x = blurRadius,
            .origin.y = blurRadius,
            .size.width = originalImage.extent.size.width - blurRadius * 2,
            .size.height = originalImage.extent.size.height - blurRadius * 2
    }];

    return [UIImage imageWithCIImage:outputImage];
}


- (UIImage*) addBlendToPhoto{
    UIImage *blendImage;
    if([UIDevice hp_isWideScreen]){
        blendImage = [UIImage imageNamed:@"Blend 5X.png"];
    }
    else{
        blendImage = [UIImage imageNamed:@"Blend 4X.png"];
    }


    CGSize newSize = CGSizeMake(self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, .0f);

// Use existing opacity as is
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
// Apply supplied opacity
    [blendImage drawInRect:CGRectMake(0,newSize.height-blendImage.size.height/2,newSize.width,blendImage.size.height/2) blendMode:kCGBlendModeNormal alpha:0.75];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return newImage;
}

//==============================================================================

- (UIImage *)hp_imageWithGaussianBlur:(NSInteger)blurRadius {
    return [self stackBlur:blurRadius];
}

-(UIImage*)resizeImageToSize:(CGSize)dstSize
{
    CGImageRef imgRef = self.CGImage;
    // the below values are regardless of orientation : for UIImages from Camera, width>height (landscape)
    CGSize  srcSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef)); // not equivalent to self.size (which is dependant on the imageOrientation)!

    /* Don't resize if we already meet the required destination size. */
    if (CGSizeEqualToSize(srcSize, dstSize)) {
        return self;
    }

    CGFloat scaleRatio = dstSize.width / srcSize.width;
    UIImageOrientation orient = self.imageOrientation;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch(orient) {

        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;

        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(srcSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;

        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(srcSize.width, srcSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;

        case UIImageOrientationLeftMirrored: //EXIF = 5
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, srcSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;

        case UIImageOrientationLeft: //EXIF = 6
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(0.0, srcSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI_2);
            break;

        case UIImageOrientationRightMirrored: //EXIF = 7
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight: //EXIF = 8
            dstSize = CGSizeMake(dstSize.height, dstSize.width);
            transform = CGAffineTransformMakeTranslation(srcSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];

    }

    /////////////////////////////////////////////////////////////////////////////
    // The actual resize: draw the image on a new context, applying a transform matrix
    UIGraphicsBeginImageContextWithOptions(dstSize, NO, self.scale);

    CGContextRef context = UIGraphicsGetCurrentContext();

    if (!context) {
        return nil;
    }

    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -srcSize.height, 0);
    } else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -srcSize.height);
    }

    CGContextConcatCTM(context, transform);

    // we use srcSize (and not dstSize) as the size to specify is in user space (and we use the CTM to apply a scaleRatio)
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, srcSize.width, srcSize.height), imgRef);
    UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return resizedImage;
}

@end

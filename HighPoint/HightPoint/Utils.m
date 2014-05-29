//
//  Utils.m
//  
//
//  Created by Andrey Anisimov on 23.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "Utils.h"

@implementation Utils
+ (CGFloat)screenPhysicalSize
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height < 500)
            return SCREEN_SIZE_IPHONE_CLASSIC;  // iPhone 4S / 4th Gen iPod Touch or earlier
        else
            return SCREEN_SIZE_IPHONE_TALL;  // iPhone 5
    }
    else
    {
        return SCREEN_SIZE_IPAD_CLASSIC; // iPad
    }
}
+ (NSString*) getStoryBoardName
{
    if([Utils screenPhysicalSize] == SCREEN_SIZE_IPHONE_TALL)
        return @"Storyboard_568";
    else return @"Storyboard_480";
}
+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, size.width, size.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIView*) getViewForGreenButtonForText:(NSString*) text  andTapped:(BOOL) tapped{
    CGFloat width;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        width = [text sizeWithFont:[UIFont fontWithName:@"FuturaPT-Light" size:18.0f ]].width;
    }
    else
    {
        width = ceil([text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Light" size:18.0f]}].width);
    }
    UIImage *imgC;
    UIImage *imgL;
    UIImage *imgR;
    if(tapped) {
        imgC = [UIImage imageNamed:@"Green-Button-Tap-C"];// resizableImageWithCapInsets:UIEdgeInsetsMake(3, 0, 1, 0)];
        imgL= [UIImage imageNamed:@"Green-Button-Tap-L"];
        imgR= [UIImage imageNamed:@"Green-Button-Tap-R"];
    } else {
        imgC = [UIImage imageNamed:@"Green-Button-C"];// resizableImageWithCapInsets:UIEdgeInsetsMake(3, 0, 1, 0)];
        imgL= [UIImage imageNamed:@"Green-Button-L"];
        imgR= [UIImage imageNamed:@"Green-Button-R"];
    }
    
    UIImageView *viewCenter = [[UIImageView alloc] initWithImage:imgC];
    UIImageView *viewLeft = [[UIImageView alloc] initWithImage:imgL];
    viewLeft.frame = CGRectMake(0, 0, viewLeft.frame.size.width/2.0, viewLeft.frame.size.height/2.0);
    UIImageView *viewRight = [[UIImageView alloc] initWithImage:imgR];
    
    viewCenter.frame = CGRectMake(viewLeft.frame.size.width, 0, width ,viewCenter.frame.size.height/2.0);
    
    viewRight.frame = CGRectMake(viewLeft.frame.size.width + viewCenter.frame.size.width, 0, viewRight.frame.size.width/2.0,viewCenter.frame.size.height);
    UIView *notView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewLeft.frame.size.width + viewCenter.frame.size.width + viewRight.frame.size.width, viewCenter.frame.size.height)];
    notView.backgroundColor = [UIColor clearColor];
    [notView addSubview:viewLeft];
    [notView addSubview:viewCenter];
    [notView addSubview:viewRight];
    
    CGFloat shift;
    if(text.length == 1)
        shift = 7;
    else shift = 4;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, width, 20.0)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0 ];
    textLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:196.0/255.0 alpha:1.0];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [notView addSubview:textLabel];
    
    //CGRect fr = notView.frame;
    //fr.origin.x = 30 - notView.frame.size.width;
    //fr.origin.y = -6;
    //notView.frame = fr;
    return notView;

}
+ (UIImage*) maskImage:(UIImage *) image
{
    UIImage *mask_ = [UIImage imageNamed:@"Userpic Mask"];
    CGImageRef maskRef = mask_.CGImage;
    
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];
}
+ (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur withRadius: (CGFloat)blurRadius {
    
    CIImage *originalImage = [CIImage imageWithCGImage: imageToBlur.CGImage];
    CIFilter *filter = [CIFilter filterWithName: @"CIGaussianBlur" keysAndValues: kCIInputImageKey, originalImage, @"inputRadius", @(blurRadius), nil];
    CIImage *outputImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef outImage = [context createCGImage: outputImage fromRect: [outputImage extent]];
    return [UIImage imageWithCGImage: outImage];
}

+ (UIView*) getNotificationViewForText:(NSString*) text {
    
    CGFloat width;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        width = [text sizeWithFont:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ]].width;
    }
    else
    {
        width = ceil([text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0]}].width);
    }
    UIImage *imgC = [[UIImage imageNamed:@"Notice-C"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 0)];
    UIImage *imgL= [UIImage imageNamed:@"Notice-L"];
    UIImage *imgR= [UIImage imageNamed:@"Notice-R"];
    
    UIImageView *viewCenter = [[UIImageView alloc] initWithImage:imgC];
    UIImageView *viewLeft = [[UIImageView alloc] initWithImage:imgL];
    viewLeft.frame = CGRectMake(0, 0, viewLeft.frame.size.width/2.0, viewLeft.frame.size.height/2.0);
    UIImageView *viewRight = [[UIImageView alloc] initWithImage:imgR];
    if(width >=15)
        viewCenter.frame = CGRectMake(viewLeft.frame.size.width, 0, width - 15.0 ,viewCenter.frame.size.height/2.0);
    else viewCenter.frame = CGRectMake(viewLeft.frame.size.width, 0.0, 0.0 ,viewCenter.frame.size.height/2.0);
    viewRight.frame = CGRectMake(viewLeft.frame.size.width + viewCenter.frame.size.width, 0, viewRight.frame.size.width/2.0,viewCenter.frame.size.height);
    UIView *notView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewLeft.frame.size.width + viewCenter.frame.size.width + viewRight.frame.size.width, viewCenter.frame.size.height)];
    notView.backgroundColor = [UIColor clearColor];
    [notView addSubview:viewLeft];
    [notView addSubview:viewCenter];
    [notView addSubview:viewRight];
    
    CGFloat shift;
    if(text.length == 1)
        shift = 7;
    else shift = 4;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(shift, 3.5, width, 16.0)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [notView addSubview:textLabel];
    
    CGRect fr = notView.frame;
    fr.origin.x = 30 - notView.frame.size.width;
    fr.origin.y = -6;
    notView.frame = fr;
    return notView;
    
}
+ (void) configureNavigationBar:(UINavigationController*) controller {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [controller.navigationBar setBarTintColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
    } else {
        [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
        [controller.navigationBar setTintColor:[UIColor colorWithRed:34.0/255.0 green:45.0/255.0 blue:77.0/255.0 alpha:0.9]];
    }
}
+ (UIImage *)captureView:(UIView *)view withArea:(CGRect)screenRect {
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end

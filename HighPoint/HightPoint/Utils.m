//
//  Utils.m
//  
//
//  Created by Andrey Anisimov on 23.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "Utils.h"
#import "DataStorage.h"
#import "UserFilter.h"
#import "Gender.h"
#import "UserFilter.h"

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
//+ (NSString*) getStoryBoardName
//{
//    if([Utils screenPhysicalSize] == SCREEN_SIZE_IPHONE_TALL)
//        return @"Storyboard_568";
//    else return @"Storyboard_480";
//}
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
        width = [text sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18.0] }].width;
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
    viewLeft.frame = CGRectMake(0, 0, viewLeft.frame.size.width, viewLeft.frame.size.height);
    UIImageView *viewRight = [[UIImageView alloc] initWithImage:imgR];
    
    viewCenter.frame = CGRectMake(viewLeft.frame.size.width, 0, width ,viewCenter.frame.size.height);
    
    viewRight.frame = CGRectMake(viewLeft.frame.size.width + viewCenter.frame.size.width, 0, viewRight.frame.size.width,viewCenter.frame.size.height);
    UIView *notView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewLeft.frame.size.width + viewCenter.frame.size.width + viewRight.frame.size.width, viewCenter.frame.size.height)];
    notView.backgroundColor = [UIColor clearColor];
    [notView addSubview:viewLeft];
    [notView addSubview:viewCenter];
    [notView addSubview:viewRight];
    

    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, width, 20.0)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0 ];
    textLabel.textColor = [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:196.0/255.0 alpha:1.0];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [notView addSubview:textLabel];
    
    return notView;

}


+ (UIView*) getNotificationViewForText:(NSString*) text {
    
    CGFloat width;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        width = [text sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ]}].width;
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
+ (UIView*) getFhotoCountViewForText:(NSString*) text {
    CGFloat width;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0)
    {
        width = [text sizeWithAttributes: @{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ]}].width;
    }
    else
    {
        width = ceil([text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0]}].width);
    }
    UIImage *imgC = [[UIImage imageNamed:@"Photos_C"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 1, 0)];
    UIImage *imgL= [UIImage imageNamed:@"Photos_Camera_L"];
    UIImage *imgR= [UIImage imageNamed:@"Photos_R"];
    
    UIImageView *viewCenter = [[UIImageView alloc] initWithImage:imgC];
    UIImageView *viewLeft = [[UIImageView alloc] initWithImage:imgL];
    viewLeft.frame = CGRectMake(0, 0, viewLeft.frame.size.width, viewLeft.frame.size.height);
    UIImageView *viewRight = [[UIImageView alloc] initWithImage:imgR];
    
    viewCenter.frame = CGRectMake(viewLeft.frame.size.width, 0, width  ,viewCenter.frame.size.height);
    
    viewRight.frame = CGRectMake(viewLeft.frame.size.width + viewCenter.frame.size.width, 0, viewRight.frame.size.width,viewCenter.frame.size.height);
    UIView *notView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewLeft.frame.size.width + viewCenter.frame.size.width + viewRight.frame.size.width, viewCenter.frame.size.height)];
    notView.backgroundColor = [UIColor clearColor];
    [notView addSubview:viewLeft];
    [notView addSubview:viewCenter];
    [notView addSubview:viewRight];
    
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 3.5, width, 16.0)];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [notView addSubview:textLabel];
    
    //CGRect fr = notView.frame;
    //fr.origin.x = 30 - notView.frame.size.width;
    //fr.origin.y = -6;
    //notView.frame = fr;
    return notView;
}
+ (NSString*) currencyConverter:(NSString*) currency {
    if([currency isEqualToString:@"usd"]) {
        return @"долларов";
    } else return @"";
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

+ (NSString *) getUserFilterPredicateString {
    UserFilter *userFilter = [[DataStorage sharedDataStorage] getUserFilter];
    NSString *filterString = @"";
    if (userFilter.minAge) {
        filterString = [filterString stringByAppendingString: [NSString stringWithFormat:@" AND age >= %@", userFilter.minAge]];
    }
    if (userFilter.maxAge) {
        filterString = [filterString stringByAppendingString:[NSString stringWithFormat:@" AND age <= %@", userFilter.maxAge]];
    }
    if (userFilter.city.cityId) {
        filterString = [filterString stringByAppendingString:[NSString stringWithFormat:@" AND cityId == %@", userFilter.city.cityId]];
    }
    if (userFilter.gender) {
        if ([userFilter.gender allObjects].count == 1) {
            Gender *gender = [[userFilter.gender allObjects] objectAtIndex:0];
            filterString = [filterString stringByAppendingString:[NSString stringWithFormat:@" AND gender == %@", gender.genderType]];
        }
    }
    return filterString;
}

+ (NSDictionary *) getFilterParamsForRequest {
    UserFilter *filter = [[DataStorage sharedDataStorage] getUserFilter];
    NSString *cityIds = filter.city.cityId? [filter.city.cityId stringValue]: @"";
    NSString *genders;
    if ([filter.gender allObjects].count > 0) {
        for (int i = 0; i < [filter.gender allObjects].count; i ++) {
            Gender * gender = [[filter.gender allObjects] objectAtIndex:i];
            [genders stringByAppendingString:[gender.genderType stringValue]];
        }
    } else {
        genders = @"";
    }
    NSString *maxAge = filter.maxAge ? [filter.maxAge stringValue] : @"";
    NSString *minAge = filter.minAge ? [filter.minAge stringValue] : @"";
    NSDictionary * result = [[NSDictionary alloc] initWithObjectsAndKeys: cityIds, @"cityIds", maxAge ,@"maxAge", minAge, @"minAge", genders, @"genders", nil];
    NSLog(@"filter params = %@", result);
    return result;
}

+ (NSDictionary*) getParameterForPointsRequest:(NSInteger) lastPoint {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:lastPoint], @"afterPointId", @"1", @"includeUsers", nil];
}
+ (NSDictionary*) getParameterForUsersRequest:(NSInteger) lastUser {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:lastUser], @"afterUserId", @"1", @"includePoints", nil];
}

+ (NSString *) getTitleStringForUserFilter {
    UserFilter *filter = [[DataStorage sharedDataStorage] getUserFilter];
    NSLog(@"print filter = %@ %@ %@ %@", filter.minAge, filter.maxAge, filter.gender, filter.city);
    //gender
    NSString *genders = @"";
    NSArray *gendersArr = [filter.gender allObjects];
    if (gendersArr.count == 2 || gendersArr.count == 0) {
        genders = @"Все люди";
    } else {
        if ([((Gender *)[gendersArr objectAtIndex:0]).genderType isEqualToNumber:@1]) {
            genders = @"Мужчины";
        } else {
            genders = @"Девушки";
        }
    }
    
    NSString *age = @"";
    if (filter.minAge && filter.maxAge) {
        if ([filter.minAge integerValue] != [filter.maxAge integerValue]) {
            if (([filter.minAge integerValue]  == 18)&& [filter.maxAge integerValue] == 60 ) {
                age = @"";
            } else {
                age = [NSString stringWithFormat:@"%@-%@", filter.minAge, filter.maxAge];
            }
        } else {
            age = [NSString stringWithFormat:@"%@", filter.minAge];
        }
    } else {
        if (filter.minAge) {
            age = [NSString stringWithFormat:@"%@", filter.minAge];
        } else if (filter.maxAge) {
            age = [NSString stringWithFormat:@"%@", filter.maxAge];
        } else {
            age = @"";
        }
    }
    NSString *town = filter.city ? filter.city.cityName :@"";
    NSString *sep = ((age.length > 0) && town.length > 0)? @", " : @"";
    if ((age.length == 0) && !filter.city) {
        town = @"из всех городов";
    }
    
    
    NSString *sep0 = ((age.length == 0) &&(!filter.city)) ? @" " : @", ";
    
    return [NSString stringWithFormat:@"%@%@%@%@%@", genders, sep0, age, sep, town];
}
+ (NSString*) deleteLastChar:(NSMutableString*) str {
    if(str.length > 0) {
        NSRange rng;
        rng.length = 1;
        rng.location = str.length - 1;
        [str deleteCharactersInRange:rng];
        return [NSString stringWithString:str];
    }
    return @"";
}
@end

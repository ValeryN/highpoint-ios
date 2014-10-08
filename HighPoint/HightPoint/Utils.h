//
//  Utils.h
//  SearchScan
//
//  Created by Andrey Anisimov on 23.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "UIImage-Extensions.h"
#define SCREEN_SIZE_IPHONE_CLASSIC 3.5
#define SCREEN_SIZE_IPHONE_TALL 4.0
#define SCREEN_SIZE_IPAD_CLASSIC 9.7
@interface Utils : NSObject
@property (nonatomic, strong) UIViewController *controller;

//+ (NSString*) getStoryBoardName;

+ (CGFloat)screenPhysicalSize;
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIView*) getNotificationViewForText:(NSString*) text;
+ (UIView*) getViewForGreenButtonForText:(NSString*) text andTapped:(BOOL) tapped;
+ (void) configureNavigationBar:(UINavigationController*) controller;
+ (UIImage *)captureView:(UIView *)view withArea:(CGRect)screenRect;
+ (NSDictionary *) getFilterParamsForRequest;
+ (NSDictionary*) getParameterForPointsRequest:(NSInteger) lastPoint;
+ (NSDictionary*) getParameterForUsersRequest:(NSInteger) lastUser;
+ (NSString *) getTitleStringForUserFilter;
+ (UIView*) getFhotoCountViewForText:(NSString*) text;
+ (NSString*) currencyConverter:(NSString*) currency;
+ (NSString*) deleteLastChar:(NSString*) str;
@end

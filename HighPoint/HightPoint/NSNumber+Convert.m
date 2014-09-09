//
//  NSNumber+Convert.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "NSNumber+Convert.h"

@implementation NSNumber (Convert)

- (NSNumber *) convertToNSNumber{
    return self;
}

- (NSString *) convertToNSString {
    return [self stringValue];
}

@end

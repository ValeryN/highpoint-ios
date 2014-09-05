//
//  NSString+Convert.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "NSString+Convert.h"

@implementation NSString (Convert)

- (NSNumber *) convertToNSNumber {
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [f numberFromString:self];
}

- (NSString *) convertToNSString {
    return self;
}

@end

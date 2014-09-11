//
// Created by Eugene on 11.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "NSDate+HighPoint.h"


@implementation NSDate (HighPoint)
- (NSString*) isoStringOnlyDatFormat{
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    return [dateFormatter stringFromDate: self];
}
@end
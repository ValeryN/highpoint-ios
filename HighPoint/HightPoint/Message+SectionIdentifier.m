//
// Created by Eugen Antropov on 08/09/14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "Message+SectionIdentifier.h"


@implementation Message (SectionIdentifier)

- (NSString*) createdAtDaySection{
    [self willAccessValueForKey:@"createdAtDaySection"];
    NSString *tmp = [self primitiveValueForKey: @"createdAtDaySection"];
    [self didAccessValueForKey:@"createdAtDaySection"];

    if (!tmp)
    {
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        tmp = [dateFormatter stringFromDate: self.createdAt];
        [self setPrimitiveValue: tmp forKey: @"createdAtDaySection"];
    }
    return tmp;
}

- (void) setCreatedAt: (NSDate*) createdAt
{
    [self willChangeValueForKey: @"createdAt"];
    [self setPrimitiveValue: createdAt forKey: @"createdAt"];
    [self didChangeValueForKey: @"createdAt"];
    [self setValue: nil forKey: @"createdAtDaySection"];
}

@end
//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPRequest.h"

@interface HPRequest (GeoLocations)
+ (RACSignal *)findCitiesWithSearchString:(NSString *)string;
@end
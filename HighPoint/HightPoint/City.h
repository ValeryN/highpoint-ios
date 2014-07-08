//
//  City.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 08.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserFilter;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityEnName;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) id cityNameForms;
@property (nonatomic, retain) NSNumber * cityRegionId;
@property (nonatomic, retain) UserFilter *userfilter;

@end

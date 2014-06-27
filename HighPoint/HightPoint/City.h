//
//  City.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface City : NSManagedObject

@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * cityEnName;
@property (nonatomic, retain) NSString * cityNameForms;
@property (nonatomic, retain) NSNumber * cityRegionId;

@end

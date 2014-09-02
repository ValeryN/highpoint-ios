//
//  City.h
//  HighPoint
//
//  Created by Andrey Anisimov on 02.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, User, UserFilter;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityEnName;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) id cityNameForms;
@property (nonatomic, retain) NSNumber * cityRegionId;
@property (nonatomic, retain) NSNumber * isPopular;
@property (nonatomic, retain) NSSet *user;
@property (nonatomic, retain) UserFilter *userfilter;
@property (nonatomic, retain) NSSet *place;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addUserObject:(User *)value;
- (void)removeUserObject:(User *)value;
- (void)addUser:(NSSet *)values;
- (void)removeUser:(NSSet *)values;

- (void)addPlaceObject:(Place *)value;
- (void)removePlaceObject:(Place *)value;
- (void)addPlace:(NSSet *)values;
- (void)removePlace:(NSSet *)values;

@end

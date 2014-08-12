//
//  City.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 12.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, UserFilter;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityEnName;
@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) id cityNameForms;
@property (nonatomic, retain) NSNumber * cityRegionId;
@property (nonatomic, retain) NSNumber * isPopular;
@property (nonatomic, retain) NSSet *user;
@property (nonatomic, retain) UserFilter *userfilter;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addUserObject:(User *)value;
- (void)removeUserObject:(User *)value;
- (void)addUser:(NSSet *)values;
- (void)removeUser:(NSSet *)values;

@end

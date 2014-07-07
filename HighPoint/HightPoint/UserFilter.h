//
//  UserFilter.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 07.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Gender, User;

@interface UserFilter : NSManagedObject

@property (nonatomic, retain) NSNumber * maxAge;
@property (nonatomic, retain) NSNumber * minAge;
@property (nonatomic, retain) NSNumber * viewType;
@property (nonatomic, retain) NSSet *gender;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSSet *city;
@end

@interface UserFilter (CoreDataGeneratedAccessors)

- (void)addGenderObject:(Gender *)value;
- (void)removeGenderObject:(Gender *)value;
- (void)addGender:(NSSet *)values;
- (void)removeGender:(NSSet *)values;

- (void)addCityObject:(City *)value;
- (void)removeCityObject:(City *)value;
- (void)addCity:(NSSet *)values;
- (void)removeCity:(NSSet *)values;

@end

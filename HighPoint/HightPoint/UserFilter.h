//
//  UserFilter.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 12.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Gender, User;

@interface UserFilter : NSManagedObject

@property (nonatomic, retain) NSNumber * maxAge;
@property (nonatomic, retain) NSNumber * minAge;
@property (nonatomic, retain) NSNumber * viewType;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *gender;
@property (nonatomic, retain) User *user;
@end

@interface UserFilter (CoreDataGeneratedAccessors)

- (void)addGenderObject:(Gender *)value;
- (void)removeGenderObject:(Gender *)value;
- (void)addGender:(NSSet *)values;
- (void)removeGender:(NSSet *)values;

@end

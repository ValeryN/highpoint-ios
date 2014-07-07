//
//  User.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 04.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Avatar, Career, Education, MaxEntertainmentPrice, MinEntertainmentPrice, UserFilter, UserPoint;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * cityId;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSString * dateOfBirth;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * favoriteCityIds;
@property (nonatomic, retain) NSString * favoritePlaceIds;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSNumber * isCurrentUser;
@property (nonatomic, retain) NSString * languageIds;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameForms;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * visibility;
@property (nonatomic, retain) Avatar *avatar;
@property (nonatomic, retain) NSSet *career;
@property (nonatomic, retain) NSSet *education;
@property (nonatomic, retain) MaxEntertainmentPrice *maxentertainment;
@property (nonatomic, retain) MinEntertainmentPrice *minentertainment;
@property (nonatomic, retain) UserFilter *userfilter;
@property (nonatomic, retain) UserPoint *point;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addCareerObject:(Career *)value;
- (void)removeCareerObject:(Career *)value;
- (void)addCareer:(NSSet *)values;
- (void)removeCareer:(NSSet *)values;

- (void)addEducationObject:(Education *)value;
- (void)removeEducationObject:(Education *)value;
- (void)addEducation:(NSSet *)values;
- (void)removeEducation:(NSSet *)values;

@end

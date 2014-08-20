//
//  Education.h
//  HighPoint
//
//  Created by Andrey Anisimov on 20.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class School, Speciality, User;

@interface Education : NSManagedObject

@property (nonatomic, retain) NSNumber * fromYear;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * specialityId;
@property (nonatomic, retain) NSNumber * toYear;
@property (nonatomic, retain) School *school;
@property (nonatomic, retain) Speciality *speciality;
@property (nonatomic, retain) User *user;

@end

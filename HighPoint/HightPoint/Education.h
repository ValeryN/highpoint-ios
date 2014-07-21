//
//  Education.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 18.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Education : NSManagedObject

@property (nonatomic, retain) NSNumber * fromYear;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSNumber * schoolId;
@property (nonatomic, retain) NSNumber * specialityId;
@property (nonatomic, retain) NSNumber * toYear;
@property (nonatomic, retain) NSManagedObject *school;
@property (nonatomic, retain) NSManagedObject *speciality;
@property (nonatomic, retain) User *user;

@end

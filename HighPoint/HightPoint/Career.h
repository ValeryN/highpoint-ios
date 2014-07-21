//
//  Career.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 18.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CareerPost, Company, User;

@interface Career : NSManagedObject

@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSNumber * fromYear;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSNumber * toYear;
@property (nonatomic, retain) CareerPost *careerpost;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) User *user;

@end

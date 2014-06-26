//
//  Career.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Career : NSManagedObject

@property (nonatomic, retain) NSNumber * companyId;
@property (nonatomic, retain) NSNumber * fromYear;
@property (nonatomic, retain) NSNumber * id_;
@property (nonatomic, retain) NSNumber * postId;
@property (nonatomic, retain) NSNumber * toYear;
@property (nonatomic, retain) User *user;

@end

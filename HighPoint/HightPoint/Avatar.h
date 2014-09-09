//
//  Avatar.h
//  HighPoint
//
//  Created by Andrey Anisimov on 09.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Avatar : NSManagedObject

@property (nonatomic, retain) NSNumber * cropLeft;
@property (nonatomic, retain) NSNumber * cropTop;
@property (nonatomic, retain) NSNumber * cropWidth;
@property (nonatomic, retain) NSNumber * cropHeight;
@property (nonatomic, retain) NSString * encodedImgSrc;
@property (nonatomic, retain) NSNumber * encodedImgWidth;
@property (nonatomic, retain) NSNumber * encodedImgHeight;
@property (nonatomic, retain) NSNumber * originalImgHeight;
@property (nonatomic, retain) NSNumber * originalImgWidth;
@property (nonatomic, retain) NSString * originalImgSrc;
@property (nonatomic, retain) User *user;

@end

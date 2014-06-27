//
//  Avatar.h
//  HighPoint
//
//  Created by Andrey Anisimov on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Avatar : NSManagedObject

@property (nonatomic, retain) NSString * highCrop;
@property (nonatomic, retain) NSNumber * highImageHeight;
@property (nonatomic, retain) NSString * highImageSrc;
@property (nonatomic, retain) NSNumber * highImageWidth;
@property (nonatomic, retain) NSNumber * originalImageHeight;
@property (nonatomic, retain) NSString * originalImageSrc;
@property (nonatomic, retain) NSNumber * originalImageWidth;
@property (nonatomic, retain) NSString * squareCrop;
@property (nonatomic, retain) NSNumber * squareImageHeight;
@property (nonatomic, retain) NSString * squareImageSrc;
@property (nonatomic, retain) NSNumber * squareImageWidth;
@property (nonatomic, retain) User *user;

@end

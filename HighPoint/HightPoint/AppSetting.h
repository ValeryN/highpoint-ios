//
//  AppSetting.h
//  HighPoint
//
//  Created by Andrey Anisimov on 10.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppSetting : NSManagedObject

@property (nonatomic, retain) NSNumber * avatarMaxFileSize;
@property (nonatomic, retain) NSNumber * avatarMinImageHeight;
@property (nonatomic, retain) NSNumber * avatarMinImageWidth;
@property (nonatomic, retain) NSNumber * pointMaxPeriod;
@property (nonatomic, retain) NSNumber * pointMinPeriod;
@property (nonatomic, retain) NSString * webSoketUrl;
@property (nonatomic, retain) NSNumber * avatarMinCropSizeWidth;
@property (nonatomic, retain) NSNumber * avatarMinCropSizeHeight;
@property (nonatomic, retain) NSNumber * photoMaxFileSize;
@property (nonatomic, retain) NSNumber * photoMinImageHeight;
@property (nonatomic, retain) NSNumber * photoMinImageWidth;

@end

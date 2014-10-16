//
//  HPSettingsDataManager.h
//  HighPoint
//
//  Created by Eugene on 15/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, SettingsNotificationType){
    SettingsNotificationStatus,
    SettingsNotificationBanner
};

@interface HPSettingsDataManager : NSObject

@property (nonatomic) BOOL soundEnabled;
@property (nonatomic) SettingsNotificationType notificationType;
@property (nonatomic) BOOL notificationWriteMessageEnabled;
@property (nonatomic) BOOL notificationLikeYourPointEnabled;
@property (nonatomic) BOOL notificationPointTimeIsUpEnabled;
@property (nonatomic,retain) NSString* applicationCode;

@end

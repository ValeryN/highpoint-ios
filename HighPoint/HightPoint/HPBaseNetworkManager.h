//
//  HPBaseNetworkManager.h
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
@class User;
@interface HPBaseNetworkManager : NSObject <SocketIODelegate>

+ (HPBaseNetworkManager*) sharedNetworkManager;
- (void) startNetworkStatusMonitor;
- (void) setNetworkStatusMonitorCallback;
- (void) initSocketIO:(NSDictionary*) param;
- (void) sendMessage:(NSDictionary*) param;
- (void) makeAutorizationRequest:(NSDictionary*) param;
- (void) makeRegistrationRequest:(NSDictionary*) param;
//- (void) getApplicationSettingsRequest:(NSDictionary*) param;
//- (void) getUserInfoRequest:(NSDictionary*) param;
//- (void) getCurrentUserSettingsRequest:(NSDictionary*) param;
- (void) makeUpdateCurrentUserFilterSettingsRequest:(NSDictionary*) param;
//- (void) getUsersListRequest:(NSDictionary*) param;
//- (void) getPointsListRequest:(NSDictionary*) param;
- (void) makePointLikeRequest:(NSNumber*) pointId;
- (void) makePointUnLikeRequest:(NSNumber*) pointId;
- (void) getApplicationSettingsRequest;
- (void) getCurrentUserRequest;
- (void) addEducationRequest:(NSDictionary*) param;
- (void) addPlaceRequest:(NSDictionary*) param;
- (void) addLanguageRequest:(NSString*) langName;
- (void) addCareerItemRequest:(NSDictionary*) param;
- (void) deleteCareerItemRequest:(NSString*) ids;
- (void) getUsersRequest:(NSInteger) lastUser;
- (void) getPointsRequest:(NSInteger) lastPoint;
//- (User*) getCurrentUser;
- (void) getGeoLocation:(NSDictionary*) param;
- (void) findGeoLocation:(NSDictionary*) param;

- (void) sendUserActivityStart:(NSDictionary*) param;
- (void) sendUserActivityEnd:(NSDictionary*) param;
- (void) sendUserMessagesRead:(NSDictionary*) param;
- (void) sendUserTypingStart:(NSDictionary*) param;
- (void) sendUserTypingFinish:(NSDictionary*) param;
- (void) sendUserNotificationRead:(NSDictionary*) param;
- (void) sendUserAllNotificationRead:(NSDictionary*) param;

@end

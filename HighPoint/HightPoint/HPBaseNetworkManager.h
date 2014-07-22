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
- (void) makeUpdateCurrentUserFilterSettingsRequest:(NSDictionary*) param;
- (void) makeReferenceRequest:(NSDictionary*) param;
- (void) makePointLikeRequest:(NSNumber*) pointId;
- (void) makePointUnLikeRequest:(NSNumber*) pointId;
- (void) getApplicationSettingsRequest;
- (void) getCurrentUserRequest;
- (void) addEducationRequest:(NSDictionary*) param;
- (void) deleteEducationItemRequest:(NSString*) ids;
- (void) addPlaceRequest:(NSDictionary*) param;
- (void) deletePlaceItemRequest:(NSString*) ids;
- (void) addLanguageRequest:(NSString*) langName;
- (void) deleteLanguageItemRequest:(NSString*) ids;
- (void) findLanguagesRequest:(NSDictionary*) param;
- (void) findCompaniesRequest:(NSDictionary*) param;
- (void) findPostsRequest:(NSDictionary*) param;
- (void) addCareerItemRequest:(NSDictionary*) param;
- (void) deleteCareerItemRequest:(NSString*) ids;
- (void) getUsersRequest:(NSInteger) lastUser;
- (void) getPointsRequest:(NSInteger) lastPoint;
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

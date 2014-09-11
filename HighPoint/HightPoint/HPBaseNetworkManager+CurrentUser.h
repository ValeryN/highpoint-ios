//
//  HPBaseNetworkManager+CurrentUser.h
//  HighPoint
//
//  Created by Andrey Anisimov on 10.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (CurrentUser)
- (void) getCurrentUserRequest;
- (void) makeUpdateCurrentUserFilterSettingsRequest:(NSDictionary*) param;
- (void) addCareerItemRequest:(NSDictionary*) param;
- (void) deleteCareerItemRequest:(NSString*) ids;
- (void) addLanguageRequest:(NSString*) langName;
- (void) deleteLanguageItemRequest:(NSString*) ids;
- (void) addPlaceRequest:(NSDictionary*) param;
- (void) deletePlaceItemRequest:(NSString*) ids;
- (void) addEducationRequest:(NSDictionary*) param;
- (void) deleteEducationItemRequest:(NSString*) ids;
- (void) setUserAvatarRequest : (UIImage *) image;
- (void) getUserPhotoRequest;
@end

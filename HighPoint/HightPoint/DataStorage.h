//
//  DataStorage.h
//  iQLib
//
//  Created by Andrey Anisimov on 07.07.13.
//  Copyright (c) 2013 Andrey Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppSetting.h"
#import "UserFilter.h"
#import "User.h"
#import "MinEntertainmentPrice.h"
#import "MaxEntertainmentPrice.h"
#import "Gender.h"
#import "Education.h"
#import "Career.h"
#import "Avatar.h"
#import "UserPoint.h"
#import "City.h"
#import "Language.h"
#import "Place.h"

@interface DataStorage : NSObject
@property (nonatomic, strong) NSManagedObjectContext *moc;
+ (DataStorage*) sharedDataStorage;
- (void) createUser:(NSDictionary*) param;
- (void) createPoint:(NSDictionary*) param;
- (void) createUserInfo:(NSDictionary*) param;
- (void) createUserSettings:(NSDictionary*) param;
- (void) createApplicationSettingEntity:(NSDictionary *)param;
- (UserFilter*) createUserFilterEntity:(NSDictionary *)param;
- (void) deleteUserFilter;
- (UserFilter*) getUserFilter;
- (void) setCityToUserFilter :(City *) city;
- (NSFetchedResultsController*) applicationSettingFetchResultsController;
- (void) createUserEntity:(NSDictionary *)param isCurrent:(BOOL) current;
- (NSFetchedResultsController*) allUsersFetchResultsController;
-(NSFetchedResultsController*) allUsersWithPointFetchResultsController;
- (User*) getCurrentUser;
- (void) deleteCurrentUser;
- (Place *) createPlaceEntity:(NSDictionary *)param;
- (void) addLPlaceEntityForUser :(NSDictionary *) param;
- (void) deletePlaceEntityFromUser :(NSArray *) id;
- (Education*) createEducationEntity:(NSDictionary *)param;
- (void) addLEducationEntityForUser :(NSDictionary *) param;
- (Language *) createLanguageEntity:(NSDictionary *)param;
- (void) addLanguageEntityForUser :(NSDictionary *) param;
- (void) deleteLanguageEntityFromUser :(NSArray *) ids;
- (void) addCareerEntityForUser :(NSDictionary *) param;
- (void) deleteCareerEntityFromUser :(NSArray *) ids;
- (UserPoint*) getPointForUserId:(NSNumber*) userId;
- (void) setPointLiked : (NSNumber *) pointId : (BOOL) isLiked;
- (AppSetting*) getAppSettings;
- (City*) createCity:(NSDictionary *)param;
- (City *) createTempCity :(NSDictionary *) param;
- (City *) getCityById : (NSNumber *) cityId;
- (City *) insertCityObjectToContext: (City *) city;
- (void) removeCityObjectById : (City *)city;
- (void) removeCitiesFromUserFilter;
- (void) deleteAllCities;
- (void) saveContext;
@end

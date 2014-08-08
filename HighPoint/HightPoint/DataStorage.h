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
#import "CareerPost.h"
#import "Company.h"
#import "School.h"
#import "Speciality.h"
#import "Contact.h"
#import "LastMessage.h"
#import "Chat.h"
#import "Message.h"

typedef void (^complationBlock) (id object);

@interface DataStorage : NSObject
@property (nonatomic, retain) NSOperationQueue *backgroundOperationQueue;
+ (DataStorage*) sharedDataStorage;
- (void) createUser:(NSDictionary*) param;
- (void)createAndSavePoint:(NSDictionary*) param;
- (void) createUserInfo:(NSDictionary*) param;
- (void) createUserSettings:(NSDictionary*) param;
- (void)createAndSaveApplicationSettingEntity:(NSDictionary *)param;
- (void)createAndSaveUserFilterEntity:(NSDictionary *)param withComplation:(complationBlock) block;
- (void)removeAndSaveUserFilter;
- (UserFilter*) getUserFilter;
- (void)setAndSaveCityToUserFilter:(City *) city;
- (NSFetchedResultsController*) applicationSettingFetchResultsController;
- (void) createAndSaveUserEntity:(NSDictionary *)param isCurrent:(BOOL)current withComplation:(complationBlock) block;
- (NSFetchedResultsController*) allUsersFetchResultsController;
- (NSFetchedResultsController*) allUsersWithPointFetchResultsController;
- (User*) getCurrentUser;
- (User*) getUserForId:(NSNumber*) id_;
- (void)deleteAndSaveCurrentUser;
- (School *) createSchoolEntity:(NSDictionary *)param;
- (School *) createTempSchool :(NSDictionary *) param;
- (Speciality *) createSpecialityEntity:(NSDictionary *)param;
- (Speciality *) createTempSpeciality :(NSDictionary *) param;
- (Place *) createPlaceEntity:(NSDictionary *)param;
- (void)addAndSavePlaceEntityForUser:(NSDictionary *) param;
- (void)deleteAndSavePlaceEntityFromUser:(NSArray *) id;
- (Place *) createTempPlace :(NSDictionary *) param;
- (Education*) createEducationEntity:(NSDictionary *)param;
- (void)deleteAndSaveEducationEntityFromUser:(NSArray *) ids;
- (void)addAndSaveEducationEntityForUser:(NSDictionary *) param;
- (Language *) createLanguageEntity:(NSDictionary *)param;
- (void)addAndSaveLanguageEntityForUser:(NSDictionary *) param;
- (void)deleteAndSaveLanguageEntityFromUser:(NSArray *) ids;
- (Language *) createTempLanguage :(NSDictionary *) param;
- (void)createAndSaveCareerPost:(NSDictionary *)param withComplation:(complationBlock) block;
- (CareerPost *) createTempCareerPost :(NSDictionary *) param;
- (void)addAndSaveCareerEntityForUser:(NSDictionary *) param;
- (void)deleteAndSaveCareerEntityFromUser:(NSArray *) ids;
- (void)createAndSaveCompany:(NSDictionary *)param withComplation:(complationBlock) block;
- (Company *) createTempCompany :(NSDictionary *) param;
- (UserPoint*) getPointForUserId:(NSNumber*) userId;
- (void)setAndSavePointLiked: (NSNumber *) pointId : (BOOL) isLiked;
- (AppSetting*) getAppSettings;
- (void)createAndSaveCity:(NSDictionary *)param withComplation:(complationBlock) block;
- (City *) createTempCity :(NSDictionary *) param;
- (City *) getCityById : (NSNumber *) cityId;
- (void)insertAndSaveCityObjectToContext: (City *) city withComplation:(complationBlock) block;
- (void)setAndSaveCityToUser: (NSNumber *) userId : (City *) city;
- (void) removeCityObjectById : (City *)city;
- (void)removeAndSaveCitiesFromUserFilter;
- (void) deleteAllCities;
- (void)createAndSaveContactEntity: (User *)user : (LastMessage *) lastMessage withComplation:(complationBlock) block;
- (void) deleteAllContacts;
- (NSFetchedResultsController*) getAllContactsFetchResultsController;
- (void)deleteAndSaveContact: (NSNumber *) contactId;
-(NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr;
- (void)createAndSaveLastMessage:(NSDictionary *)param  :(int) keyId withComplation:(complationBlock) block;
- (void)createAndSaveChatEntity: (User *)user : (NSArray *) messages withComplation:(complationBlock) block;
- (void)deleteAndSaveChatByUserId: (NSNumber *) userId;
- (void) saveContext;
@end

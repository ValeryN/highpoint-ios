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
#import "Chat.h"
#import "Message.h"
#import "HPBaseNetworkManager.h"

typedef enum {
    CurrentUserType = 1,
    MainListUserType,
    ContactUserType
} UserType;

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
- (void) createAndSaveUserEntity:(NSDictionary *)param forUserType:(UserType) type  withComplation:(complationBlock) block;
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
- (void) createAndSaveCity:(NSDictionary *)param popular: (BOOL) isPopular  withComplation:(complationBlock) block;
- (NSFetchedResultsController *) getPopularCities;
- (City *) createTempCity :(NSDictionary *) param;
- (City *) getCityById : (NSNumber *) cityId;
- (void)insertAndSaveCityObjectToContext: (City *) city withComplation:(complationBlock) block;
- (void)setAndSaveCityToUser: (NSNumber *) userId : (City *) city;
- (void) removeCityObjectById : (City *)city;
- (void)removeAndSaveCitiesFromUserFilter;
- (void) deleteAllCities;
- (void)createAndSaveContactEntity: (User *)user forMessage: (Message *) lastMessage withComplation:(complationBlock) block;
- (void)deleteAndSaveAllContacts;
- (NSFetchedResultsController*) getAllContactsFetchResultsController;

- (void) deleteContact : (NSNumber *) contactId;
- (NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr;
- (void) linkParameter:(NSDictionary*) param toUser:(User*) user;
- (Message *) createMessage :(NSDictionary *)param forUserId:(NSNumber *)userId andMessageType:(MessageTypes) type;
- (Chat *) createChatEntity: (User *)user : (NSArray *) messages;
- (Chat *) getChatByUserId :(NSNumber *) userId;
- (NSDictionary*) prepareParamFromUser:(User*) user;
- (void) deleteChatByUserId : (NSNumber *) userId;
- (void) saveContext;

- (void)deleteAndSaveContact: (NSNumber *) contactId;
-(NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr;
- (void)createAndSaveMessage:(NSDictionary *)param  forUserId:(NSNumber*) keyId  andMessageType:(MessageTypes) type withComplation:(complationBlock) block;
- (void)createAndSaveChatEntity: (User *)user withMessages: (NSArray *) messages withComplation:(complationBlock) block;
- (void)deleteAndSaveChatByUserId: (NSNumber *) userId;
- (Chat *) getChatByUserId :(NSNumber *) userId;

@end

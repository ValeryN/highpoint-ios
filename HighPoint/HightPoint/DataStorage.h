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

@interface DataStorage : NSObject
@property (nonatomic, strong) NSManagedObjectContext *moc;
+ (DataStorage*) sharedDataStorage;
- (void) createUser:(NSDictionary*) param;
- (void)createAndSavePoint:(NSDictionary*) param;
- (void) createUserInfo:(NSDictionary*) param;
- (void) createUserSettings:(NSDictionary*) param;
- (void)createAndSaveApplicationSettingEntity:(NSDictionary *)param;
- (UserFilter*)createAndSaveUserFilterEntity:(NSDictionary *)param;
- (void)removeAndSaveUserFilter;
- (UserFilter*) getUserFilter;
- (void)setAndSaveCityToUserFilter:(City *) city;
- (NSFetchedResultsController*) applicationSettingFetchResultsController;
- (User *)createAndSaveUserEntity:(NSDictionary *)param isCurrent:(BOOL) current;
- (NSFetchedResultsController*) allUsersFetchResultsController;
- (NSFetchedResultsController*) allUsersWithPointFetchResultsController;
- (User*) getCurrentUser;
- (User*) getUserForId:(NSNumber*) id_;
- (void) deleteCurrentUser;
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
- (CareerPost*)createAndSaveCareerPost:(NSDictionary *)param;
- (CareerPost *) createTempCareerPost :(NSDictionary *) param;
- (void)addAndSaveCareerEntityForUser:(NSDictionary *) param;
- (void)deleteAndSaveCareerEntityFromUser:(NSArray *) ids;
- (Company*)createAndSaveCompany:(NSDictionary *)param;
- (Company *) createTempCompany :(NSDictionary *) param;
- (UserPoint*) getPointForUserId:(NSNumber*) userId;
- (void)setAndSavePointLiked: (NSNumber *) pointId : (BOOL) isLiked;
- (AppSetting*) getAppSettings;
- (City*)createAndSaveCity:(NSDictionary *)param;
- (City *) createTempCity :(NSDictionary *) param;
- (City *) getCityById : (NSNumber *) cityId;
- (City *)insertAndSaveCityObjectToContext: (City *) city;
- (void)setAndSaveCityToUser: (NSNumber *) userId : (City *) city;
- (void) removeCityObjectById : (City *)city;
- (void)removeAndSaveCitiesFromUserFilter;
- (void) deleteAllCities;
- (Contact *)createAndSaveContactEntity: (User *)user : (LastMessage *) lastMessage;
- (void) deleteAllContacts;
- (NSFetchedResultsController*) getAllContactsFetchResultsController;
- (void)deleteAndSaveContact: (NSNumber *) contactId;
-(NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr;
- (LastMessage*)createAndSaveLastMessage:(NSDictionary *)param  :(int) keyId;
- (Chat *)createAndSaveChatEntity: (User *)user : (NSArray *) messages;
- (void)deleteAndSaveChatByUserId: (NSNumber *) userId;
- (void) saveContext;
@end

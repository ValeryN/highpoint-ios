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
- (User *) createUserEntity:(NSDictionary *)param isCurrent:(BOOL) current isItFromContact:(BOOL) contact;
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
- (void) addLPlaceEntityForUser :(NSDictionary *) param;
- (void) deletePlaceEntityFromUser :(NSArray *) id;
- (Place *) createTempPlace :(NSDictionary *) param;
- (Education*) createEducationEntity:(NSDictionary *)param;
- (void) deleteEducationEntityFromUser :(NSArray *) ids;
- (void) addLEducationEntityForUser :(NSDictionary *) param;
- (Language *) createLanguageEntity:(NSDictionary *)param;
- (void) addLanguageEntityForUser :(NSDictionary *) param;
- (void) deleteLanguageEntityFromUser :(NSArray *) ids;
- (Language *) createTempLanguage :(NSDictionary *) param;
- (CareerPost*) createCareerPost :(NSDictionary *)param;
- (CareerPost *) createTempCareerPost :(NSDictionary *) param;
- (void) addCareerEntityForUser :(NSDictionary *) param;
- (void) deleteCareerEntityFromUser :(NSArray *) ids;
- (Company*) createCompany :(NSDictionary *)param;
- (Company *) createTempCompany :(NSDictionary *) param;
- (UserPoint*) getPointForUserId:(NSNumber*) userId;
- (void) setPointLiked : (NSNumber *) pointId : (BOOL) isLiked;
- (AppSetting*) getAppSettings;
- (City*) createCity:(NSDictionary *)param : (BOOL) isPopular;
- (NSFetchedResultsController *) getPopularCities;
- (City *) createTempCity :(NSDictionary *) param;
- (City *) getCityById : (NSNumber *) cityId;
- (City *) insertCityObjectToContext: (City *) city;
- (void) setCityToUser : (NSNumber *) userId : (City *) city;
- (void) removeCityObjectById : (City *)city;
- (void) removeCitiesFromUserFilter;
- (void) deleteAllCities;
- (Contact *) createContactEntity:(User *)user forMessage:(Message *) lastMessage;
- (void) deleteAllContacts;
- (NSFetchedResultsController*) getAllContactsFetchResultsController;
- (void) deleteContact : (NSNumber *) contactId;
-(NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr;

- (Message *) createMessage :(NSDictionary *)param forUserId:(NSNumber *)userId andMessageType:(MessageTypes) type;
- (Chat *) createChatEntity: (User *)user : (NSArray *) messages;
- (void) deleteChatByUserId : (NSNumber *) userId;
- (void) saveContext;
@end

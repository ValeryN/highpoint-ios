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
    ContactUserType,
    PointLikeUserType
} UserType;

typedef void (^complationBlock) (id object);

@interface DataStorage : NSObject
//@property (nonatomic, retain) NSOperationQueue *backgroundOperationQueue;

+ (DataStorage*) sharedDataStorage;


- (NSFetchedResultsController *)allUsersAndContactFetchResultsController;
- (void) updateUserFilterEntity : (NSDictionary *) param;
- (void) setAndSaveCityToUserFilter:(City *) globalCity;
- (void) updateCityAtUserFilter:(City *)city;
- (UserFilter *) getUserFilter;
- (void) addAndSaveEducationEntityForUser:(NSDictionary *)param;
- (void) deleteAndSaveEducationEntityFromUser:(NSArray *)ids;
- (void) addAndSaveLanguageEntityForUser:(NSDictionary *)param;
- (void) deleteAndSaveLanguageEntityFromUser:(NSArray *)ids;
- (void) createTempLanguage:(NSDictionary *)param withComplation:(complationBlock)block;
- (void) createTempSchool:(NSDictionary *)param withComplation:(complationBlock)block;
- (void) createTempSpeciality:(NSDictionary *)param withComplation:(complationBlock)block;
- (void) createTempPlace:(NSDictionary *)param withComplation:(complationBlock)block;
- (void) createTempCareerPost:(NSDictionary *)param withComplation:(complationBlock)block;
- (void) createTempCompany:(NSDictionary *)param withComplation:(complationBlock)block;
- (void) createAndSaveUserEntity:(NSMutableArray*) params forUserType:(UserType)type withComplation:(complationBlock)block;
- (User*) getUserForId:(NSNumber*) id_;
- (void) createAndSavePoint:(NSArray*) array withComplation:(complationBlock)block;
- (void) linkParameter:(NSDictionary *)param toUser:(User *)user withComplation:(complationBlock)block;
- (void) deleteAndSaveAllUsersWithBlock:(complationBlock)block;
- (void) createAndSaveCity:(NSDictionary *) param popular: (BOOL) isPopular  withComplation:(complationBlock) block;
- (Message *)createMessage:(NSDictionary *)param forUserId:(NSNumber *)userId andMessageType:(MessageTypes)type forContext:(NSManagedObjectContext*) context;
- (Chat *)getChatByUserId:(NSNumber *)userId forContext:(NSManagedObjectContext*) context;
- (NSInteger)allUnreadMessagesCount:(User *)user;
- (void)createAndSavePhotoEntity:(NSDictionary *)param withComplation:(complationBlock)block;
- (void)createAndSaveIntPhotoEntity:(NSDictionary *)param withComplation:(complationBlock)block;
- (NSArray*) getUsersForCityId:(NSNumber*) cityId;
- (void)deleteAndSaveChatByUserId: (NSNumber *) userId;
- (User *) getSelectedUserById:(NSNumber*) id_;
- (void)createAndSaveChatEntity: (User *)user withMessages: (NSArray *) messages withComplation:(complationBlock) block;
- (void)deleteAndSaveAllMessages;
- (void)createAndSaveMessage:(NSDictionary *)param  forUserId:(NSNumber*) keyId  andMessageType:(MessageTypes) type withComplation:(complationBlock) block;
- (void)deleteAndSaveContact: (NSNumber *) contactId;
- (NSDictionary*) prepareParamFromUser:(User*) user;
- (void)deletePhotosWithComplation:(complationBlock)block;
- (void) deletePhotoById:(NSNumber*) id_ withComplation:(complationBlock)block;


- (void)setAndSaveUser:(User *)globalUser toLikePoint:(UserPoint *)globalPoint withComplationBlock:(complationBlock)block;
- (NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr;
- (void)createAndSaveApplicationSettingEntity:(NSDictionary *)param;
- (NSFetchedResultsController*) applicationSettingFetchResultsController;
- (NSFetchedResultsController*) allUsersFetchResultsController;
- (NSFetchedResultsController*) allUsersWithPointFetchResultsController;
- (NSFetchedResultsController *)allUsersPointLikesResultsController;
- (User*) getCurrentUser;
- (void)deleteAndSaveCurrentUser;
- (NSArray *) getPhotoForUserId:(NSNumber *) userId;

- (void)addAndSavePlaceEntity:(NSDictionary *)param forUser:(User*) user;
- (void)deleteAndSavePlaceEntityFromUserWithIds:(NSArray *) id;


- (void)deleteAndSavePlaceEntityForCurrentUserWithCity:(City *)globalCity;
- (void)setAndSaveCurrentUserMaxEntertainmentPrice:(NSNumber *)number;
- (void)setAndSaveCurrentUserMinEntertainmentPrice:(NSNumber *)number;


- (void)addAndSaveCareerEntityForUser:(NSDictionary *) param;
- (void)deleteAndSaveCareerEntityFromUser:(NSArray *) ids;

- (void)deleteAndSaveUserPointForUser:(User *)globalUser;
- (void)updateAndSaveVisibility:(UserVisibilityType)visibilityType forUser:(User *)globalUser;
- (UserPoint*) getPointForUserId:(NSNumber*) userId;
- (void)setAndSavePointLiked: (NSNumber *) pointId isLiked: (BOOL) isLiked withComplationBlock:(complationBlock)block;
- (AppSetting*) getAppSettings;
- (NSFetchedResultsController *) getPopularCities;
- (City *) getCityById : (NSNumber *) cityId;
- (void)setAndSaveCityToUser: (NSNumber *) userId forCity: (City *) city;
- (void) removeCityObjectById : (City *)city;
- (void) deleteAllCities;
- (void)createAndSaveContactEntity: (User *)user forMessage: (Message *) lastMessage withComplation:(complationBlock) block;
- (void)deleteAndSaveAllContacts;
- (NSFetchedResultsController*) getAllContactsFetchResultsController;
- (void) deleteAndSaveEntity:(NSManagedObject*) globalObject;
- (void) setAndSaveMessageStatus:(MessageStatus) status forMessage:(Message *) globalMessage;
- (void)createAndSaveMessageArray:(NSArray *)param andMessageType:(MessageTypes)type withComplation:(complationBlock)block;
- (Message*) getMessageForId:(NSNumber*) messId;



@end

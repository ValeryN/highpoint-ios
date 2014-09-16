//
//  DataStorage.m
//  HightPoint
//
//  Created by Andrey Anisimov on 07.07.13.
//  Copyright (c) 2013 Andrey Anisimov. All rights reserved.
//

#import "DataStorage.h"
#import "HPAppDelegate.h"
#import "Utils.h"
#import "NotificationsConstants.h"
#import <objc/runtime.h>
#import "NSManagedObject+HighPoint.h"

#import "NSManagedObjectContext+HighPoint.h"
#import "Photo.h"
#import "NSNumber+Convert.h"
#import "NSString+Convert.h"




static DataStorage *dataStorage;
@interface DataStorage()
@property(nonatomic, retain) User* currentUser;
@end

@implementation DataStorage
+ (DataStorage *)sharedDataStorage {
    @synchronized (self) {
        static dispatch_once_t onceToken;
        if (!dataStorage) {
            dispatch_once(&onceToken, ^{
                dataStorage = [[DataStorage alloc] init];
                /*
                dataStorage.backgroundOperationQueue = [[NSOperationQueue alloc] init];
                dataStorage.backgroundOperationQueue.maxConcurrentOperationCount = 1;
                //Merge changes between context
                [[NSNotificationCenter defaultCenter]
                        addObserverForName:NSManagedObjectContextDidSaveNotification
                                    object:nil
                                     queue:nil
                                usingBlock:^(NSNotification *note) {
                                    NSManagedObjectContext *moc = ((HPAppDelegate *) [UIApplication sharedApplication].delegate).managedObjectContext;
                                    if (note.object != moc)
                                        [moc performBlock:^() {
                                            [moc mergeChangesFromContextDidSaveNotification:note];
                                        }];
                                }];
                 */
            });
        }
        return dataStorage;
    }
}

#pragma mark -
#pragma mark maxEntertimentPrice
- (MaxEntertainmentPrice *)createMaxPrice:(NSDictionary *)param forContext:(NSManagedObjectContext*) context    {
    MaxEntertainmentPrice *maxP = [MaxEntertainmentPrice createInContext:context];
    maxP.amount = [param[@"amount"] convertToNSNumber];
    maxP.currency = [param[@"currency"] convertToNSString];
    return maxP;
}
#pragma mark -
#pragma mark minEntertimentPrice
- (MinEntertainmentPrice *)createMinPrice:(NSDictionary *)param forContext:(NSManagedObjectContext*) context{
    MinEntertainmentPrice *minP = [MinEntertainmentPrice createInContext:context];
    minP.amount = [param[@"amount"] convertToNSNumber];
    minP.currency = [param[@"currency"] convertToNSString];
    return minP;
}

#pragma mark -
#pragma mark user filter
- (UserFilter *)createUserFilterEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context   {
    UserFilter *uf;
    NSArray *filters = [UserFilter findAllInContext:context];
    if (filters.count == 0) {
        uf = [UserFilter createInContext:context];
    } else {
        uf = filters[0];
    }
    uf.maxAge = [param[@"maxAge"]convertToNSNumber];
    uf.minAge = [param[@"minAge"]convertToNSNumber];
    uf.viewType = [param[@"viewType"]convertToNSNumber];
    NSMutableArray *arr = [NSMutableArray new];
    for (NSNumber *p in param[@"genders"]) {
        Gender *gender = [Gender createInContext:context];
        gender.genderType = p;
        [arr addObject:gender];
    }
    NSArray *citiesArr = param[@"cityIds"];
    if ([citiesArr isKindOfClass:[NSArray class]]) {
        if (citiesArr.count > 0) {
            NSArray *localPoints = [City findAllWithPredicate:[NSPredicate predicateWithFormat:@"cityId == %d", [citiesArr[0] intValue] ] inContext:context];
            if(localPoints.count > 0)
                uf.city = localPoints[0];
            else uf.city = nil;
        } else {
            uf.city = nil;
        }
    } else {
        uf.city = nil;
    }
    uf.gender = [NSSet setWithArray:arr];
    return uf;
}

- (void) updateUserFilterEntity : (NSDictionary *) param {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createUserFilterEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
    }];
}
- (void)setAndSaveCityToUserFilter:(City *)globalCity {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *filters = [UserFilter findAllInContext:localContext];
        UserFilter *uf;
        City *city = [globalCity MR_inContext:localContext];
        if (filters.count > 0) {
            uf = filters[0];
        }
        if (city) {
            uf.city = city;
        } else {
            uf.city = nil;
        }
    } completion:^(BOOL success, NSError *error)    {
    }];
}
- (void)updateCityAtUserFilter:(City *)city {
    [self setAndSaveCityToUserFilter:city];
}

- (void)removeAndSaveCitiesFromUserFilter {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *filters = [UserFilter findAllInContext:localContext];
        UserFilter *uf;
        if (filters.count > 0) {
            uf = filters[0];
        }
        uf.city = nil;
    } completion:^(BOOL success, NSError *error)    {
    }];
}
- (UserFilter *)getUserFilter {
    
    NSArray *filters = [UserFilter findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    if (filters.count > 0) {
        return filters[0];
    } else return nil;
}
- (void)removeAndSaveUserFilter {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *filters = [UserFilter findAllInContext:localContext];
        if (filters.count > 0) {
            [filters[0] deleteInContext:localContext];
        }
    } completion:^(BOOL success, NSError *error)    {
    }];
}

#pragma mark -
#pragma mark education entity

- (Education *)createEducationEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context{
    Education *edu = [Education createInContext:context];
    edu.id_ = [param[@"id"]convertToNSNumber];
    edu.fromYear = [param[@"fromYear"]convertToNSNumber];
    edu.schoolId = [param[@"schoolId"]convertToNSNumber];
    edu.specialityId = [param[@"specialityId"]convertToNSNumber];
    edu.toYear = [param[@"toYear"]convertToNSNumber];
    return edu;
}
- (User*) getCurrentUserForContext:(NSManagedObjectContext*) context {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isCurrentUser  = %d", 1];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *users = [User findAllWithPredicate:predicate inContext:context];
        if(users.count > 0) return users[0];
    } else return nil;
}

- (void)addAndSaveEducationEntityForUser:(NSDictionary *)param {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Education *ed = [weakSelf createEducationEntity:param forContext:localContext];
        User *user = [weakSelf getCurrentUserForContext:localContext];
        NSMutableArray *education = [[user.education allObjects] mutableCopy];
        if (education != nil) {
            [education addObject:ed];
        } else {
            education = [[NSMutableArray alloc] init];
        }
        user.education = [NSSet setWithArray:education];
    } completion:^(BOOL success, NSError *error)    {
    }];
}

- (void)deleteAndSaveEducationEntityFromUser:(NSArray *)ids {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        User *user = [weakSelf getCurrentUserForContext:localContext];
        NSMutableArray *educationItems = [[user.education allObjects] mutableCopy];
        NSMutableArray *discardedItems = [NSMutableArray array];
        Education *item;
        for (item in educationItems) {
            for (NSUInteger i = 0; i < ids.count; i++) {
                if ([item.id_ intValue] == [ids[i] intValue]) {
                    [discardedItems addObject:item];
                }
            }
        }
        [educationItems removeObjectsInArray:discardedItems];
        user.education = [NSSet setWithArray:educationItems];
    } completion:^(BOOL success, NSError *error)    {
    }];
}

#pragma mark - language

- (Language *)createLanguageEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context   {
    Language *lan = [Language createInContext:context];
    lan.id_ = [param[@"id"]convertToNSNumber];
    lan.name = [param[@"name"]convertToNSString];
    return lan;
}
- (void)addAndSaveLanguageEntityForUser:(NSDictionary *)param {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *user = [weakSelf getCurrentUserForContext:localContext];
        Language *lng = [weakSelf createLanguageEntity:param forContext:localContext];
        NSMutableArray *languages = [[user.language allObjects] mutableCopy];
        if (languages != nil) {
            [languages addObject:lng];
        } else {
            languages = [[NSMutableArray alloc] init];
        }
        user.language = [NSSet setWithArray:languages];
    } completion:^(BOOL success, NSError *error)    {
    }];
    
}
- (void)deleteAndSaveLanguageEntityFromUser:(NSArray *)ids {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *user = [weakSelf getCurrentUserForContext:localContext];
        NSMutableArray *languageItems = [[user.language allObjects] mutableCopy];
        NSMutableArray *discardedItems = [NSMutableArray array];
        Language *item;
        for (item in languageItems) {
            for (NSUInteger i = 0; i < ids.count; i++) {
                if ([item.id_ intValue] == [ids[i] intValue]) {
                    [discardedItems addObject:item];
                }
            }
        }
        [languageItems removeObjectsInArray:discardedItems];
        user.language = [NSSet setWithArray:languageItems];
    } completion:^(BOOL success, NSError *error)    {
    }];
}
- (void)createTempLanguage:(NSDictionary *)param withComplation:(complationBlock)block{
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createLanguageEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        Language *lng = [weakSelf getLanguageById:param[@"id"] forContext:[NSManagedObjectContext MR_defaultContext]];
        block(lng);
    }];
}
- (void)removeLanguageObjectById:(NSNumber *)langId {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Language *lng = [weakSelf getLanguageById:langId forContext:localContext];
        if(lng)
            [lng deleteInContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (Language *)getLanguageById:(NSNumber *)langId forContext:(NSManagedObjectContext*) context   {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [langId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *lang = [Language findAllWithPredicate:predicate inContext:context];
        if(lang.count > 0) return lang[0];
    } else return nil;
    
}
- (void)deleteAndSaveAllLanguages {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *lang = [Language findAllInContext:localContext];
        for(Language *lng in lang) {
            [lng deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}
////////////////////////////////////////////////////////////////////////////////////
#pragma mark - school

- (School *)createSchoolEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context{
    School *sch = [School createInContext:context];
    sch.id_ = [param[@"id"]convertToNSNumber];
    sch.name = [param[@"name"]convertToNSString];
    return sch;
}
- (void)createTempSchool:(NSDictionary *)param withComplation:(complationBlock)block{
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createSchoolEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        School *sch = [weakSelf getSchoolById:param[@"id"] forContext:[NSManagedObjectContext MR_defaultContext]];
        block(sch);
    }];
    
 }
- (void)removeSchoolObjectById:(NSNumber*)schoolId {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        School *sch = [weakSelf getSchoolById:schoolId forContext:localContext];
        if(sch)
            [sch deleteInContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (School *)getSchoolById:(NSNumber *)schoolId forContext:(NSManagedObjectContext*) context {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [schoolId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [School findAllWithPredicate:predicate inContext:context];
        if(sch.count > 0) return sch[0];
    } else return nil;
}

- (void)deleteAllSchools {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *schools = [School findAllInContext:localContext];
        for(School *s in schools) {
            [s deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}
///////////////////////////////////////////////////////
#pragma mark - specialities

- (Speciality *)createSpecialityEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context {
    Speciality *sp = [Speciality createInContext:context];
    sp.id_ = [param[@"id"]convertToNSNumber];
    sp.name = [param[@"name"]convertToNSString];
    return sp;
}

- (void)createTempSpeciality:(NSDictionary *)param withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createSpecialityEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        Speciality *sp = [weakSelf getSpecialityById:param[@"id"] forContext:[NSManagedObjectContext MR_defaultContext]];
        block(sp);
    }];
}
- (void)removeSpecialityObjectById:(NSNumber *)specialityId {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Speciality *sp = [weakSelf getSpecialityById:specialityId forContext:localContext];
        if(sp)
            [sp deleteInContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (Speciality *)getSpecialityById:(NSNumber *)specId forContext:(NSManagedObjectContext*) context   {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [specId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [Speciality findAllWithPredicate:predicate inContext:context];
        if(sch.count > 0) return sch[0];
    } else return nil;
}

- (void)deleteAllSpeciality {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *specs = [Speciality findAllInContext:localContext];
        for(Speciality *s in specs) {
            [s deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

/////////////////////////////////////////////////////////////////
#pragma mark - place

- (Place *)createPlaceEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context{
    Place *pl = [Place createInContext:context];
    pl.id_ = [param[@"id"] convertToNSNumber];
    pl.cityId = [param[@"cityId"] convertToNSNumber];
    pl.name = [param[@"name"] convertToNSString];
    return pl;
}

- (void)addAndSavePlaceEntity:(NSDictionary *)param forUser:(User *)globalUser {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Place *pl = [weakSelf createPlaceEntity:param forContext:localContext];
        User* user = [globalUser MR_inContext:localContext];
        NSMutableArray *places = [[user.place allObjects] mutableCopy];
        if (places != nil) {
            [places addObject:pl];
        } else {
            places = [[NSMutableArray alloc] init];
        }
        user.place = [NSSet setWithArray:places];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (void)deleteAndSavePlaceEntityFromUserWithIds:(NSArray *)ids {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *currentUser = [weakSelf getCurrentUserForContext:localContext];
        NSMutableArray *placesItems = [[currentUser.place allObjects] mutableCopy];
        NSMutableArray *discardedItems = [NSMutableArray array];
        Place *item;
        for (item in placesItems) {
            for (NSUInteger i = 0; i < ids.count; i++) {
                if ([item.id_ intValue] == [ids[i] intValue]) {
                    [discardedItems addObject:item];
                }
            }
        }
        [placesItems removeObjectsInArray:discardedItems];
        currentUser.place = [NSSet setWithArray:placesItems];
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (void)deleteAndSavePlaceEntityForCurrentUserWithCity:(City *) globalCity {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *currentUser = [weakSelf getCurrentUserForContext:localContext];
        City* city = [globalCity MR_inContext:localContext];
        NSArray * returnArray = [[currentUser.place allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"cityId != %@",city.cityId]];
        currentUser.place = [NSSet setWithArray:returnArray];
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (void) setAndSaveCurrentUserMaxEntertainmentPrice:(NSNumber*) number{
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *currentUser = [weakSelf getCurrentUserForContext:localContext];
        currentUser.maxentertainment.amount = number;
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (void) setAndSaveCurrentUserMinEntertainmentPrice:(NSNumber*) number{
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *currentUser = [weakSelf getCurrentUserForContext:localContext];
        currentUser.minentertainment.amount = number;
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}
- (void)createTempPlace:(NSDictionary *)param withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createPlaceEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        Place *placeEnt = [weakSelf getPlaceById:param[@"id"] forContext:[NSManagedObjectContext MR_defaultContext]];
        block(placeEnt);
    }];

}

- (void)removePlaceObjectById:(NSNumber *)placeId {
   __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Place *plEnt = [weakSelf getPlaceById:placeId forContext:localContext];
        if(plEnt)
            [plEnt deleteInContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (Place *)getPlaceById:(NSNumber *)postId forContext:(NSManagedObjectContext*) context {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [postId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *pl = [Place findAllWithPredicate:predicate inContext:context];
        if(pl.count > 0) return pl[0];
    } else return nil;
}


- (void)deleteAllPlaces {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *places = [Place findAllInContext:localContext];
        for(Place *p in places) {
            [p deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

#pragma mark -
#pragma mark career entity

- (Career *)createCareerEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context   {
    Career *car = [Career createInContext:context];
    
    car.id_ = [param[@"id"] convertToNSNumber];
    car.fromYear = [param[@"fromYear"] convertToNSNumber];
    car.companyId = [param[@"companyId"] convertToNSNumber];
    car.postId = [param[@"postId"] convertToNSNumber];
    car.toYear = [param[@"toYear"] convertToNSNumber];
    return car;
}


- (void)addAndSaveCareerEntityForUser:(NSDictionary *)param {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Career *ca = [weakSelf createCareerEntity:param forContext:localContext];
        User* user = [weakSelf getCurrentUserForContext:localContext];
        NSMutableArray *careerItems = [[user.career allObjects] mutableCopy];
        if (careerItems != nil) {
            [careerItems addObject:ca];
        } else {
            careerItems = [[NSMutableArray alloc] init];
        }
        user.career = [NSSet setWithArray:careerItems];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (void)deleteAndSaveCareerEntityFromUser:(NSArray *)ids {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User* user = [weakSelf getCurrentUserForContext:localContext];
        NSMutableArray *careerItems = [[user.career allObjects] mutableCopy];
        NSMutableArray *discardedItems = [NSMutableArray array];
        Career *item;
        for (item in careerItems) {
            for (NSUInteger i = 0; i < ids.count; i++) {
                if ([item.id_ intValue] == [ids[i] intValue]) {
                    [discardedItems addObject:item];
                }
            }
        }
        [careerItems removeObjectsInArray:discardedItems];
        user.career = [NSSet setWithArray:careerItems];
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}


#pragma mark - career-post

- (CareerPost*)createCareerPostEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context {
    CareerPost *postEnt = [CareerPost createInContext:context];
    postEnt.name = [param[@"name"] convertToNSString];
    postEnt.id_ = [param[@"id"] convertToNSNumber];
    return postEnt;
}

- (void)createTempCareerPost:(NSDictionary *)param withComplation:(complationBlock)block{
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createCareerPostEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        CareerPost *carPost = [weakSelf getCareerPostById:param[@"id"] forContext:[NSManagedObjectContext MR_defaultContext]];
        block(carPost);
    }];
}

- (void)removeCareerPostObjectById:(NSNumber *)cPostId {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        CareerPost *postEnt = [weakSelf getCareerPostById:cPostId forContext:localContext];
        if(postEnt)
            [postEnt deleteInContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (CareerPost *)getCareerPostById:(NSNumber *)postId forContext:(NSManagedObjectContext*) context   {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [postId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *pl = [CareerPost findAllWithPredicate:predicate inContext:context];
        if(pl.count > 0) return pl[0];
    } else return nil;
}

- (void)deleteAllCareerPosts {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *posts = [CareerPost findAllInContext:localContext];
        for(CareerPost *p in posts) {
            [p deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}


#pragma mark - company

- (Company*)createCompanyEntity:(NSDictionary *)param  forContext:(NSManagedObjectContext*) context{
    Company *companyEnt = [Company createInContext:context];
    companyEnt.name = [param[@"name"] convertToNSString];
    companyEnt.id_ = [param[@"id"] convertToNSNumber];
    return companyEnt;
}
- (void)createTempCompany:(NSDictionary *)param withComplation:(complationBlock)block  {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createCompanyEntity:param forContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        Company *companyEnt = [weakSelf getCompanyById:param[@"id"] forContext:[NSManagedObjectContext MR_defaultContext]];
        block(companyEnt);
    }];
}
- (void)removeCompanyObjectById:(NSNumber*)companyId {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Company *companyEnt = [weakSelf getCompanyById:companyId forContext:localContext];
        if(companyEnt)
            [companyEnt deleteInContext:localContext];
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}
- (Company *)getCompanyById:(NSNumber *)companyId forContext:(NSManagedObjectContext*) context{
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [companyId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *pl = [Company findAllWithPredicate:predicate inContext:context];
        if(pl.count > 0) return pl[0];
    } else return nil;
}
- (void)deleteCompanyPosts {
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *comp = [Company findAllInContext:localContext];
        for(Company *p in comp) {
            [p deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

#pragma mark -
#pragma mark avatar entity

- (Avatar *)createAvatarEntity:(NSDictionary *)param forContext:(NSManagedObjectContext*) context{
    
    Avatar *avatar = [Avatar createInContext:context];
    if(param[@"crop"] && param[@"image"] && param[@"originalImage"]) {
        
        if([param[@"crop"] isKindOfClass:[NSDictionary class]]) {
            avatar.cropHeight = [param[@"crop"] objectForKey:@"height"];
            avatar.cropWidth = [param[@"crop"] objectForKey:@"width"];
            avatar.cropLeft = [param[@"crop"] objectForKey:@"left"];
            avatar.cropTop = [param[@"crop"] objectForKey:@"top"];
        }
        if([param[@"image"] isKindOfClass:[NSDictionary class]]) {
            avatar.encodedImgHeight = [param[@"image"] objectForKey:@"height"];
            avatar.encodedImgWidth = [param[@"image"] objectForKey:@"width"];
            avatar.encodedImgSrc = [param[@"image"] objectForKey:@"src"];
        }
        if([param[@"originalImage"] isKindOfClass:[NSDictionary class]]) {
            avatar.originalImgHeight = [param[@"originalImage"] objectForKey:@"height"];
            avatar.originalImgWidth = [param[@"originalImage"] objectForKey:@"width"];
            //avatar.originalImgSrc = [param[@"originalImage"] objectForKey:@"src"];
            avatar.originalImgSrc = [[param[@"originalImage"] objectForKey:@"src"] stringByAppendingString:@"?size=s640"];
        }
    }
    else {
        //avatar.originalImgSrc = param[@"src"];
        avatar.originalImgHeight = param[@"height"];
        avatar.originalImgHeight = param[@"width"];
        avatar.originalImgSrc = [param[@"src"] stringByAppendingString:@"?size=s640"];
    }
    return avatar;
}

#pragma mark -
#pragma mark current user entity

- (void)createAndSaveUserEntity:(NSMutableArray*) params forUserType:(UserType)type withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)    {
        NSDateFormatter *dft = [[NSDateFormatter alloc] init];
        [dft setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        for(NSDictionary *param in params) {
            
            //NSDictionary *param;
            //if([key isKindOfClass:[NSString class]]) {
            //    param = [params objectForKey:key];
            //} else if ([key isKindOfClass:[NSDictionary class]]) {
            //    param = key;
            //}
            
            User *user;
            NSArray *localUsers = [User findAllWithPredicate:[NSPredicate predicateWithFormat:@"userId == %d", [param[@"id"] intValue] ] inContext:localContext];
            if(localUsers.count >0) {
                user = localUsers[0] ;
            } else {
                user = [User createInContext:localContext];
            }
            
            
            if (param[@"id"])
                user.userId = [param[@"id"] convertToNSNumber];
            //user type
            if (type == CurrentUserType) {
                user.isCurrentUser = @YES;
            }
            if (type == MainListUserType) {
                user.isItFromMainList = @YES;
            }
            if (type == ContactUserType) {
                user.isItFromContact = @YES;
            }
            if (type == PointLikeUserType) {
                user.isItFromPointLike = @YES;
            }
            if (param[@"name"])
                user.name = [param[@"name"] convertToNSString];
            if (param[@"cityId"])
                user.cityId = [param[@"cityId"] convertToNSNumber];
            if (param[@"createdAt"])
                user.createdAt = [dft dateFromString: param[@"createdAt"]];
            if (param[@"dateOfBirth"])
                user.dateOfBirth =[df dateFromString: param[@"dateOfBirth"]];
            if (param[@"email"])
                user.email = [param[@"email"] convertToNSString];
            if (param[@"gender"])
                user.gender = [param[@"gender"] convertToNSNumber];
            if (param[@"visibility"]) {
                user.visibility = [param[@"visibility"] convertToNSNumber];
            }
            if (param[@"online"]) {
                user.online = [param[@"online"] convertToNSNumber];
            }
            if (param[@"avatar"]) {
                user.avatar = [weakSelf createAvatarEntity:param[@"avatar"] forContext:localContext];
                user.avatar.user = user;
            }
            if (param[@"age"])
                user.age = [param[@"age"] convertToNSNumber];
            if ([param[@"education"] isKindOfClass:[NSDictionary class]]) {
                if (![param[@"education"] isKindOfClass:[NSNull class]]) {
                    Education *ed = [weakSelf createEducationEntity:param[@"education"] forContext:localContext];
                    ed.user = user;
                    user.education = [NSSet setWithArray:@[ed]];
                }
            } else if ([param[@"education"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *entArray = [NSMutableArray new];
                for (NSDictionary *t in param[@"education"]) {
                    Education *ed = [weakSelf createEducationEntity:t forContext:localContext] ;
                    ed.user = user;
                    [entArray addObject:ed];
                }
                user.education = [NSSet setWithArray:entArray];
            }
            if ([param[@"career"] isKindOfClass:[NSDictionary class]]) {
                if (![param[@"career"] isKindOfClass:[NSNull class]]) {
                    Career *ca = [weakSelf createCareerEntity:param[@"career"] forContext:localContext];
                    ca.user = user;
                    user.career = [NSSet setWithArray:@[ca]];
                }
            } else if ([param[@"career"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *entArray = [NSMutableArray new];
                for (NSDictionary *t in param[@"career"]) {
                    Career *ca = [weakSelf createCareerEntity:t forContext:localContext];
                    ca.user = user;
                    [entArray addObject:ca];
                }
                user.career = [NSSet setWithArray:entArray];
            }
            if ([param[@"languageIds"] isKindOfClass:[NSDictionary class]]) {
                if (![param[@"languageIds"] isKindOfClass:[NSNull class]]) {
                    Language *lan = [weakSelf createLanguageEntity:param[@"language"] forContext:localContext];
                    lan.user = user;
                    user.language = [NSSet setWithArray:@[lan]];
                }
            } else if ([param[@"languageIds"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *entArray = [NSMutableArray new];
                for (NSDictionary *t in param[@"career"]) {
                    Language *lan = [weakSelf createLanguageEntity:t forContext:localContext];
                    lan.user = user;
                    [entArray addObject:lan];
                }
                user.language = [NSSet setWithArray:entArray];
            }
            NSArray *cityIds;
            NSMutableString *par;
            if (![param[@"favoriteCityIds"] isKindOfClass:[NSNull class]]) {
                cityIds = param[@"favoriteCityIds"];
                par = [NSMutableString new];
                for (NSNumber *n in cityIds) {
                    [par appendFormat:@"%d;", [n intValue]];
                }
                if (par.length > 0) {
                    NSRange rng;
                    rng.location = par.length - 1;
                    rng.length = 1;
                    [par deleteCharactersInRange:rng];
                    user.favoriteCityIds = par;
                }
            }
            if (![param[@"favoritePlaceIds"] isKindOfClass:[NSNull class]]) {
                cityIds = param[@"favoritePlaceIds"];
                par = [NSMutableString new];
                for (NSNumber *n in cityIds) {
                    [par appendFormat:@"%d;", [n intValue]];
                }
                if (par.length > 0) {
                    NSRange rng;
                    rng.location = par.length - 1;
                    rng.length = 1;
                    [par deleteCharactersInRange:rng];
                    user.favoritePlaceIds = par;
                }
            }
            if (type == CurrentUserType) {
                if (![param[@"filter"] isKindOfClass:[NSNull class]]) {
                    UserFilter *uf = [weakSelf createUserFilterEntity:param[@"filter"] forContext:localContext];
                    uf.user = user;
                    user.userfilter = uf;
                }
            }
            if (![param[@"languageIds"] isKindOfClass:[NSNull class]]) {
                cityIds = param[@"languageIds"];
                par = [NSMutableString new];
                for (NSNumber *n in cityIds) {
                    [par appendFormat:@"%d;", [n intValue]];
                }
                if (par.length > 0) {
                    NSRange rng;
                    rng.location = par.length - 1;
                    rng.length = 1;
                    [par deleteCharactersInRange:rng];
                    user.languageIds = par;
                }
            }
            
            if (![param[@"maxEntertainmentPrice"] isKindOfClass:[NSNull class]]) {
                MaxEntertainmentPrice *mxP = [weakSelf createMaxPrice:param[@"maxEntertainmentPrice"] forContext:localContext];
                mxP.user = user;
                user.maxentertainment = mxP;
            }
            if (![param[@"minEntertainmentPrice"] isKindOfClass:[NSNull class]]) {
                MinEntertainmentPrice *mnP = [weakSelf createMinPrice:param[@"minEntertainmentPrice"] forContext:localContext];
                mnP.user = user;
                user.minentertainment = mnP;
            }
            if (![param[@"nameForms"] isKindOfClass:[NSNull class]]) {
                cityIds = param[@"nameForms"];
                par = [NSMutableString new];
                for (NSString *n in cityIds) {
                    [par appendString:n];
                    [par appendString:@";"];
                }
                if (par.length > 0) {
                    NSRange rng;
                    rng.location = par.length - 1;
                    rng.length = 1;
                    [par deleteCharactersInRange:rng];
                    user.nameForms = par;
                }
            }
            NSArray *points = [UserPoint findAllWithPredicate:[NSPredicate predicateWithFormat:@"pointUserId == %d", [user.userId intValue] ] inContext:localContext];
            if (points.count > 0 && [user.isItFromMainList boolValue]) {
                user.point = points[0];
            }
        }
    } completion:^(BOOL success, NSError *error)    {
        
        block(error);
    }];
}
#pragma mark -
#pragma mark pointEntity

- (void) createAndSavePoint:(NSArray*) array withComplation:(complationBlock)block{
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)    {
        for(NSDictionary *dict in array) {
            UserPoint *localPoint;
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSArray *localPoints = [UserPoint findAllWithPredicate:[NSPredicate predicateWithFormat:@"pointId == %d", [dict[@"id"] intValue] ] inContext:localContext];
            if(localPoints.count >0) {
                localPoint = localPoints[0];
            } else {
                localPoint = [UserPoint createInContext:localContext];
            }
            
            localPoint.pointCreatedAt = [df dateFromString:dict[@"createdAt"]];
            localPoint.pointLiked = [dict[@"liked"] convertToNSNumber];
            localPoint.pointText = [dict[@"text"] convertToNSString];
            localPoint.pointUserId = [[dict[@"userId"] convertToNSNumber] convertToNSNumber];
            localPoint.pointValidTo =  [df dateFromString:dict[@"validTo"]];
            NSArray *localUsers = [User findAllWithPredicate:[NSPredicate predicateWithFormat:@"userId == %d", [dict[@"userId"] intValue] ] inContext:localContext];
            if(localUsers.count >0) {
                User* user = localUsers[0];
                user.point = localPoint;
            }
        }
    } completion:^(BOOL success, NSError *error)    {
        //[[NSManagedObjectContext defaultContext] saveNestedContexts];
        block(error);
    }];
}

- (User *)getCurrentUser {
    User* user = self.currentUser;
    if(!user) {
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
        [request setEntity:entity];
        NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
        [sortDescriptors addObject:sortDescriptor];
        [request setSortDescriptors:sortDescriptors];

        NSMutableString *predicateString = [NSMutableString string];
        [predicateString appendFormat:@"isCurrentUser  = %d", 1];

        @try {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            [request setPredicate:predicate];
        }
        @catch (NSException *exception) {
            return nil;
        }


        NSError *error = nil;
        [request setFetchLimit:1];
        NSArray *array = [context executeFetchRequest:request error:&error];
        if ([array count] == 1) {
            user = array[0];
            self.currentUser = user;
        } else {
            NSLog(@"users count = %lu", (unsigned long)[array count]);
        }
        //else
         //   NSAssert(false, @"2 текущих пользователя, как мило");
    }
    return user;
}

- (User*)currentUser {
    User* user = nil;
    if(_currentUser && !_currentUser.isFault && [NSThread mainThread]){
        user = [_currentUser moveToContext:[NSManagedObjectContext threadContext]];
        if(user.isFault){
            user = nil;
        }
    }
    return user;
}

- (void)deleteAndSaveCurrentUser {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)    {
        
        NSMutableString *predicateString = [NSMutableString string];
        [predicateString appendFormat:@"isCurrentUser  = %d", 1];
        NSPredicate *predicate;
        @try {
            predicate = [NSPredicate predicateWithFormat:predicateString];
        }
        @catch (NSException *exception) {
            NSLog(@"predicate error");
        }
        if(predicate) {
            NSArray *users = [User  findAllSortedBy:@"userId" ascending:NO withPredicate:predicate inContext:localContext];
            User *user = users[0];
            [user deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}
- (NSArray*) getUsersForCityId:(NSNumber*) cityId {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"cityId  = %d", [cityId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *users = [User  findAllSortedBy:@"userId" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        return users;
    } else return nil;
}

- (User *)getUserForId:(NSNumber *)id_ {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"userId  = %d", [id_ intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *users = [User findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        if(users.count > 0) return users[0];
    } else return nil;
}


- (void)deleteAndSaveUserPointForUser:(User*) globalUser{
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User* user = [globalUser MR_inContext:localContext];
        user.point = nil;
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (void) updateAndSaveVisibility:(UserVisibilityType) visibilityType forUser:(User*) globalUser{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User* user = [globalUser MR_inContext:localContext];
        user.visibility = @(visibilityType);
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (UserPoint *)getPointForUserId:(NSNumber *)userId {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointUserId  = %d", [userId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [UserPoint findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        if(sch.count > 0) return sch[0];
    } else return nil;
}

- (UserPoint *)getPointForId:(NSNumber *)id_ {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointId  = %d", [id_ intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [UserPoint findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        if(sch.count > 0) return sch[0];
    } else return nil;
}


- (void)setAndSavePointLiked:(NSNumber *)pointId :(BOOL)isLiked {
    UserPoint *globalPoint = [self getPointForId:pointId];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        UserPoint* point = [globalPoint MR_inContext:localContext];
        point.pointLiked = @(isLiked);
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (NSDictionary *)prepareParamFromUser:(User *)user {

    NSArray *lng = [user.language allObjects];
    NSMutableString *langStr = [NSMutableString stringWithString:@""];
    for (Language *l in lng) {
        [langStr appendFormat:@"%d,", [l.id_ intValue]];
    }
    NSArray *edu = [user.education allObjects];
    NSMutableString *schoolStr = [NSMutableString stringWithString:@""];
    NSMutableString *specStr = [NSMutableString stringWithString:@""];
    for (Education *e in edu) {
        [schoolStr appendFormat:@"%d,", [e.schoolId intValue]];
        [specStr appendFormat:@"%d,", [e.specialityId intValue]];
    }
    NSArray *car = [user.career allObjects];
    NSMutableString *carrierStr = [NSMutableString stringWithString:@""];
    NSMutableString *workPlaceStr = [NSMutableString stringWithString:@""];
    for (Career *c in car) {
        [carrierStr appendFormat:@"%d,", [c.companyId intValue]];
        [workPlaceStr appendFormat:@"%d,", [c.postId intValue]];
    }
    NSArray *pl = [user.favoritePlaceIds componentsSeparatedByString:@";"];
    NSMutableString *placeStr = [NSMutableString stringWithString:@""];
    for (NSString *p in pl) {
        [placeStr appendString:p];
        [placeStr appendString:@","];
    }
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[Utils deleteLastChar:placeStr], @"placeIds",
                                                                     [Utils deleteLastChar:carrierStr], @"companyIds",
                                                                     [Utils deleteLastChar:workPlaceStr], @"careerPostIds",
                                                                     [Utils deleteLastChar:schoolStr], @"schoolIds",
                                                                     [Utils deleteLastChar:specStr], @"specialityIds",
                                                                     [Utils deleteLastChar:langStr], @"languageIds",
                                                                     user, @"user", nil];//workPlaceStr
    return param;
}

- (void)linkParameter:(NSDictionary *)param toUser:(User *)user withComplation:(complationBlock)block{
     __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *local_user = [user MR_inContext:localContext];
        for (Career *car in  [user.career allObjects]) {
            
            Career *local  = [car MR_inContext:localContext];
            for (NSDictionary *d in [param objectForKey:@"careerPosts"]) {
                if ([local.postId intValue] == [[d objectForKey:@"id"] intValue]) {
                    CareerPost *post = [weakSelf createCareerPostEntity:d forContext:localContext];
                    local.careerpost = post;
                }
            }
            for (NSDictionary *d in [param objectForKey:@"companies"]) {
                NSLog(@"%@", d);
                if ([local.companyId intValue] == [[d objectForKey:@"id"] intValue]) {
                    
                    Company *comp = [weakSelf createCompanyEntity:d  forContext:localContext];
                    local.company = comp;
                }
            }
            
        }
        for (Education *edu in  [user.education allObjects]) {
            
            Education *ed_local = [edu MR_inContext:localContext];
            for (NSDictionary *d in [param objectForKey:@"schools"]) {
                if ([ed_local.schoolId intValue] == [[d objectForKey:@"id"] intValue]) {
                    School *school = [weakSelf createSchoolEntity:d forContext:localContext];
                    ed_local.school = school;
                }
            }
            for (NSDictionary *d in [param objectForKey:@"specialities"]) {
                if ([ed_local.specialityId intValue] == [[d objectForKey:@"id"] intValue]) {
                    Speciality *spec = [weakSelf createSpecialityEntity:d forContext:localContext];
                    ed_local.speciality = spec;
                }
            }
            NSLog(@"%@", edu);
        }
        NSMutableArray *places = [NSMutableArray new];
        NSMutableArray *languages = [NSMutableArray new];
        for (NSDictionary *d in [param objectForKey:@"places"]) {
            Place *pl = [weakSelf createPlaceEntity:d forContext:localContext];
            City *c = [weakSelf getCityById:pl.cityId forContext:localContext];
            pl.city = c;
            [places addObject:pl];
        }
        local_user.place = [NSSet setWithArray:places];
        for (NSDictionary *d in [param objectForKey:@"languages"]) {
            Language *lng = [weakSelf createLanguageEntity:d forContext:localContext];
            [languages addObject:lng];
            
        }
        local_user.language = [NSSet setWithArray:languages];
    } completion:^(BOOL success, NSError *error) {
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedUpdateProfileData
                                                                                             object:nil
                                                                                           userInfo:nil]];
    }];
    
}

#pragma mark -
#pragma mark application photo entity
- (void)createAndSavePhotoEntity:(NSDictionary *)param {
     __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
    
        User *user = [weakSelf getCurrentUserForContext:localContext];
        Photo *photo = [Photo createInContext:localContext];
        photo.photoId = [[param objectForKey:@"id"] convertToNSNumber];
        photo.photoPosition =[[param objectForKey:@"position"] convertToNSNumber];
        if([[param objectForKey:@"title"] isKindOfClass:[NSString class]]) {
            photo.photoTitle = [param objectForKey:@"title"];
        }
        photo.userId = user.userId;
        if([[param objectForKey:@"image"] isKindOfClass:[NSDictionary class]]) {
            photo.imgeHeight =[[[param objectForKey:@"image"] objectForKey:@"height"] convertToNSNumber];
            photo.imgeWidth =[[[param objectForKey:@"image"] objectForKey:@"width"] convertToNSNumber];
            if([[[param objectForKey:@"image"] objectForKey:@"src"] isKindOfClass:[NSString class]]) {
                photo.imgeSrc = [[param objectForKey:@"image"] objectForKey:@"src"];
            }
        }
    } completion:^(BOOL success, NSError *error) {
    }];
}
- (void)deletePhotos {
    
}
#pragma mark -
#pragma mark application settings entity

- (void)createAndSaveApplicationSettingEntity:(NSDictionary *)param {
    
    [self deleteAppSettings:^(NSError *error) {
        if(!error) {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                AppSetting *settings = [AppSetting createInContext:localContext];
                settings.avatarMaxFileSize = [param[@"avatar"] objectForKey:@"maxFileSize"];
                if ([[param[@"avatar"] objectForKey:@"minImageSize"] isKindOfClass:[NSArray class]]) {
                    if ([[param[@"avatar"] objectForKey:@"minImageSize"] count] == 2) {
                        settings.avatarMinImageHeight = [[[param[@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:0] convertToNSNumber];//minImageSize
                        settings.avatarMinImageWidth = [[[param[@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:1] convertToNSNumber];
                    }
                }
                if ([[param[@"avatar"] objectForKey:@"minCropSize"] isKindOfClass:[NSArray class]]) {
                    if ([[param[@"avatar"] objectForKey:@"minCropSize"] count] == 2) {
                        settings.avatarMinImageHeight = [[[param[@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:0] convertToNSNumber];
                        settings.avatarMinImageWidth = [[[param[@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:1] convertToNSNumber];
                    }
                }
                
                if ([[param[@"avatar"] objectForKey:@"minImageSize"] isKindOfClass:[NSDictionary class]])    {
                    settings.avatarMinImageWidth = [[[param[@"avatar"] objectForKey:@"minImageSize"] objectForKey:@"width"] convertToNSNumber];
                    settings.avatarMinImageHeight = [[[param[@"avatar"] objectForKey:@"minImageSize"] objectForKey:@"height"] convertToNSNumber];
                }
                if ([[param[@"avatar"] objectForKey:@"minCropSize"] isKindOfClass:[NSDictionary class]])    {
                    settings.avatarMinCropSizeHeight = [[[param[@"avatar"] objectForKey:@"minCropSize"] objectForKey:@"height"] convertToNSNumber];
                    settings.avatarMinCropSizeWidth = [[[param[@"avatar"] objectForKey:@"minCropSize"] objectForKey:@"width"] convertToNSNumber];
                }
                if ([[param[@"photo"] objectForKey:@"minImageSize"] isKindOfClass:[NSArray class]]) {
                    if ([[param[@"photo"] objectForKey:@"minImageSize"] count] == 2) {
                        settings.photoMinImageHeight = [[[param[@"photo"] objectForKey:@"minImageSize"] objectAtIndex:0] convertToNSNumber];//minImageSize
                        settings.photoMinImageWidth = [[[param[@"photo"] objectForKey:@"minImageSize"] objectAtIndex:1] convertToNSNumber];
                    }
                }
                if ([[param[@"photo"] objectForKey:@"minImageSize"] isKindOfClass:[NSDictionary class]])    {
                    settings.photoMinImageWidth = [[[param[@"photo"] objectForKey:@"minImageSize"] objectForKey:@"width"] convertToNSNumber];
                    settings.photoMinImageHeight = [[[param[@"photo"] objectForKey:@"minImageSize"] objectForKey:@"height"] convertToNSNumber];
                }
                settings.photoMaxFileSize = [param[@"photo"] objectForKey:@"maxFileSize"];
                settings.pointMaxPeriod = [[param[@"point"] objectForKey:@"maxPeriod"] convertToNSNumber];
                settings.pointMinPeriod = [[param[@"point"] objectForKey:@"minPeriod"] convertToNSNumber];
                if ([param[@"webSocketUrls"] isKindOfClass:[NSArray class]]) {
                    if ([param[@"webSocketUrls"] count] == 1)
                        settings.webSoketUrl = [[param[@"webSocketUrls"] objectAtIndex:0] convertToNSString];
                }
            } completion:^(BOOL success, NSError *error) {
            }];
            
        }
    } ];
}

- (void)deleteAppSettings:(complationBlock)block{
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *settings = [AppSetting findAllInContext:localContext];
        for(AppSetting *s in settings) {
            [s deleteInContext:localContext];
        }
        
    } completion:^(BOOL success, NSError *error)    {
        block(error);
    }];
}

- (AppSetting *)getAppSettings {
    NSArray *settings = [AppSetting findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    if (settings.count > 0)
        return settings[0];
    else return nil;
}
#pragma mark - users
- (NSFetchedResultsController *) usersFetchResultControllerWithPredicate:(NSString*) predicateStr {
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateStr];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSFetchedResultsController *controller = [User fetchAllSortedBy:@"userId" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
        return controller;
    } else return nil;
}
- (NSFetchedResultsController *)allUsersFetchResultsController {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isCurrentUser != 1 AND isItFromMainList == 1"];
    return [self usersFetchResultControllerWithPredicate:predicateString];
}
- (NSFetchedResultsController *)allUsersWithPointFetchResultsController {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"point != nil AND isItFromMainList == 1"];
    return [self usersFetchResultControllerWithPredicate:predicateString];
}

- (NSFetchedResultsController *)allUsersPointLikesResultsController {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isItFromPointLike == 1"];
    return [self usersFetchResultControllerWithPredicate:predicateString];
}


- (void)deleteAndSaveAllUsersWithBlock:(complationBlock)block {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSMutableString *predicateString = [NSMutableString string];
        [predicateString appendFormat:@"isCurrentUser != 1"];
        NSPredicate *predicate;
        @try {
            predicate = [NSPredicate predicateWithFormat:predicateString];
        }
        @catch (NSException *exception) {
            NSLog(@"create predicate error");
        }
        if(predicate) {
            NSArray *users = [User findAllWithPredicate:predicate inContext:localContext];
            if(users.count > 0) {
                for(User *usr in users) {
                    [usr deleteInContext:localContext];
                }
            }
        }
        
    } completion:^(BOOL success, NSError *error)    {
        block(error);
    }];
}


- (NSFetchedResultsController *)applicationSettingFetchResultsController {
    
    NSFetchedResultsController *controller = [AppSetting fetchAllSortedBy:@"avatarMaxFileSize" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
    return controller;
}

- (void)setAndSaveCityToUser:(NSNumber *)userId forCity:(City *)city {
    User *user = [self getUserForId:userId];
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        User *localUser = [user inContext:localContext];
        City *localCity = [city inContext:localContext];
        localUser.city = localCity;
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}


#pragma mark - city

- (void)createAndSaveCity:(NSDictionary *)param popular:(BOOL)isPopular withComplation:(complationBlock)block {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        
        City *city = [weakSelf getCityById:param[@"id"] forContext:localContext];
        if(!city) {
            city = [City createInContext:localContext];
            
        }
        city.cityId = [param[@"id"]convertToNSNumber];
        city.cityEnName = [param[@"enName"] convertToNSString];
        //convertToNSNumber];
        city.cityName = [param[@"name"] convertToNSString];
        city.cityNameForms = param[@"nameForms"];
        city.cityRegionId = [param[@"regionId"] convertToNSNumber];
        if (isPopular) {
            city.isPopular = @(isPopular);
        }
    } completion:^(BOOL success, NSError *error)    {
        block ([self getCityById:[param[@"id"] convertToNSNumber]]);
    }];
}

- (NSFetchedResultsController *)getPopularCities {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isPopular == 1"];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSFetchedResultsController *controller = [City fetchAllSortedBy:@"cityName" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
        return controller;
    } else return nil;
}

- (void)removeCityObjectById:(City *)city {
    City *cityEnt = [self getCityById:city.cityId];
    if (cityEnt) {
       [cityEnt deleteInContext:[NSManagedObjectContext MR_defaultContext]];
    }
}
- (City *)getCityById:(NSNumber *)cityId forContext:(NSManagedObjectContext*) context {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"cityId  = %@", cityId];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [City findAllWithPredicate:predicate inContext:context];
        if(sch.count > 0) return sch[0];
        else return nil;
    } else return nil;
}
- (City *)getCityById:(NSNumber *)cityId {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"cityId  = %d", [cityId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {

        return nil;
    }
    if(predicate) {
        NSArray *sch = [City findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        if(sch.count > 0) return sch[0];
        else return nil;
    } else return nil;
}


- (void)deleteAllCities {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *cities = [City findAllInContext:localContext];
        if(cities.count > 0) {
            for(City *city in cities) {
                [city deleteInContext:localContext];
            }
        }
        
        
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

#pragma mark - contacts


- (void)createAndSaveContactEntity:(User *)glovaluser forMessage:(Message *)globallastMessage withComplation:(complationBlock)block {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Contact *contactEnt = [weakSelf getContactById:glovaluser.userId forContext:localContext];
        if(!contactEnt) {
            contactEnt = [Contact createInContext:localContext];
        }
        contactEnt.lastmessage = [globallastMessage MR_inContext:localContext];
        contactEnt.user = [glovaluser MR_inContext:localContext];
    } completion:^(BOOL success, NSError *error)    {
        block ([self getContactById:glovaluser.userId forContext:[NSManagedObjectContext MR_defaultContext]]);
    }];
}


- (void)deleteAndSaveAllContacts {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *contacts = [Contact findAllInContext:localContext];
        if(contacts.count > 0) {
            for(Contact *cont in contacts) {
                [cont deleteInContext:localContext];
            }
        }
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (NSFetchedResultsController *)getAllContactsFetchResultsController {

    NSFetchedResultsController *controller = [Contact fetchAllSortedBy:@"user.userId" ascending:NO withPredicate:nil groupBy:nil delegate:nil];
    return controller;
}

- (User *)getSelectedUserById:(NSNumber *)id_ {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"userId  = %d", [id_ intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [User findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        if(sch.count > 0) return sch[0];
        else return nil;
    } else return nil;
}

- (Contact *)getContactById:(NSNumber *)contactId forContext:(NSManagedObjectContext*) context{
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.userId  = %d", [contactId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [Contact findAllWithPredicate:predicate inContext:context];
        if(sch.count > 0) return sch[0];
        else return nil;
    } else return nil;
}
- (void)deleteAndSaveContact:(NSNumber *)contactId {
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Contact *local = [weakSelf getContactById:contactId forContext:localContext];
        [local deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

- (NSFetchedResultsController *)getContactsByQueryFetchResultsController:(NSString *)queryStr {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.name contains[c] '%@' OR user.age == '%@' OR user.city.cityName contains[c] '%@'", queryStr, queryStr, queryStr];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSFetchedResultsController *controller = [Contact fetchAllSortedBy:@"user.userId" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
        return controller;
    } else return nil;
    
}


#pragma mark - chat

- (void)createAndSaveChatEntity:(User *)globalUser withMessages:(NSArray *)messages withComplation:(complationBlock)block {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User *user = [globalUser MR_inContext:localContext];
        Chat *chatEnt = [weakSelf getChatByUserId:user.userId forContext:localContext];
        if(!chatEnt)
            chatEnt = [Chat createInContext:localContext];
        chatEnt.user = user;
        NSMutableArray *entArray = [NSMutableArray new];
        for (NSDictionary *t in messages) {
            Message *msg = [weakSelf createMessage:t forUserId:user.userId andMessageType:HistoryMessageType forContext:localContext];
            msg.chat = chatEnt;
            [entArray addObject:msg];
        }
        chatEnt.message = [NSSet setWithArray:entArray];
        
    } completion:^(BOOL success, NSError *error)    {
  
    }];
}

- (Chat *)getChatByUserId:(NSNumber *)userId forContext:(NSManagedObjectContext*) context{
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.userId  = %d", [userId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [Chat findAllWithPredicate:predicate inContext:context];
        if(sch.count > 0) return sch[0];
        else return nil;
    } else return nil;
}
- (void)deleteAndSaveChatByUserId:(NSNumber *)userId {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Chat *chat = [weakSelf getChatByUserId:userId forContext:localContext];
        [chat deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}

#pragma mark - messages

- (Message *)createMessage:(NSDictionary *)param forUserId:(NSNumber *)userId andMessageType:(MessageTypes)type forContext:(NSManagedObjectContext*) context{

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    Message *msgEnt = [Message createInContext:context];
    msgEnt.bindedUserId = [userId convertToNSNumber];
    if (type == HistoryMessageType) {
        msgEnt.historyMessage = @YES;
    }
    if (type == LastMessageType) {
        msgEnt.lastMessage = @YES;
    }
    if (type == UnreadMessageType) {
        msgEnt.unreadMessage = @YES;
    }
    msgEnt.id_ = [param[@"id"] convertToNSNumber];
    msgEnt.createdAt = [df dateFromString:param[@"createdAt"]];
    msgEnt.destinationId = param[@"destinationId"];
    if (![param[@"readAt"] isKindOfClass:[NSNull class]]) {
        msgEnt.readAt = [df dateFromString:param[@"readAt"]];
    }
    msgEnt.sourceId = [param[@"sourceId"] convertToNSNumber];
    msgEnt.text = [param[@"text"] convertToNSString];
    return msgEnt;
}
- (Message*) getMessageForId:(NSNumber*) messId {
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %d", [messId intValue]];
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return nil;
    }
    if(predicate) {
        NSArray *sch = [Message findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        if(sch.count > 0) return sch[0];
        else return nil;
    } else return nil;
}
- (void)createAndSaveMessage:(NSDictionary *)param forUserId:(NSNumber *)userId andMessageType:(MessageTypes)type withComplation:(complationBlock)block {
    
    __weak typeof(self) weakSelf = self;
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [weakSelf createMessage:param forUserId:userId andMessageType:type forContext:localContext];
    } completion:^(BOOL success, NSError *error)    {
        
        block([self getMessageForId:[param[@"id"] convertToNSNumber]]);
    }];
    
}

- (NSInteger)allUnreadMessagesCount:(User *)user {
    
    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"unreadMessage == 1"];
    if (user) {
        [predicateString appendFormat:@"AND bindedUserId  = %d", [user.userId intValue]];
    }
    NSPredicate *predicate;
    @try {
        predicate = [NSPredicate predicateWithFormat:predicateString];
    }
    @catch (NSException *exception) {
        return 0;
    }
    if(predicate) {
        NSFetchedResultsController *controller = [Message fetchAllSortedBy:@"id_" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
        return [[controller fetchedObjects] count];
    } else return 0;
    
}
- (void)deleteAndSaveAllMessages {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray *messages = [Message findAllInContext:localContext];
        if(messages.count > 0) {
            for(Message *mess in messages) {
                [mess deleteInContext:localContext];
            }
        }
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}
- (void) setAndSaveUser: (User*) globalUser toLikePoint:(UserPoint*) globalPoint withComplationBlock:(complationBlock)block{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        User* user = [globalUser MR_inContext:localContext];
        UserPoint* point = [globalPoint MR_inContext:localContext];
        point.likedBy = [point.likedBy setByAddingObject:user];
    } completion:^(BOOL success, NSError *error)    {
        block ([self getUserForId:globalUser.userId]);
    }];
}

/*
- (void)addSaveOperationToBottomInContext:(NSManagedObjectContext *)context {
    //NSLog(@"%@",[NSThread callStackSymbols]);
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if (context.hasChanges) {
            [context performBlockAndWait:^{
                [context saveWithErrorHandler];
            }];
        }
    }];
    operation.queuePriority = NSOperationQueuePriorityLow;
    [self.backgroundOperationQueue addOperation:operation];
}

- (void)returnObject:(NSManagedObject *)object inComplationBlock:(complationBlock)block {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSOperation *waitOperation = [NSBlockOperation blockOperationWithBlock:^{
            if (block) {
                if (!object.isFault) {
                    block([object moveToContext:[NSManagedObjectContext threadContext]]);
                }
                else {
                    //Object already deleted
                    block(nil);
                }
            }
        }];
        [[NSOperationQueue mainQueue] addOperations:@[waitOperation] waitUntilFinished:YES];
    }];
    operation.queuePriority = NSOperationQueuePriorityLow;
    [self.backgroundOperationQueue addOperation:operation];
}
*/

- (void) deleteAndSaveEntity:(NSManagedObject*) globalObject{
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        NSManagedObject* object = [globalObject MR_inContext:localContext];
        [object deleteInContext:localContext];
    } completion:^(BOOL success, NSError *error)    {
        
    }];
}


@end

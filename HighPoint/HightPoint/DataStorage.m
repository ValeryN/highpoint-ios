//
//  DataStorage.m
//  HightPoint
//
//  Created by Andrey Anisimov on 07.07.13.
//  Copyright (c) 2013 Andrey Anisimov. All rights reserved.
//

#import "DataStorage.h"
#import "HPAppDelegate.h"
#import "HPBaseNetworkManager.h"
#import "NSManagedObject+HighPoint.h"
#import "NSManagedObjectContext+HighPoint.h"
#import <objc/runtime.h>

static DataStorage *dataStorage;

@implementation DataStorage
+ (DataStorage *)sharedDataStorage {
    @synchronized (self) {
        static dispatch_once_t onceToken;
        if (!dataStorage) {
            dispatch_once(&onceToken, ^{
                dataStorage = [[DataStorage alloc] init];
                dataStorage.backgroundOperationQueue = [[NSOperationQueue alloc] init];
                dataStorage.backgroundOperationQueue.maxConcurrentOperationCount = 10;
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
            });
        }
        return dataStorage;
    }
}

- (void)createUser:(NSDictionary *)param {
    @throw [NSException exceptionWithName:@"ru.surfstudio.HighPoint.404" reason:@"Code not implemented" userInfo:param];
}

- (void)createUserInfo:(NSDictionary *)param {
    @throw [NSException exceptionWithName:@"ru.surfstudio.HighPoint.404" reason:@"Code not implemented" userInfo:param];
}

- (void)createUserSettings:(NSDictionary *)param {
    @throw [NSException exceptionWithName:@"ru.surfstudio.HighPoint.404" reason:@"Code not implemented" userInfo:param];
}


#pragma mark -
#pragma mark maxEntertimentPrice

- (MaxEntertainmentPrice *)createMaxPrice:(NSDictionary *)param {
    MaxEntertainmentPrice *maxP = (MaxEntertainmentPrice *) [NSEntityDescription insertNewObjectForEntityForName:@"MaxEntertainmentPrice" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    maxP.amount = param[@"amount"];
    maxP.currency = param[@"currency"];
    return maxP;
}

- (MinEntertainmentPrice *)createMinPrice:(NSDictionary *)param {
    MinEntertainmentPrice *minP = (MinEntertainmentPrice *) [NSEntityDescription insertNewObjectForEntityForName:@"MinEntertainmentPrice" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    minP.amount = param[@"amount"];
    minP.currency = param[@"currency"];
    return minP;
}

#pragma mark -
#pragma mark user filter

- (UserFilter *)createUserFilterEntity:(NSDictionary *)param {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    UserFilter *uf = [self getUserFilter];
    if (!uf) {
        uf = (UserFilter *) [NSEntityDescription insertNewObjectForEntityForName:@"UserFilter" inManagedObjectContext:context];
    }
    NSLog(@"filter params = %@", param);


    uf.maxAge = param[@"maxAge"];
    uf.minAge = param[@"minAge"];
    uf.viewType = param[@"viewType"];
    NSMutableArray *arr = [NSMutableArray new];
    for (NSNumber *p in param[@"genders"]) {
        Gender *gender = (Gender *) [NSEntityDescription insertNewObjectForEntityForName:@"Gender" inManagedObjectContext:context];
        gender.genderType = p;
        [arr addObject:gender];
    }
    NSString *cityIds = @"";
    NSArray *citiesArr = param[@"cityIds"];

    if ([param[@"cityIds"] isKindOfClass:[NSArray class]]) {
        for (NSUInteger i = 0; i < citiesArr.count; i++) {
            cityIds = [[cityIds stringByAppendingString:[citiesArr[i] stringValue]] stringByAppendingString:@","];
        }
        if ([cityIds length] > 0) {
            cityIds = [cityIds substringToIndex:[cityIds length] - 1];
        }
    } else {
        [[DataStorage sharedDataStorage] setAndSaveCityToUserFilter:nil];

    }
    uf.gender = [NSSet setWithArray:arr];
    NSLog(@"cityids = %@", cityIds);
    NSDictionary *params = @{@"cityIds" : cityIds, @"countryIds" : @"", @"regionIds" : @""};
    [[HPBaseNetworkManager sharedNetworkManager] getGeoLocation:params :2];
    return uf;
}

- (void)createAndSaveUserFilterEntity:(NSDictionary *)param withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block UserFilter *returnUf = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        returnUf = [weakSelf createUserFilterEntity:param];
        [[NSManagedObjectContext threadContext] saveWithErrorHandler];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnUf moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)setAndSaveCityToUserFilter:(City *)globalCity {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            City *city = [globalCity moveToContext:context];
            NSArray *fetchedObjects;
            NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter" inManagedObjectContext:context];
            [fetch setEntity:entityDescription];
            NSError *error = nil;
            fetchedObjects = [context executeFetchRequest:fetch error:&error];
            if ([fetchedObjects count] == 1) {
                UserFilter *filter = fetchedObjects[0];
                if (city) {
                    NSMutableSet *cities = [[NSMutableSet alloc] initWithSet:filter.city];
                    [cities addObject:city];
                    filter.city = cities;
                } else {
                    filter.city = nil;
                }
                [context saveWithErrorHandler];
            }
            if ([fetchedObjects count] > 1) {
                @throw [NSException exceptionWithName:@"ru.surfstudio.HighPoint.500" reason:@"Implicitly behavior!" userInfo:nil];
            }
        }];
    }];
}


- (void)removeAndSaveCitiesFromUserFilter {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            NSArray *fetchedObjects;
            NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter" inManagedObjectContext:context];
            [fetch setEntity:entityDescription];
            NSError *error = nil;
            fetchedObjects = [context executeFetchRequest:fetch error:&error];
            if ([fetchedObjects count] >= 1) {
                UserFilter *filter = fetchedObjects[0];
                filter.city = [[NSSet alloc] init];
                [context saveWithErrorHandler];
            }
        }];
    }];
}


- (UserFilter *)getUserFilter {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter" inManagedObjectContext:context];
    [fetch setEntity:entityDescription];
    NSError *error = nil;
    fetchedObjects = [context executeFetchRequest:fetch error:&error];
    if ([fetchedObjects count] >= 1) {
        return fetchedObjects[0];
    }
    else {
        return nil;
    }
}

- (void)removeAndSaveUserFilter {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            NSFetchRequest *allFilters = [[NSFetchRequest alloc] init];
            [allFilters setEntity:[NSEntityDescription entityForName:@"UserFilter" inManagedObjectContext:context]];
            [allFilters setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            NSError *error = nil;
            NSArray *filters = [context executeFetchRequest:allFilters error:&error];
            //error handling goes here
            for (NSManagedObject *filter in filters) {
                [context deleteObject:filter];
            }
            [context saveWithErrorHandler];
        }];
    }];
}

#pragma mark -
#pragma mark education entity

- (Education *)createEducationEntity:(NSDictionary *)param {
    Education *edu = (Education *) [NSEntityDescription insertNewObjectForEntityForName:@"Education" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    edu.id_ = param[@"id"];
    edu.fromYear = param[@"fromYear"];
    edu.schoolId = param[@"schoolId"];
    edu.specialityId = param[@"specialityId"];
    edu.toYear = param[@"toYear"];
    return edu;
}


- (void)addAndSaveEducationEntityForUser:(NSDictionary *)param {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Education *globalEd = [self createEducationEntity:param];
        User *globalCurrentUser = [self getCurrentUser];
        Education *ed = [globalEd moveToContext:context];
        User *currentUser = [globalCurrentUser moveToContext:context];
        NSMutableArray *education = [[currentUser.education allObjects] mutableCopy];
        if (education != nil) {
            [education addObject:ed];
        } else {
            education = [[NSMutableArray alloc] init];
        }
        [context performBlockAndWait:^{
            currentUser.education = [NSSet setWithArray:education];
            [context saveWithErrorHandler];
        }];
    }];
}


- (void)deleteAndSaveEducationEntityFromUser:(NSArray *)ids {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        User *globalCurrentUser = [self getCurrentUser];
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        User *currentUser = [globalCurrentUser moveToContext:context];
        NSMutableArray *educationItems = [[currentUser.education allObjects] mutableCopy];
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
        [context performBlockAndWait:^{
            currentUser.education = [NSSet setWithArray:educationItems];
            [context saveWithErrorHandler];
        }];
    }];
}


#pragma mark - language

- (Language *)createLanguageEntity:(NSDictionary *)param {
    Language *lan = (Language *) [NSEntityDescription insertNewObjectForEntityForName:@"Language" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    lan.id_ = param[@"id"];
    lan.name = param[@"name"];
    return lan;
}

- (void)addAndSaveLanguageEntityForUser:(NSDictionary *)param {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        Language *globalLan = [self createLanguageEntity:param];
        User *globalCurrentUser = [self getCurrentUser];
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Language *lan = [globalLan moveToContext:context];
        User *currentUser = [globalCurrentUser moveToContext:context];

        NSMutableArray *languages = [[currentUser.language allObjects] mutableCopy];
        if (languages != nil) {
            [languages addObject:lan];
        } else {
            languages = [[NSMutableArray alloc] init];
        }
        [context performBlockAndWait:^{
            currentUser.language = [NSSet setWithArray:languages];
            [context saveWithErrorHandler];
        }];
    }];
}


- (void)deleteAndSaveLanguageEntityFromUser:(NSArray *)ids {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        User *globalCurrentUser = [self getCurrentUser];
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        User *currentUser = [globalCurrentUser moveToContext:context];
        NSMutableArray *languageItems = [[currentUser.language allObjects] mutableCopy];
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
        [context performBlockAndWait:^{
            currentUser.language = [NSSet setWithArray:languageItems];
            [context saveWithErrorHandler];
        }];
    }];
}

- (Language *)createTempLanguage:(NSDictionary *)param {
    NSEntityDescription *myLanguageEntity = [NSEntityDescription entityForName:@"Language" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    Language *lanEnt = [[Language alloc] initWithEntity:myLanguageEntity insertIntoManagedObjectContext:nil];
    lanEnt.id_ = param[@"id"];
    lanEnt.name = param[@"name"];
    return lanEnt;
}

- (void)insertAndSaveLanguageObjectToContext:(Language *)globalLanguage withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block Language *returnLanguage = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Language *language = [globalLanguage moveToContext:context];
        Language *lanEnt = [weakSelf getLanguageById:language.id_];
        if (!lanEnt) {
            [context performBlockAndWait:^{
                [context insertObject:language];
                [context saveWithErrorHandler];
            }];
            returnLanguage = language;
        } else {
            returnLanguage = lanEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnLanguage moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removeLanguageObjectById:(Language *)language {
    Language *lanEnt = [self getLanguageById:language.id_];
    if (lanEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:lanEnt];
    }
}

- (Language *)getLanguageById:(NSNumber *)postId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Language" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", postId];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}


- (void)deleteAndSaveAllLanguages {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            NSFetchRequest *allLanguages = [[NSFetchRequest alloc] init];
            [allLanguages setEntity:[NSEntityDescription entityForName:@"Language" inManagedObjectContext:context]];
            [allLanguages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
            NSError *error = nil;
            NSArray *languages = [context executeFetchRequest:allLanguages error:&error];
            //error handling goes here
            for (Language *language in languages) {
                [context deleteObject:language];
            }
            [context saveWithErrorHandler];
        }];
    }];
}

#pragma mark - school

- (School *)createSchoolEntity:(NSDictionary *)param {
    School *sch = (School *) [NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    sch.id_ = param[@"id"];
    sch.name = param[@"name"];
    return sch;
}

- (School *)createTempSchool:(NSDictionary *)param {
    NSEntityDescription *mySchEntity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    School *schEnt = [[School alloc] initWithEntity:mySchEntity insertIntoManagedObjectContext:nil];
    schEnt.id_ = param[@"id"];
    schEnt.name = param[@"name"];
    return schEnt;
}

- (void)insertAndSaveSchoolObjectToContext:(School *)globalSchool withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block School *returnSchool = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        School *school = [globalSchool moveToContext:context];
        School *schEnt = [weakSelf getSchoolById:school.id_];
        if (!schEnt) {
            [context performBlockAndWait:^{
                [context insertObject:school];
                [context saveWithErrorHandler];
            }];
            returnSchool = school;
        } else {
            returnSchool = schEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnSchool moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removeSchoolObjectById:(School *)school {
    School *schEnt = [self getSchoolById:school.id_];
    if (schEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:schEnt];
    }
}

- (School *)getSchoolById:(NSNumber *)schoolId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", schoolId];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}

- (void)deleteAllSchools {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *allSchools = [[NSFetchRequest alloc] init];
    [allSchools setEntity:[NSEntityDescription entityForName:@"School" inManagedObjectContext:[NSManagedObjectContext threadContext]]];
    [allSchools setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error = nil;
    NSArray *schools = [context executeFetchRequest:allSchools error:&error];
    //error handling goes here
    for (School *sch in schools) {
        [context deleteObject:sch];
    }
}

#pragma mark - specialities

- (Speciality *)createSpecialityEntity:(NSDictionary *)param {
    Speciality *sp = (Speciality *) [NSEntityDescription insertNewObjectForEntityForName:@"Speciality" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    sp.id_ = param[@"id"];
    sp.name = param[@"name"];
    return sp;
}

- (Speciality *)createTempSpeciality:(NSDictionary *)param {
    NSEntityDescription *mySchEntity = [NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    Speciality *spEnt = [[Speciality alloc] initWithEntity:mySchEntity insertIntoManagedObjectContext:nil];
    spEnt.id_ = param[@"id"];
    spEnt.name = param[@"name"];
    return spEnt;
}

- (void)insertAndSaveSpecialityObjectToContext:(Speciality *)globalSpeciality withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block Speciality *returnSpeciality = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Speciality *speciality = [globalSpeciality moveToContext:context];
        Speciality *spEnt = [weakSelf getSpecialityById:speciality.id_];
        if (!spEnt) {
            [context performBlockAndWait:^{
                [context insertObject:speciality];
                [context saveWithErrorHandler];
            }];
            returnSpeciality = speciality;
        } else {
            returnSpeciality = spEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnSpeciality moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removeSpecialityObjectById:(Speciality *)speciality {
    Speciality *spEnt = [self getSpecialityById:speciality.id_];
    if (spEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:spEnt];
    }
}

- (Speciality *)getSpecialityById:(NSNumber *)specId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", specId];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}

- (void)deleteAllSpeciality {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *allSpec = [[NSFetchRequest alloc] init];
    [allSpec setEntity:[NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:context]];
    [allSpec setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error = nil;
    NSArray *specialities = [context executeFetchRequest:allSpec error:&error];
    //error handling goes here
    for (Speciality *sp in specialities) {
        [context deleteObject:sp];
    }
}


#pragma mark - place

- (Place *)createPlaceEntity:(NSDictionary *)param {
    Place *pl = (Place *) [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    pl.id_ = param[@"id"];
    pl.cityId = param[@"cityId"];
    pl.name = param[@"name"];
    return pl;
}

- (void)addAndSavePlaceEntityForUser:(NSDictionary *)param {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        Place *pl = [self createPlaceEntity:param];
        User *currentUser = [self getCurrentUser];

        NSMutableArray *places = [[currentUser.place allObjects] mutableCopy];
        if (places != nil) {
            [places addObject:pl];
        } else {
            places = [[NSMutableArray alloc] init];
        }
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            currentUser.place = [NSSet setWithArray:places];
            [context saveWithErrorHandler];
        }];
    }];
}

- (void)deleteAndSavePlaceEntityFromUser:(NSArray *)ids {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        User *currentUser = [self getCurrentUser];
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
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            currentUser.place = [NSSet setWithArray:placesItems];
            [context saveWithErrorHandler];
        }];
    }];
}

- (Place *)createTempPlace:(NSDictionary *)param {
    NSEntityDescription *myPlaceEntity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    Place *placeEnt = [[Place alloc] initWithEntity:myPlaceEntity insertIntoManagedObjectContext:nil];
    placeEnt.id_ = param[@"id"];
    placeEnt.cityId = param[@"cityId"];
    placeEnt.name = param[@"name"];
    return placeEnt;
}

- (void)insertAndSavePlaceObjectToContext:(Place *)globalPlace withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block Place *returnPlace = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Place *place = [globalPlace moveToContext:context];
        Place *placeEnt = [weakSelf getPlaceById:place.id_];
        if (!placeEnt) {
            [context performBlockAndWait:^{
                [context insertObject:place];
                [context saveWithErrorHandler];
            }];
            returnPlace = place;
        } else {
            returnPlace = placeEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnPlace moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removePlaceObjectById:(Place *)place {
    Place *plEnt = [self getPlaceById:place.id_];
    if (plEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:plEnt];
    }
}

- (Place *)getPlaceById:(NSNumber *)postId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", postId];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}


- (void)deleteAllPlaces {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *allPlaces = [[NSFetchRequest alloc] init];
    [allPlaces setEntity:[NSEntityDescription entityForName:@"Place" inManagedObjectContext:context]];
    [allPlaces setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:allPlaces error:&error];
    //error handling goes here
    for (Place *place in places) {
        [context deleteObject:place];
    }
}

#pragma mark -
#pragma mark career entity

- (Career *)createCareerEntity:(NSDictionary *)param {
    Career *car = (Career *) [NSEntityDescription insertNewObjectForEntityForName:@"Career" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    car.id_ = param[@"id"];
    car.fromYear = param[@"fromYear"];
    car.companyId = param[@"companyId"];
    car.postId = param[@"postId"];
    car.toYear = param[@"toYear"];
    return car;
}


- (void)addAndSaveCareerEntityForUser:(NSDictionary *)param {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        Career *ca = [self createCareerEntity:param];
        User *currentUser = [self getCurrentUser];
        NSMutableArray *careerItems = [[currentUser.career allObjects] mutableCopy];
        if (careerItems != nil) {
            [careerItems addObject:ca];
        } else {
            careerItems = [[NSMutableArray alloc] init];
        }

        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            currentUser.career = [NSSet setWithArray:careerItems];
            [context saveWithErrorHandler];
        }];
    }];
}

- (void)deleteAndSaveCareerEntityFromUser:(NSArray *)ids {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        User *currentUser = [self getCurrentUser];
        NSMutableArray *careerItems = [[currentUser.career allObjects] mutableCopy];
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
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            currentUser.career = [NSSet setWithArray:careerItems];
            [context saveWithErrorHandler];
        }];
    }];
}


#pragma mark - career-post

- (void)createAndSaveCareerPost:(NSDictionary *)param withComplation:(complationBlock)block {
    __block CareerPost *returCpost = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            CareerPost *postEnt = (CareerPost *) [NSEntityDescription insertNewObjectForEntityForName:@"CareerPost" inManagedObjectContext:context];
            postEnt.name = param[@"name"];
            postEnt.id_ = param[@"id"];
            [context saveWithErrorHandler];
            returCpost = postEnt;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block)
                    block([returCpost moveToContext:[NSManagedObjectContext threadContext]]);
            }];
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (CareerPost *)createTempCareerPost:(NSDictionary *)param {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSEntityDescription *myCareerPostEntity = [NSEntityDescription entityForName:@"CareerPost" inManagedObjectContext:context];
    CareerPost *postEnt = [[CareerPost alloc] initWithEntity:myCareerPostEntity insertIntoManagedObjectContext:nil];
    postEnt.id_ = param[@"id"];
    postEnt.name = param[@"name"];
    return postEnt;
}

- (void)insertAndSaveCareerPostObjectToContext:(CareerPost *)globalcPost withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block CareerPost *returnPost = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        CareerPost *cPost = [globalcPost moveToContext:context];
        CareerPost *postEnt = [weakSelf getCareerPostById:cPost.id_];
        if (!postEnt) {
            [context performBlockAndWait:^{
                [context insertObject:cPost];
                [context saveWithErrorHandler];
            }];
            returnPost = cPost;
        } else {
            returnPost = postEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnPost moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removeCareerPostObjectById:(CareerPost *)cPost {
    CareerPost *postEnt = [self getCareerPostById:cPost.id_];
    if (postEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:postEnt];
    }
}

- (CareerPost *)getCareerPostById:(NSNumber *)postId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CareerPost" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", postId];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}


- (void)deleteAllCareerPosts {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *allCareerPosts = [[NSFetchRequest alloc] init];
    [allCareerPosts setEntity:[NSEntityDescription entityForName:@"CareerPost" inManagedObjectContext:context]];
    [allCareerPosts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error = nil;
    NSArray *cPosts = [context executeFetchRequest:allCareerPosts error:&error];
    //error handling goes here
    for (CareerPost *post in cPosts) {
        [context deleteObject:post];
    }
}


#pragma mark - company

- (void)createAndSaveCompany:(NSDictionary *)param withComplation:(complationBlock)block {
    __block Company *returnCompany = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            Company *companyEnt = (Company *) [NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:context];
            companyEnt.name = param[@"name"];
            companyEnt.id_ = param[@"id"];
            [context saveWithErrorHandler];
            returnCompany = companyEnt;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block)
                    block([returnCompany moveToContext:[NSManagedObjectContext threadContext]]);
            }];
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (Company *)createTempCompany:(NSDictionary *)param {
    NSEntityDescription *myCompanyEntity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    Company *companyEnt = [[Company alloc] initWithEntity:myCompanyEntity insertIntoManagedObjectContext:nil];
    companyEnt.id_ = param[@"id"];
    companyEnt.name = param[@"name"];
    return companyEnt;
}

- (void)insertAndSaveCompanyObjectToContext:(Company *)globalCompany withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block Company *returnCompany = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Company *company = [globalCompany moveToContext:context];
        Company *companyEnt = [weakSelf getCompanyById:company.id_];
        if (!companyEnt) {
            [context performBlockAndWait:^{
                [context insertObject:company];
                [context saveWithErrorHandler];
            }];
            returnCompany = company;
        } else {
            returnCompany = companyEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnCompany moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removeCompanyObjectById:(Company *)company {
    Company *companyEnt = [self getCompanyById:company.id_];
    if (companyEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:companyEnt];
    }
}

- (Company *)getCompanyById:(NSNumber *)companyId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", companyId];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}

- (void)deleteCompanyPosts {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *allCompanies = [[NSFetchRequest alloc] init];
    [allCompanies setEntity:[NSEntityDescription entityForName:@"Company" inManagedObjectContext:context]];
    [allCompanies setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error = nil;
    NSArray *companies = [context executeFetchRequest:allCompanies error:&error];
    //error handling goes here
    for (Company *comp in companies) {
        [context deleteObject:comp];
    }
}


#pragma mark -
#pragma mark avatar entity

- (Avatar *)createAvatarEntity:(NSDictionary *)param {
    Avatar *avatar = (Avatar *) [NSEntityDescription insertNewObjectForEntityForName:@"Avatar" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    avatar.highCrop = param[@"highCrop"];
    avatar.highImageSrc = [param[@"highImage"] objectForKey:@"src"];
    avatar.highImageHeight = [param[@"highImage"] objectForKey:@"height"];
    avatar.highImageWidth = [param[@"highImage"] objectForKey:@"width"];
    avatar.squareCrop = param[@"squareCrop"];
    avatar.originalImageSrc = [param[@"originalImage"] objectForKey:@"src"];
    avatar.originalImageHeight = [param[@"originalImage"] objectForKey:@"height"];
    avatar.originalImageWidth = [param[@"originalImage"] objectForKey:@"width"];
    avatar.squareImageSrc = [param[@"squareImage"] objectForKey:@"src"];
    avatar.squareImageHeight = [param[@"squarelImage"] objectForKey:@"height"];
    avatar.squareImageWidth = [param[@"squareImage"] objectForKey:@"width"];
    return avatar;
}

#pragma mark -
#pragma mark current user entity


- (void)createAndSaveUserEntity:(NSDictionary *)param isCurrent:(BOOL)current withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        User *returnUser = nil;
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        User *user;
        user = [weakSelf getUserForId:param[@"id"]];
        if (!user) {
            user = (User *) [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            [context insertObject:user];
        }
        user.isCurrentUser = @(current);
        if (param[@"name"])
            user.name = param[@"name"];
        if (param[@"id"])
            user.userId = param[@"id"];
        if (param[@"cityId"])
            user.cityId = param[@"cityId"];
        if (param[@"createdAt"])
            user.createdAt = param[@"createdAt"];
        if (param[@"dateOfBirth"])
            user.dateOfBirth = param[@"dateOfBirth"];
        if (param[@"email"])
            user.email = param[@"email"];
        if (param[@"gender"])
            user.gender = param[@"gender"];
        if (param[@"visibility"])
            user.visibility = param[@"visibility"];
        if (param[@"avatar"]) {
            user.avatar = [weakSelf createAvatarEntity:param[@"avatar"]];
            user.avatar.user = user;
        }
        if (param[@"age"])
            user.age = param[@"age"];
        if ([param[@"education"] isKindOfClass:[NSDictionary class]]) {

            if (![param[@"education"] isKindOfClass:[NSNull class]]) {
                Education *ed = [weakSelf createEducationEntity:param[@"education"]];
                ed.user = user;
                user.education = [NSSet setWithArray:@[ed]];
            }

        } else if ([param[@"education"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *entArray = [NSMutableArray new];
            for (NSDictionary *t in param[@"education"]) {
                Education *ed = [weakSelf createEducationEntity:t];
                ed.user = user;
                [entArray addObject:[weakSelf createEducationEntity:t]];
            }
            user.education = [NSSet setWithArray:entArray];
        }

        if ([param[@"career"] isKindOfClass:[NSDictionary class]]) {

            if (![param[@"career"] isKindOfClass:[NSNull class]]) {
                Career *ca = [weakSelf createCareerEntity:param[@"career"]];
                ca.user = user;
                user.career = [NSSet setWithArray:@[ca]];
            }

        } else if ([param[@"career"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *entArray = [NSMutableArray new];
            for (NSDictionary *t in param[@"career"]) {
                Career *ca = [weakSelf createCareerEntity:t];
                ca.user = user;
                [entArray addObject:[weakSelf createCareerEntity:t]];
            }
            user.career = [NSSet setWithArray:entArray];
        }

        if ([param[@"languageIds"] isKindOfClass:[NSDictionary class]]) {
            if (![param[@"languageIds"] isKindOfClass:[NSNull class]]) {
                Language *lan = [weakSelf createLanguageEntity:param[@"language"]];
                lan.user = user;
                user.language = [NSSet setWithArray:@[lan]];
            }
        } else if ([param[@"languageIds"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *entArray = [NSMutableArray new];
            for (NSDictionary *t in param[@"career"]) {
                Language *lan = [weakSelf createLanguageEntity:t];
                lan.user = user;
                [entArray addObject:[weakSelf createLanguageEntity:t]];
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
        if (current) {
            if (![param[@"filter"] isKindOfClass:[NSNull class]]) {
                UserFilter *uf = [weakSelf createUserFilterEntity:param[@"filter"]];
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
        //id y = [param objectForKey:@"maxEntertainmentPrice"];
        if (![param[@"maxEntertainmentPrice"] isKindOfClass:[NSNull class]]) {
            MaxEntertainmentPrice *mxP = [weakSelf createMaxPrice:param[@"maxEntertainmentPrice"]];
            mxP.user = user;
            user.maxentertainment = mxP;
        }
        if (![param[@"minEntertainmentPrice"] isKindOfClass:[NSNull class]]) {
            MinEntertainmentPrice *mnP = [weakSelf createMinPrice:param[@"minEntertainmentPrice"]];
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
        user.point = [[DataStorage sharedDataStorage] getPointForUserId:user.userId];
        NSLog(@"saved point text %@", user.point.pointText);


        if (current) {
            NSDictionary *params = @{@"cityIds" : user.cityId, @"countryIds" : @"", @"regionIds" : @""};
            [[HPBaseNetworkManager sharedNetworkManager] getGeoLocation:params :1];
        }

        returnUser = user;
        [context saveWithErrorHandler];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnUser moveToContext:[NSManagedObjectContext threadContext]]);
        }];

    }];

    [self.backgroundOperationQueue addOperation:operation];
}

- (User *)getCurrentUser {
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

    if ([array count] > 0)
        return array[0];
    else return nil;
}

- (void)deleteAndSaveCurrentUser {
    [self.backgroundOperationQueue addOperationWithBlock:^{
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
            return;
        }


        NSError *error = nil;
        [request setFetchLimit:1];
        NSArray *array = [context executeFetchRequest:request error:&error];

        if ([array count] > 0) {
            User *current = array[0];
            [context deleteObject:current];
            [context saveWithErrorHandler];
            return;
        } else {
            return;
        }
    }];
}


- (User *)getUserForId:(NSNumber *)id_ {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"userId  = %d", [id_ intValue]];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}

#pragma mark -
#pragma mark pointEntity

- (void)createAndSavePoint:(NSDictionary *)param {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        __block UserPoint *userPoint;
        userPoint = [self getPointForId:param[@"id"]];
        [context performBlockAndWait:^{
            if (!userPoint) {
                userPoint = (UserPoint *) [NSEntityDescription insertNewObjectForEntityForName:@"UserPoint" inManagedObjectContext:context];

                if (param[@"id"])
                    userPoint.pointId = param[@"id"];
                userPoint.pointCreatedAt = param[@"createdAt"];
                userPoint.pointLiked = param[@"liked"];
                userPoint.pointText = param[@"text"];
                userPoint.pointUserId = param[@"userId"];
                userPoint.pointValidTo = param[@"validTo"];
                [context saveWithErrorHandler];
            }
        }];
    }];
}

- (UserPoint *)getPointForUserId:(NSNumber *)userId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserPoint" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointUserId  = %d", [userId intValue]];

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

    if ([array count] > 0)
        return array[0];
    else return nil;

}

- (UserPoint *)getPointForId:(NSNumber *)id_ {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserPoint" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointId  = %d", [id_ intValue]];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}


- (void)setAndSavePointLiked:(NSNumber *)pointId :(BOOL)isLiked {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserPoint" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointId  = %d", [pointId intValue]];

    @try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        return;
    }


    NSError *error = nil;
    [request setFetchLimit:1];
    NSArray *array = [context executeFetchRequest:request error:&error];

    if ([array count] > 0) {
        UserPoint *globalPoint = array[0];
        [self.backgroundOperationQueue addOperationWithBlock:^{
            NSManagedObjectContext *backgroundContext = [NSManagedObjectContext threadContext];
            [backgroundContext performBlockAndWait:^{
                UserPoint *point = [globalPoint moveToContext:backgroundContext];
                point.pointLiked = @(isLiked);
                [backgroundContext saveWithErrorHandler];
            }];
        }];
        return;
    } else {
        return;
    }
}

#pragma mark -
#pragma mark application settings entity

- (void)createAndSaveApplicationSettingEntity:(NSDictionary *)param {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [self deleteAppSettings];
        [context performBlockAndWait:^{
            AppSetting *settings = (AppSetting *) [NSEntityDescription insertNewObjectForEntityForName:@"AppSetting" inManagedObjectContext:context];
            settings.avatarMaxFileSize = [param[@"avatar"] objectForKey:@"maxFileSize"];
            if ([[param[@"avatar"] objectForKey:@"minImageSize"] isKindOfClass:[NSArray class]]) {
                if ([[param[@"avatar"] objectForKey:@"minImageSize"] count] == 2) {
                    settings.avatarMinImageWidth = [[param[@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:0];//minImageSize
                    settings.avatarMinImageHeight = [[param[@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:1];
                }
            }
            settings.pointMaxPeriod = [param[@"point"] objectForKey:@"maxPeriod"];
            settings.pointMinPeriod = [param[@"point"] objectForKey:@"minPeriod"];
            if ([param[@"webSocketUrls"] isKindOfClass:[NSArray class]]) {
                if ([param[@"webSocketUrls"] count] == 1)
                    settings.webSoketUrl = [param[@"webSocketUrls"] objectAtIndex:0];
            }
            //settings.webSoketUrl = [param objectForKey:@"webSocketUrls"];
            [context saveWithErrorHandler];
        }];
    }];
}

- (void)deleteAppSettings {
    NSArray *temp = [[self applicationSettingFetchResultsController] fetchedObjects];
    for (AppSetting *t in temp) {
        [[NSManagedObjectContext threadContext] deleteObject:t];
    }
}

- (AppSetting *)getAppSettings {
    NSArray *temp = [[self applicationSettingFetchResultsController] fetchedObjects];
    if (temp.count > 0)
        return temp[0];
    else return nil;
}

#pragma mark - users

- (NSFetchedResultsController *)allUsersFetchResultsController {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isCurrentUser != 1"];

    @try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        return nil;
    }


    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        return nil;
    }
    return controller;

}

- (NSFetchedResultsController *)allUsersWithPointFetchResultsController {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"point != nil AND isCurrentUser != 1"];

    @try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        return nil;
    }


    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        return nil;
    }
    return controller;

}


- (NSFetchedResultsController *)applicationSettingFetchResultsController {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppSetting" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"avatarMaxFileSize" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        return nil;
    }
    return controller;
}

- (void)setAndSaveCityToUser:(NSNumber *)userId :(City *)city {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        User *user = [self getUserForId:userId];
        if (user) {
            [context performBlockAndWait:^{
                user.city = [city moveToContext:context];
                [context saveWithErrorHandler];
            }];
        }
    }];
}


#pragma mark - city

- (void)createAndSaveCity:(NSDictionary *)param withComplation:(complationBlock)block {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            City *returnCity = nil;
            City *cityEnt = (City *) [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:context];
            cityEnt.cityEnName = param[@"enName"];
            cityEnt.cityId = param[@"id"];
            cityEnt.cityName = param[@"name"];
            cityEnt.cityNameForms = param[@"nameForms"];
            cityEnt.cityRegionId = param[@"regionId"];
            [context saveWithErrorHandler];
            returnCity = cityEnt;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(returnCity);
                }
            });
        }];
    }];

    [self.backgroundOperationQueue addOperation:operation];
}

- (City *)createTempCity:(NSDictionary *)param {
    NSEntityDescription *myCityEntity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:[NSManagedObjectContext threadContext]];
    City *cityEnt = [[City alloc] initWithEntity:myCityEntity insertIntoManagedObjectContext:nil];
    cityEnt.cityEnName = param[@"enName"];
    cityEnt.cityId = param[@"id"];
    cityEnt.cityName = param[@"name"];
    cityEnt.cityNameForms = param[@"nameForms"];
    cityEnt.cityRegionId = param[@"regionId"];
    return cityEnt;
}

- (void)insertAndSaveCityObjectToContext:(City *)globalCity withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block City *returnCity = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        City *city = [globalCity moveToContext:context];
        City *cityEnt = [weakSelf getCityById:city.cityId];
        if (!cityEnt) {
            [context performBlockAndWait:^{
                [context insertObject:city];
                [context saveWithErrorHandler];
            }];
            returnCity = city;
        } else {
            returnCity = cityEnt;
        }
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (block)
                block([returnCity moveToContext:[NSManagedObjectContext threadContext]]);
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (void)removeCityObjectById:(City *)city {
    City *cityEnt = [self getCityById:city.cityId];
    if (cityEnt) {
        [[NSManagedObjectContext threadContext] deleteObject:cityEnt];
    }
}

- (City *)getCityById:(NSNumber *)cityId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"cityId  = %@", cityId];

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

    if ([array count] > 0) {
        return array[0];
    } else {
        return nil;
    }
}


- (void)deleteAllCities {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *allCities = [[NSFetchRequest alloc] init];
    [allCities setEntity:[NSEntityDescription entityForName:@"City" inManagedObjectContext:context]];
    [allCities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError *error = nil;
    NSArray *cities = [context executeFetchRequest:allCities error:&error];
    //error handling goes here
    for (City *city in cities) {
        [context deleteObject:city];
    }
}

#pragma mark - contacts


- (void)createAndSaveContactEntity:(User *)glovaluser :(LastMessage *)globallastMessage withComplation:(complationBlock)block {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            Contact *contactEnt = (Contact *) [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:context];
            contactEnt.lastmessage = [globallastMessage moveToContext:context];
            contactEnt.user = [glovaluser moveToContext:context];
            [context saveWithErrorHandler];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block)
                    block([contactEnt moveToContext:[NSManagedObjectContext threadContext]]);
            }];
        }];

    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}


- (void)deleteAndSaveAllContacts {
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            NSFetchRequest *allContacts = [[NSFetchRequest alloc] init];
            [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context]];
            [allContacts setIncludesPropertyValues:NO];
            NSError *error = nil;
            NSArray *contacts = [context executeFetchRequest:allContacts error:&error];
            //error handling goes here
            for (Contact *cont in contacts) {
                [context deleteObject:cont];
            }
            [context saveWithErrorHandler];
        }];
    }];
    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (NSFetchedResultsController *)getAllContactsFetchResultsController {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        return nil;
    }
    return controller;

}


- (Contact *)getContactById:(NSNumber *)contactId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.userId  = %d", [contactId intValue]];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}

- (void)deleteAndSaveContact:(NSNumber *)contactId {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Contact *contact = [self getContactById:contactId];
        if (contact) {
            [context performBlockAndWait:^{
                [context deleteObject:contact];
                [context saveWithErrorHandler];
            }];
        }
    }];
}

- (NSFetchedResultsController *)getContactsByQueryFetchResultsController:(NSString *)queryStr {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.name contains[c] '%@' OR user.age == '%@' OR user.city.cityName contains[c] '%@'", queryStr, queryStr, queryStr];

    @try {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        return nil;
    }


    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    if (![controller performFetch:&error]) {
        return nil;
    }
    return controller;

}


#pragma mark - last message

- (void)createAndSaveLastMessage:(NSDictionary *)param :(int)keyId withComplation:(complationBlock)block {
    __block LastMessage *returnMessage = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
        [context performBlockAndWait:^{
            LastMessage *lastMsgEnt = (LastMessage *) [NSEntityDescription insertNewObjectForEntityForName:@"LastMessage" inManagedObjectContext:context];
            lastMsgEnt.userId = @(keyId);
            lastMsgEnt.id_ = param[@"id"];
            lastMsgEnt.createdAt = [df dateFromString:param[@"createdAt"]];
            lastMsgEnt.destinationId = param[@"destinationId"];
            lastMsgEnt.readAt = [df dateFromString:param[@"readAt"]];
            lastMsgEnt.sourceId = param[@"sourceId"];
            lastMsgEnt.text = param[@"text"];
            [context saveWithErrorHandler];
            returnMessage = lastMsgEnt;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block)
                    block([returnMessage moveToContext:[NSManagedObjectContext threadContext]]);
            }];
        }];
    }];


    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

#pragma mark - chat

- (void)createAndSaveChatEntity:(User *)globalUser :(NSArray *)messages withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block Chat *returnChat = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            User *user = [globalUser moveToContext:context];
            Chat *chatEnt = (Chat *) [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:context];
            chatEnt.user = user;
            NSMutableArray *entArray = [NSMutableArray new];
            for (NSDictionary *t in messages) {
                Message *msg = [weakSelf createMessage:t :user.userId];
                msg.chat = chatEnt;
                [entArray addObject:msg];
            }
            chatEnt.message = [NSSet setWithArray:entArray];
            [context saveWithErrorHandler];
            returnChat = chatEnt;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block)
                    block([returnChat moveToContext:[NSManagedObjectContext threadContext]]);
            }];
        }];
    }];


    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}

- (Chat *)getChatByUserId:(NSNumber *)userId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:context];
    [request setEntity:entity];
    NSMutableArray *sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString *predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.userId  = %d", [userId intValue]];

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

    if ([array count] > 0)
        return array[0];
    else return nil;
}


- (void)deleteAndSaveChatByUserId:(NSNumber *)userId {
    [self.backgroundOperationQueue addOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        Chat *chat = [self getChatByUserId:userId];
        if (chat) {
            [context performBlockAndWait:^{
                [context deleteObject:chat];
                [context saveWithErrorHandler];
            }];
        }
    }];
}

#pragma mark - messages

- (Message*)createMessage:(NSDictionary *)param :(NSNumber *)userId {
    NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
    Message *msgEnt = (Message *) [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    msgEnt.bindedUserId = userId;
    msgEnt.id_ = param[@"id"];
    msgEnt.createdAt = [df dateFromString:param[@"createdAt"]];
    msgEnt.destinationId = param[@"destinationId"];
    msgEnt.readAt = [df dateFromString:param[@"readAt"]];
    msgEnt.sourceId = param[@"sourceId"];
    msgEnt.text = param[@"text"];
    return msgEnt;
}

- (void)createAndSaveMessage:(NSDictionary *)param :(NSNumber *)userId withComplation:(complationBlock)block {
    __weak typeof(self) weakSelf = self;
    __block Message *returnMessage = nil;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *context = [NSManagedObjectContext threadContext];
        [context performBlockAndWait:^{
            returnMessage = [weakSelf createMessage:param :userId];
            [context saveWithErrorHandler];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (block)
                    block([returnMessage moveToContext:[NSManagedObjectContext threadContext]]);
            }];
        }];
    }];

    [self.backgroundOperationQueue addOperations:@[operation] waitUntilFinished:NO];
}


#pragma mark - Deprecated


- (void)saveContext {
    @throw [NSException exceptionWithName:@"deprecated" reason:@"Deprecated" userInfo:nil];
}

- (NSManagedObjectContext *)moc {
    @throw [NSException exceptionWithName:@"deprecated" reason:@"Deprecated" userInfo:nil];
    return nil;
}

@end

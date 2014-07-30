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
#import "NotificationsConstants.h"

static DataStorage *dataStorage;
@implementation DataStorage
+(DataStorage*) sharedDataStorage{
    @synchronized (self){
        static dispatch_once_t onceToken;
        if (!dataStorage){
            dispatch_once(&onceToken, ^{
                dataStorage = [[DataStorage alloc] init];
                dataStorage.moc = ((HPAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
            });
        }
        return dataStorage;
    }
}

#pragma mark -
#pragma mark maxEntertimentPrice
- (MaxEntertainmentPrice*) createMaxPrice:(NSDictionary *)param {
    MaxEntertainmentPrice *maxP = (MaxEntertainmentPrice*)[NSEntityDescription insertNewObjectForEntityForName:@"MaxEntertainmentPrice" inManagedObjectContext:self.moc];
    maxP.amount = [param objectForKey:@"amount"];
    maxP.currency = [param objectForKey:@"currency"];
    return maxP;
}
- (MinEntertainmentPrice*) createMinPrice:(NSDictionary *)param {
    MinEntertainmentPrice *minP = (MinEntertainmentPrice*)[NSEntityDescription insertNewObjectForEntityForName:@"MinEntertainmentPrice" inManagedObjectContext:self.moc];
    minP.amount = [param objectForKey:@"amount"];
    minP.currency = [param objectForKey:@"currency"];
    return minP;
}
#pragma mark -
#pragma mark user filter
- (UserFilter*) createUserFilterEntity:(NSDictionary *)param {
    UserFilter *uf = [self getUserFilter];
    if (!uf) {
        uf = (UserFilter*)[NSEntityDescription insertNewObjectForEntityForName:@"UserFilter" inManagedObjectContext:self.moc];
    }
    uf.maxAge = [param objectForKey:@"maxAge"];
    uf.minAge = [param objectForKey:@"minAge"];
    uf.viewType = [param objectForKey:@"viewType"];
    NSMutableArray *arr = [NSMutableArray new];
    for(NSNumber *p in [param objectForKey:@"genders"]) {
        Gender *gender = (Gender*)[NSEntityDescription insertNewObjectForEntityForName:@"Gender" inManagedObjectContext:self.moc];
        gender.genderType = p;
        [arr addObject:gender];
    }
    NSString *cityIds = @"";
    NSArray *citiesArr = [param objectForKey:@"cityIds"];
    
    if ( [[param objectForKey:@"cityIds"] isKindOfClass: [NSArray class]]) {
        for (int i = 0; i < citiesArr.count; i++) {
                cityIds = [[cityIds stringByAppendingString:[[citiesArr objectAtIndex:i] stringValue]] stringByAppendingString:@","];
        }
        if ([cityIds length] > 0) {
            cityIds = [cityIds substringToIndex:[cityIds length] - 1];
        }
    }
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:cityIds, @"cityIds",@"",@"countryIds",@"",@"regionIds", nil];
    [[HPBaseNetworkManager sharedNetworkManager] getGeoLocation:params];
    uf.gender = [NSSet setWithArray:arr];
    [self saveContext];
    return uf;
}

- (void) setCityToUserFilter :(City *) city {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter"  inManagedObjectContext: self.moc];
    [fetch setEntity:entityDescription];
    NSError * error = nil;
    fetchedObjects = [self.moc executeFetchRequest:fetch error:&error];
    if([fetchedObjects count] == 1) {
        UserFilter *filter = [fetchedObjects objectAtIndex:0];
        NSMutableSet *cities = [[NSMutableSet alloc] initWithSet:filter.city];
        [cities addObject:city];
        filter.city = cities;
        [self saveContext];
        return;
    } else {
        return;
    }
}


- (void) removeCitiesFromUserFilter {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter"  inManagedObjectContext: self.moc];
    [fetch setEntity:entityDescription];
    NSError * error = nil;
    fetchedObjects = [self.moc executeFetchRequest:fetch error:&error];
    if([fetchedObjects count] >= 1) {
        UserFilter *filter = [fetchedObjects objectAtIndex:0];
        filter.city = [[NSSet alloc] init];
        [self saveContext];
        return;
    } else {
        return;
    }
}



- (UserFilter*) getUserFilter {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter"  inManagedObjectContext: self.moc];
    [fetch setEntity:entityDescription];
    NSError * error = nil;
    fetchedObjects = [self.moc executeFetchRequest:fetch error:&error];
    if([fetchedObjects count] >= 1) {
        return [fetchedObjects objectAtIndex:0];
    }
    else {
        return nil;
    }
}

- (void) deleteUserFilter {
    NSFetchRequest * allFilters = [[NSFetchRequest alloc] init];
    [allFilters setEntity:[NSEntityDescription entityForName:@"UserFilter" inManagedObjectContext:self.moc]];
    [allFilters setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * filters = [self.moc executeFetchRequest:allFilters error:&error];
    //error handling goes here
    for (NSManagedObject * filter in filters) {
        [self.moc deleteObject:filter];
    }
    [self saveContext];
}

#pragma mark -
#pragma mark education entity
- (Education*) createEducationEntity:(NSDictionary *)param {
    Education *edu = (Education*)[NSEntityDescription insertNewObjectForEntityForName:@"Education" inManagedObjectContext:self.moc];
    edu.id_ = [param objectForKey:@"id"];
    edu.fromYear = [param objectForKey:@"fromYear"];
    edu.schoolId = [param objectForKey:@"schoolId"];
    edu.specialityId = [param objectForKey:@"specialityId"];
    edu.toYear = [param objectForKey:@"toYear"];
    return edu;
}


- (void) addLEducationEntityForUser :(NSDictionary *) param {
    Education *ed = [self createEducationEntity: param];
    User *currentUser = [self getCurrentUser];
    
    NSMutableArray *education = [[currentUser.education allObjects] mutableCopy];
    if (education != nil) {
        [education addObject:ed];
    } else {
        education = [[NSMutableArray alloc] init];
    }
    currentUser.education = [NSSet setWithArray:education];
    [self saveContext];
}


- (void) deleteEducationEntityFromUser :(NSArray *) ids {
    User *currentUser = [self getCurrentUser];
    NSMutableArray *educationItems = [[currentUser.education allObjects] mutableCopy];
    NSMutableArray *discardedItems = [NSMutableArray array];
    Education *item;
    for (item in educationItems) {
        for (int i = 0; i < ids.count; i++) {
            if ([item.id_ intValue] == [[ids objectAtIndex:i] intValue]) {
                [discardedItems addObject:item];
            }
        }
    }
    [educationItems removeObjectsInArray:discardedItems];
    currentUser.education = [NSSet setWithArray:educationItems];
    [self saveContext];
}


#pragma mark - language

- (Language *) createLanguageEntity:(NSDictionary *)param {
    Language *lan = (Language*)[NSEntityDescription insertNewObjectForEntityForName:@"Language" inManagedObjectContext:self.moc];
    lan.id_ = [param objectForKey:@"id"];
    lan.name = [param objectForKey:@"name"];
    return lan;
}

- (void) addLanguageEntityForUser :(NSDictionary *) param {
    Language *lan = [self createLanguageEntity: param];
    User *currentUser = [self getCurrentUser];
    
    NSMutableArray *languages = [[currentUser.language allObjects] mutableCopy];
    if (languages != nil) {
        [languages addObject:lan];
    } else {
        languages = [[NSMutableArray alloc] init];
    }
    currentUser.language = [NSSet setWithArray:languages];
    [self saveContext];
}


- (void) deleteLanguageEntityFromUser :(NSArray *) ids {
    User *currentUser = [self getCurrentUser];
    NSMutableArray *languageItems = [[currentUser.language allObjects] mutableCopy];
    NSMutableArray *discardedItems = [NSMutableArray array];
    Language *item;
    for (item in languageItems) {
        for (int i = 0; i < ids.count; i++) {
            if ([item.id_ intValue] == [[ids objectAtIndex:i] intValue]) {
                [discardedItems addObject:item];
            }
        }
    }
    [languageItems removeObjectsInArray:discardedItems];
    currentUser.language = [NSSet setWithArray:languageItems];
    [self saveContext];
}

- (Language *) createTempLanguage :(NSDictionary *) param {
    NSEntityDescription *myLanguageEntity = [NSEntityDescription entityForName:@"Language" inManagedObjectContext:self.moc];
    Language *lanEnt = [[Language alloc] initWithEntity:myLanguageEntity insertIntoManagedObjectContext:nil];
    lanEnt.id_ = [param objectForKey:@"id"];
    lanEnt.name = [param objectForKey:@"name"];
    return lanEnt;
}

- (Language *) insertLanguageObjectToContext: (Language *) language {
    Language *lanEnt = [self getLanguageById:language.id_];
    if (!lanEnt) {
        [self.moc insertObject:language];
        [self saveContext];
        return language;
    } else {
        return lanEnt;
    }
}

- (void) removeLanguageObjectById : (Language *)language {
    Language *lanEnt = [self getLanguageById:language.id_];
    if (lanEnt) {
        [self.moc deleteObject:lanEnt];
    }
}

- (Language *) getLanguageById : (NSNumber *) postId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Language" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@",postId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}


- (void) deleteAllLanguages {
    NSFetchRequest * allLanguages = [[NSFetchRequest alloc] init];
    [allLanguages setEntity:[NSEntityDescription entityForName:@"Language" inManagedObjectContext:self.moc]];
    [allLanguages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * languages = [self.moc executeFetchRequest:allLanguages error:&error];
    //error handling goes here
    for (Language *language in languages) {
        [self.moc deleteObject:language];
    }
}

#pragma mark - school

- (School *) createSchoolEntity:(NSDictionary *)param {
    School *sch = (School*)[NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:self.moc];
    sch.id_ = [param objectForKey:@"id"];
    sch.name = [param objectForKey:@"name"];
    return sch;
}

- (School *) createTempSchool :(NSDictionary *) param {
    NSEntityDescription *mySchEntity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:self.moc];
    School *schEnt = [[School alloc] initWithEntity:mySchEntity insertIntoManagedObjectContext:nil];
    schEnt.id_ = [param objectForKey:@"id"];
    schEnt.name = [param objectForKey:@"name"];
    return schEnt;
}

- (School *) insertSchoolObjectToContext: (School *) school {
    School *schEnt = [self getSchoolById:school.id_];
    if (!schEnt) {
        [self.moc insertObject:school];
        [self saveContext];
        return school;
    } else {
        return schEnt;
    }
}

- (void) removeSchoolObjectById : (School *)school {
    School *schEnt = [self getSchoolById:school.id_];
    if (schEnt) {
        [self.moc deleteObject:schEnt];
    }
}

- (School *) getSchoolById : (NSNumber *) schoolId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"School" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", schoolId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void) deleteAllSchools {
    NSFetchRequest * allSchools = [[NSFetchRequest alloc] init];
    [allSchools setEntity:[NSEntityDescription entityForName:@"School" inManagedObjectContext:self.moc]];
    [allSchools setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * schools = [self.moc executeFetchRequest:allSchools error:&error];
    //error handling goes here
    for (School *sch in schools) {
        [self.moc deleteObject:sch];
    }
}

#pragma mark - specialities

- (Speciality *) createSpecialityEntity:(NSDictionary *)param {
    Speciality *sp = (Speciality*)[NSEntityDescription insertNewObjectForEntityForName:@"Speciality" inManagedObjectContext:self.moc];
    sp.id_ = [param objectForKey:@"id"];
    sp.name = [param objectForKey:@"name"];
    return sp;
}

- (Speciality *) createTempSpeciality :(NSDictionary *) param {
    NSEntityDescription *mySchEntity = [NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:self.moc];
    Speciality *spEnt = [[Speciality alloc] initWithEntity:mySchEntity insertIntoManagedObjectContext:nil];
    spEnt.id_ = [param objectForKey:@"id"];
    spEnt.name = [param objectForKey:@"name"];
    return spEnt;
}

- (Speciality *) insertSpecialityObjectToContext: (Speciality *) speciality {
    Speciality *spEnt = [self getSpecialityById:speciality.id_];
    if (!spEnt) {
        [self.moc insertObject:speciality];
        [self saveContext];
        return speciality;
    } else {
        return spEnt;
    }
}

- (void) removeSpecialityObjectById : (Speciality *) speciality {
    Speciality *spEnt = [self getSpecialityById:speciality.id_];
    if (spEnt) {
        [self.moc deleteObject:spEnt];
    }
}

- (Speciality *) getSpecialityById : (NSNumber *) specId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@", specId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void) deleteAllSpeciality {
    NSFetchRequest * allSpec = [[NSFetchRequest alloc] init];
    [allSpec setEntity:[NSEntityDescription entityForName:@"Speciality" inManagedObjectContext:self.moc]];
    [allSpec setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * specialities = [self.moc executeFetchRequest:allSpec error:&error];
    //error handling goes here
    for (Speciality *sp in specialities) {
        [self.moc deleteObject:sp];
    }
}


#pragma mark - place
- (Place *) createPlaceEntity:(NSDictionary *)param {
    Place *pl = (Place*)[NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:self.moc];
    pl.id_ = [param objectForKey:@"id"];
    pl.cityId = [param objectForKey:@"cityId"];
    pl.name = [param objectForKey:@"name"];
    return pl;
}

- (void) addLPlaceEntityForUser :(NSDictionary *) param {
    Place *pl = [self createPlaceEntity: param];
    User *currentUser = [self getCurrentUser];
    
    NSMutableArray *places = [[currentUser.place allObjects] mutableCopy];
    if (places != nil) {
        [places addObject:pl];
    } else {
        places = [[NSMutableArray alloc] init];
    }
    currentUser.place = [NSSet setWithArray:places];
    [self saveContext];
}

- (void) deletePlaceEntityFromUser :(NSArray *) ids {
    User *currentUser = [self getCurrentUser];
    NSMutableArray *placesItems = [[currentUser.place allObjects] mutableCopy];
    NSMutableArray *discardedItems = [NSMutableArray array];
    Place *item;
    for (item in placesItems) {
        for (int i = 0; i < ids.count; i++) {
            if ([item.id_ intValue] == [[ids objectAtIndex:i] intValue]) {
                [discardedItems addObject:item];
            }
        }
    }
    [placesItems removeObjectsInArray:discardedItems];
    currentUser.place = [NSSet setWithArray:placesItems];
    [self saveContext];
}

- (Place *) createTempPlace :(NSDictionary *) param {
    NSEntityDescription *myPlaceEntity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.moc];
    Place *placeEnt = [[Place alloc] initWithEntity:myPlaceEntity insertIntoManagedObjectContext:nil];
    placeEnt.id_ = [param objectForKey:@"id"];
    placeEnt.cityId = [param objectForKey:@"cityId"];
    placeEnt.name = [param objectForKey:@"name"];
    return placeEnt;
}

- (Place *) insertPlaceObjectToContext: (Place *) place {
    Place *placeEnt = [self getPlaceById:place.id_];
    if (!placeEnt) {
        [self.moc insertObject:place];
        [self saveContext];
        return place;
    } else {
        return placeEnt;
    }
}

- (void) removePlaceObjectById : (Place *) place {
    Place *plEnt = [self getPlaceById:place.id_];
    if (plEnt) {
        [self.moc deleteObject:plEnt];
    }
}

- (Place *) getPlaceById : (NSNumber *) postId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@",postId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}


- (void) deleteAllPlaces {
    NSFetchRequest * allPlaces = [[NSFetchRequest alloc] init];
    [allPlaces setEntity:[NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.moc]];
    [allPlaces setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * places = [self.moc executeFetchRequest:allPlaces error:&error];
    //error handling goes here
    for (Place *place in places) {
        [self.moc deleteObject:place];
    }
}

#pragma mark -
#pragma mark career entity
- (Career*) createCareerEntity:(NSDictionary *)param {
    Career *car = (Career*)[NSEntityDescription insertNewObjectForEntityForName:@"Career" inManagedObjectContext:self.moc];
    car.id_ = [param objectForKey:@"id"];
    car.fromYear = [param objectForKey:@"fromYear"];
    car.companyId = [param objectForKey:@"companyId"];
    car.postId = [param objectForKey:@"postId"];
    car.toYear = [param objectForKey:@"toYear"];
    return car;
}


- (void) addCareerEntityForUser :(NSDictionary *) param {
    Career *ca = [self createCareerEntity: param];
    User *currentUser = [self getCurrentUser];
    NSMutableArray *careerItems = [[currentUser.career allObjects] mutableCopy];
    if (careerItems != nil) {
        [careerItems addObject:ca];
    } else {
        careerItems = [[NSMutableArray alloc] init];
    }
    currentUser.career = [NSSet setWithArray:careerItems];
    [self saveContext];
}

- (void) deleteCareerEntityFromUser :(NSArray *) ids {
    User *currentUser = [self getCurrentUser];
    NSMutableArray *careerItems = [[currentUser.career allObjects] mutableCopy];
    NSMutableArray *discardedItems = [NSMutableArray array];
    Career *item;
    for (item in careerItems) {
        for (int i = 0; i < ids.count; i++) {
            if ([item.id_ intValue] == [[ids objectAtIndex:i] intValue]) {
                [discardedItems addObject:item];
            }
        }
    }
    [careerItems removeObjectsInArray:discardedItems];
    currentUser.career = [NSSet setWithArray:careerItems];
    [self saveContext];
}



#pragma mark - career-post

- (CareerPost*) createCareerPost :(NSDictionary *)param {
    CareerPost *postEnt = (CareerPost*)[NSEntityDescription insertNewObjectForEntityForName:@"CareerPost" inManagedObjectContext:self.moc];
    postEnt.name = [param objectForKey:@"name"];
    postEnt.id_ = [param objectForKey:@"id"];
    [self saveContext];
    return postEnt;
}

- (CareerPost *) createTempCareerPost :(NSDictionary *) param {
    NSEntityDescription *myCareerPostEntity = [NSEntityDescription entityForName:@"CareerPost" inManagedObjectContext:self.moc];
    CareerPost *postEnt = [[CareerPost alloc] initWithEntity:myCareerPostEntity insertIntoManagedObjectContext:nil];
    postEnt.id_ = [param objectForKey:@"id"];
    postEnt.name = [param objectForKey:@"name"];
    return postEnt;
}

- (CareerPost *) insertCareerPostObjectToContext: (CareerPost *) cPost {
    CareerPost *postEnt = [self getCareerPostById:cPost.id_];
    if (!postEnt) {
        [self.moc insertObject:cPost];
        [self saveContext];
        return cPost;
    } else {
        return postEnt;
    }
}

- (void) removeCareerPostObjectById : (CareerPost *)cPost {
    CareerPost *postEnt = [self getCareerPostById:cPost.id_];
    if (postEnt) {
        [self.moc deleteObject:postEnt];
    }
}

- (CareerPost *) getCareerPostById : (NSNumber *) postId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"CareerPost" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@",postId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}


- (void) deleteAllCareerPosts {
    NSFetchRequest * allCareerPosts = [[NSFetchRequest alloc] init];
    [allCareerPosts setEntity:[NSEntityDescription entityForName:@"CareerPost" inManagedObjectContext:self.moc]];
    [allCareerPosts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * cPosts = [self.moc executeFetchRequest:allCareerPosts error:&error];
    //error handling goes here
    for (CareerPost * post in cPosts) {
        [self.moc deleteObject:post];
    }
}


#pragma mark - company

- (Company*) createCompany :(NSDictionary *)param {
    Company *companyEnt = (Company*)[NSEntityDescription insertNewObjectForEntityForName:@"Company" inManagedObjectContext:self.moc];
    companyEnt.name = [param objectForKey:@"name"];
    companyEnt.id_ = [param objectForKey:@"id"];
    [self saveContext];
    return companyEnt;
}

- (Company *) createTempCompany :(NSDictionary *) param {
    NSEntityDescription *myCompanyEntity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:self.moc];
    Company *companyEnt = [[Company alloc] initWithEntity:myCompanyEntity insertIntoManagedObjectContext:nil];
    companyEnt.id_ = [param objectForKey:@"id"];
    companyEnt.name = [param objectForKey:@"name"];
    return companyEnt;
}

- (Company *) insertCompanyObjectToContext: (Company *) company {
    Company *companyEnt = [self getCompanyById:company.id_];
    if (!companyEnt) {
        [self.moc insertObject:company];
        [self saveContext];
        return company;
    } else {
        return companyEnt;
    }
}

- (void) removeCompanyObjectById : (Company *)company {
    Company *companyEnt = [self getCompanyById:company.id_];
    if (companyEnt) {
        [self.moc deleteObject:companyEnt];
    }
}

- (Company *) getCompanyById : (NSNumber *) companyId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Company" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id_" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"id_  = %@",companyId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}

- (void) deleteCompanyPosts {
    NSFetchRequest * allCompanies = [[NSFetchRequest alloc] init];
    [allCompanies setEntity:[NSEntityDescription entityForName:@"Company" inManagedObjectContext:self.moc]];
    [allCompanies setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * companies = [self.moc executeFetchRequest:allCompanies error:&error];
    //error handling goes here
    for (Company * comp in companies) {
        [self.moc deleteObject:comp];
    }
}


#pragma mark -
#pragma mark avatar entity
- (Avatar*) createAvatarEntity:(NSDictionary *)param {
    Avatar *avatar = (Avatar*)[NSEntityDescription insertNewObjectForEntityForName:@"Avatar" inManagedObjectContext:self.moc];
    avatar.highCrop = [param objectForKey:@"highCrop"];
    avatar.highImageSrc = [[param objectForKey:@"highImage"] objectForKey:@"src"];
    avatar.highImageHeight = [[param objectForKey:@"highImage"] objectForKey:@"height"];
    avatar.highImageWidth = [[param objectForKey:@"highImage"] objectForKey:@"width"];
    avatar.squareCrop = [param objectForKey:@"squareCrop"];
    avatar.originalImageSrc = [[param objectForKey:@"originalImage"] objectForKey:@"src"];
    avatar.originalImageHeight = [[param objectForKey:@"originalImage"] objectForKey:@"height"];
    avatar.originalImageWidth = [[param objectForKey:@"originalImage"] objectForKey:@"width"];
    avatar.squareImageSrc = [[param objectForKey:@"squareImage"] objectForKey:@"src"];
    avatar.squareImageHeight = [[param objectForKey:@"squarelImage"] objectForKey:@"height"];
    avatar.squareImageWidth = [[param objectForKey:@"squareImage"] objectForKey:@"width"];
    return avatar;
}
#pragma mark -
#pragma mark current user entity
- (User *) createUserEntity:(NSDictionary *)param isCurrent:(BOOL) current {
    User *user;
    user = [self getUserForId:[param objectForKey:@"id"]];
    if(!user) {
        user = (User*)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.moc];
        user.isCurrentUser = [NSNumber numberWithBool:current];
        if([param objectForKey:@"name"])
            user.name = [param objectForKey:@"name"];
        if([param objectForKey:@"id"])
            user.userId = [param objectForKey:@"id"];
        if([param objectForKey:@"cityId"])
            user.cityId = [param objectForKey:@"cityId"];
        if([param objectForKey:@"createdAt"])
            user.createdAt = [param objectForKey:@"createdAt"];
        if([param objectForKey:@"dateOfBirth"])
            user.dateOfBirth = [param objectForKey:@"dateOfBirth"];
        if([param objectForKey:@"email"])
            user.email = [param objectForKey:@"email"];
        if([param objectForKey:@"gender"])
            user.gender = [param objectForKey:@"gender"];
        if([param objectForKey:@"visibility"])
            user.visibility = [param objectForKey:@"visibility"];
        if([param objectForKey:@"avatar"]) {
            user.avatar = [self createAvatarEntity:[param objectForKey:@"avatar"]];
            user.avatar.user = user;
        }
        if([param objectForKey:@"age"])
            user.age = [param objectForKey:@"age"];
        if([[param objectForKey:@"education"] isKindOfClass:[NSDictionary class]]) {
            
            if(![[param objectForKey:@"education"] isKindOfClass:[NSNull class]]) {
                Education *ed = [self createEducationEntity: [param objectForKey:@"education"]];
                ed.user = user;
                user.education = [NSSet setWithArray:[NSArray arrayWithObjects:ed, nil]];
            }
            
        } else if ([[param objectForKey:@"education"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *entArray = [NSMutableArray new];
            for(NSDictionary *t in [param objectForKey:@"education"]) {
                Education *ed = [self createEducationEntity:t];
                ed.user = user;
                [entArray addObject:[self createEducationEntity:t]];
            }
            user.education = [NSSet setWithArray:entArray];
        }
        
        if([[param objectForKey:@"career"] isKindOfClass:[NSDictionary class]]) {
            
            if(![[param objectForKey:@"career"] isKindOfClass:[NSNull class]]) {
                Career *ca = [self createCareerEntity: [param objectForKey:@"career"]];
                ca.user = user;
                user.career = [NSSet setWithArray:[NSArray arrayWithObjects:ca, nil]];
            }
            
        } else if ([[param objectForKey:@"career"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *entArray = [NSMutableArray new];
            for(NSDictionary *t in [param objectForKey:@"career"]) {
                Career *ca = [self createCareerEntity:t];
                ca.user = user;
                [entArray addObject:[self createCareerEntity:t]];
            }
            user.career = [NSSet setWithArray:entArray];
        }

        if([[param objectForKey:@"languageIds"] isKindOfClass:[NSDictionary class]]) {
            if(![[param objectForKey:@"languageIds"] isKindOfClass:[NSNull class]]) {
                Language *lan = [self createLanguageEntity: [param objectForKey:@"language"]];
                lan.user = user;
                user.language = [NSSet setWithArray:[NSArray arrayWithObjects:lan, nil]];
            }
        } else if ([[param objectForKey:@"languageIds"] isKindOfClass:[NSArray class]]) {
            NSMutableArray *entArray = [NSMutableArray new];
            for(NSDictionary *t in [param objectForKey:@"career"]) {
                Language *lan = [self createLanguageEntity:t];
                lan.user = user;
                [entArray addObject:[self createLanguageEntity:t]];
            }
            user.language = [NSSet setWithArray:entArray];
        }
        
        NSArray *cityIds;
        NSMutableString *par;
        if(![[param objectForKey:@"favoriteCityIds"] isKindOfClass:[NSNull class]]) {
        
            cityIds = [param objectForKey:@"favoriteCityIds"];
            par = [NSMutableString new];
            for(NSNumber *n in cityIds) {
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
        if(![[param objectForKey:@"favoritePlaceIds"] isKindOfClass:[NSNull class]]) {
            cityIds = [param objectForKey:@"favoritePlaceIds"];
            par = [NSMutableString new];
            for(NSNumber *n in cityIds) {
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
        
        if(![[param objectForKey:@"filter"] isKindOfClass:[NSNull class]]) {
            UserFilter *uf = [self createUserFilterEntity:[param objectForKey:@"filter"]];
            uf.user = user;
            user.userfilter = uf;
        }
        if(![[param objectForKey:@"languageIds"] isKindOfClass:[NSNull class]]) {
            cityIds = [param objectForKey:@"languageIds"];
            par = [NSMutableString new];
            for(NSNumber *n in cityIds) {
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
        if(![[param objectForKey:@"maxEntertainmentPrice"] isKindOfClass:[NSNull class]]) {
            MaxEntertainmentPrice *mxP = [self createMaxPrice:[param objectForKey:@"maxEntertainmentPrice"]];
            mxP.user = user;
            user.maxentertainment = mxP;
        }
        if(![[param objectForKey:@"minEntertainmentPrice"] isKindOfClass:[NSNull class]]) {
            MinEntertainmentPrice *mnP = [self createMinPrice:[param objectForKey:@"minEntertainmentPrice"]];
            mnP.user = user;
            user.minentertainment = mnP;
        }
        if(![[param objectForKey:@"nameForms"] isKindOfClass:[NSNull class]]) {
            cityIds = [param objectForKey:@"nameForms"];
            par = [NSMutableString new];
            for(NSString *n in cityIds) {
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
        [self saveContext];
    }
    return user;
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:@"1,2",@"careerPostIds",@"1,2",@"companyIds",@"1,2",@"languageIds",@"1,2", @"placeIds",@"1,2", @"schoolIds",@"1,2", @"specialityIds",nil];
//    [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:params];
}
- (User*) getCurrentUser {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isCurrentUser  = %d",1];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0)
        return [[controller fetchedObjects] objectAtIndex:0];
    else return nil;
}

- (void) deleteCurrentUser {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isCurrentUser  = %d",1];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return;
	}
    if([[controller fetchedObjects] count] >0) {
        User *current = [[controller fetchedObjects] objectAtIndex:0];
        [self.moc deleteObject:current];
        return;
    } else {
        return;
    }
}


- (User*) getUserForId:(NSNumber*) id_ {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"userId  = %d",[id_ intValue]];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0)
        return [[controller fetchedObjects] objectAtIndex:0];
    else return nil;
}
#pragma mark -
#pragma mark pointEntity
- (void) createPoint:(NSDictionary*) param {
    UserPoint *userPoint;
    userPoint = [self getPointForId:[param objectForKey:@"id"]];
    if(!userPoint) {
        userPoint = (UserPoint*)[NSEntityDescription insertNewObjectForEntityForName:@"UserPoint" inManagedObjectContext:self.moc];
        
        if([param objectForKey:@"id"])
            userPoint.pointId = [param objectForKey:@"id"];
        userPoint.pointCreatedAt = [param objectForKey:@"createdAt"];
        userPoint.pointLiked = [param objectForKey:@"liked"];
        userPoint.pointText = [param objectForKey:@"text"];
        userPoint.pointUserId = [param objectForKey:@"userId"];
        userPoint.pointValidTo = [param objectForKey:@"validTo"];
        [self saveContext];
    }
}
- (UserPoint*) getPointForUserId:(NSNumber*) userId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"UserPoint" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointUserId  = %d",[userId intValue]];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0)
        return [[controller fetchedObjects] objectAtIndex:0];
    else return nil;

}
- (UserPoint*) getPointForId:(NSNumber*) id_ {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"UserPoint" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointId  = %d",[id_ intValue]];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0)
        return [[controller fetchedObjects] objectAtIndex:0];
    else return nil;
}


- (void) setPointLiked : (NSNumber *) pointId : (BOOL) isLiked {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"UserPoint" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pointId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"pointId  = %d",[pointId intValue]];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return;
	}
    if([[controller fetchedObjects] count] >0) {
        UserPoint *point =[[controller fetchedObjects] objectAtIndex:0];
        point.pointLiked = [NSNumber numberWithBool:isLiked];
        [self saveContext];
        return;
    } else {
        return;
    }
}
#pragma mark -
#pragma mark application settings entity
- (void) createApplicationSettingEntity:(NSDictionary *)param
{
    [self deleteAppSettings];
    AppSetting *settings = (AppSetting*)[NSEntityDescription insertNewObjectForEntityForName:@"AppSetting" inManagedObjectContext:self.moc];
    settings.avatarMaxFileSize = [[param objectForKey:@"avatar"] objectForKey:@"maxFileSize"];
    if([[[param objectForKey:@"avatar"] objectForKey:@"minImageSize"] isKindOfClass:[NSArray class]] ) {
        if([[[param objectForKey:@"avatar"] objectForKey:@"minImageSize"] count] == 2) {
        settings.avatarMinImageWidth =  [[[param objectForKey:@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:0];//minImageSize
        settings.avatarMinImageHeight =  [[[param objectForKey:@"avatar"] objectForKey:@"minImageSize"] objectAtIndex:1];
        }
    }
    settings.pointMaxPeriod = [[param objectForKey:@"point"] objectForKey:@"maxPeriod"];
    settings.pointMinPeriod = [[param objectForKey:@"point"] objectForKey:@"minPeriod"];
    if([[param objectForKey:@"webSocketUrls"] isKindOfClass:[NSArray class]] ) {
        if([[param objectForKey:@"webSocketUrls"] count] == 1)
            settings.webSoketUrl = [[param objectForKey:@"webSocketUrls"] objectAtIndex:0];
    }
    //settings.webSoketUrl = [param objectForKey:@"webSocketUrls"];
    [self saveContext];
}
- (void) deleteAppSettings {
    NSArray *temp = [[self applicationSettingFetchResultsController] fetchedObjects];
    for(AppSetting *t in temp) {
        [self.moc deleteObject:t];
    }
}
- (AppSetting*) getAppSettings {
    NSArray *temp = [[self applicationSettingFetchResultsController] fetchedObjects];
    if(temp.count > 0)
        return [temp objectAtIndex:0];
    else return nil;
}

#pragma mark - users

-(NSFetchedResultsController*) allUsersFetchResultsController {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"isCurrentUser != 1"];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    return controller;

}

-(NSFetchedResultsController*) allUsersWithPointFetchResultsController {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"point.@count == 1 AND isCurrentUser != 1"];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    return controller;
    
}


-(NSFetchedResultsController*) applicationSettingFetchResultsController
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"AppSetting" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"avatarMaxFileSize" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    return controller;
}

- (void) createUser:(NSDictionary*) param {
    
}

- (void) createUserInfo:(NSDictionary*) param {
    
}
- (void) createUserSettings:(NSDictionary*) param {
    
}
- (NSFetchedResultsController*) getAllUsers {
    return nil;
}
- (NSFetchedResultsController*) getAllUsersForParams:(NSDictionary*) param {
    return nil;
}
- (void) DeleteAllUsers {
    
}
- (void) DeleteAllPoints {
    
}


#pragma mark - city
- (City*) createCity:(NSDictionary *)param {
    City *cityEnt = (City*)[NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:self.moc];
    cityEnt.cityEnName = [param objectForKey:@"enName"];
    cityEnt.cityId = [param objectForKey:@"id"];
    cityEnt.cityName = [param objectForKey:@"name"];
    cityEnt.cityNameForms = [param objectForKey:@"nameForms"];
    cityEnt.cityRegionId = [param objectForKey:@"regionId"];
    [self saveContext];
    return cityEnt;
    
}

- (City *) createTempCity :(NSDictionary *) param {
    NSEntityDescription *myCityEntity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.moc];
    City *cityEnt = [[City alloc] initWithEntity:myCityEntity insertIntoManagedObjectContext:nil];
    cityEnt.cityEnName = [param objectForKey:@"enName"];
    cityEnt.cityId = [param objectForKey:@"id"];
    cityEnt.cityName = [param objectForKey:@"name"];
    cityEnt.cityNameForms = [param objectForKey:@"nameForms"];
    cityEnt.cityRegionId = [param objectForKey:@"regionId"];
    return cityEnt;
}

- (City *) insertCityObjectToContext: (City *) city {
    City *cityEnt = [self getCityById:city.cityId];
    if (!cityEnt) {
        [self.moc insertObject:city];
        [self saveContext];
        return city;
    } else {
        return cityEnt;
    }
}

- (void) removeCityObjectById : (City *)city {
    City *cityEnt = [self getCityById:city.cityId];
    if (cityEnt) {
        [self.moc deleteObject:cityEnt];
    }
}

- (City *) getCityById : (NSNumber *) cityId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"cityId  = %@",cityId];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0) {
        return [[controller fetchedObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}


- (void) deleteAllCities {
    NSFetchRequest * allCities = [[NSFetchRequest alloc] init];
    [allCities setEntity:[NSEntityDescription entityForName:@"City" inManagedObjectContext:self.moc]];
    [allCities setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * cities = [self.moc executeFetchRequest:allCities error:&error];
    //error handling goes here
    for (City * city in cities) {
        [self.moc deleteObject:city];
    }
}

#pragma mark - contacts


- (Contact *) createContactEntity: (User *)user : (LastMessage *) lastMessage  {
    Contact *contactEnt = (Contact*)[NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.moc];
    contactEnt.lastmessage = lastMessage;
    contactEnt.user = user;
    [self saveContext];
    return contactEnt;
}


- (void) deleteAllContacts {
    NSFetchRequest * allContacts = [[NSFetchRequest alloc] init];
    [allContacts setEntity:[NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.moc]];
    [allContacts setIncludesPropertyValues:NO];
    NSError * error = nil;
    NSArray * contacts = [self.moc executeFetchRequest:allContacts error:&error];
    //error handling goes here
    for (Contact * cont in contacts) {
        [self.moc deleteObject:cont];
    }
}

-(NSFetchedResultsController*) getAllContactsFetchResultsController {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    return controller;
    
}


- (Contact *) getContactById : (NSNumber *) contactId {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.userId  = %d",[contactId intValue]];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    if([[controller fetchedObjects] count] >0)
        return [[controller fetchedObjects] objectAtIndex:0];
    else return nil;
}

- (void) deleteContact : (NSNumber *) contactId {
    Contact *contact = [self getContactById:contactId];
    if (contact) {
        [self.moc deleteObject:contact];
        [self saveContext];
    }
}

-(NSFetchedResultsController*) getContactsByQueryFetchResultsController :(NSString *) queryStr {
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
	NSEntityDescription* entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.moc];
	[request setEntity:entity];
    NSMutableArray* sortDescriptors = [NSMutableArray array]; //@"averageRating"
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"user.userId" ascending:NO];
    [sortDescriptors addObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    NSMutableString* predicateString = [NSMutableString string];
    [predicateString appendFormat:@"user.name contains[c] '%@' OR user.age == '%@'", queryStr, queryStr];
    
    BOOL predicateError = NO;
    @try {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:predicateString];
        [request setPredicate:predicate];
    }
    @catch (NSException *exception) {
        predicateError = YES;
    }
    
    if (predicateError)
        return nil;
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.moc sectionNameKeyPath:nil cacheName:nil];
    NSError* error=nil;
	if (![controller performFetch:&error])
	{
		return nil;
	}
    return controller;
    
}


#pragma mark - last message

- (LastMessage*) createLastMessage:(NSDictionary *)param  :(int) keyId {
    LastMessage *lastMsgEnt = (LastMessage*)[NSEntityDescription insertNewObjectForEntityForName:@"LastMessage" inManagedObjectContext:self.moc];
    lastMsgEnt.userId =[NSNumber numberWithInt: keyId];
    lastMsgEnt.id_ = [param objectForKey:@"id"];
   // lastMsgEnt.createdAt = [param objectForKey:@"createdAt"];
    lastMsgEnt.destinationId = [param objectForKey:@"destinationId"];
  // lastMsgEnt.readAt = [param objectForKey:@"readAt"];
    lastMsgEnt.sourceId = [param objectForKey:@"sourceId"];
    lastMsgEnt.text = [param objectForKey:@"text"];
    [self saveContext];
    return lastMsgEnt;
}



#pragma mark - save context


- (void) saveContext
{
    //if ([[self moc] hasChanges])
    {
        NSError* error=nil;
        [[self moc] save:&error];
        if (error)
        {
            NSLog(@"ERROR: saveContext: %@",error );
        }
    }
    
}

@end

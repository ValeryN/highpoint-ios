//
//  DataStorage.m
//  HightPoint
//
//  Created by Andrey Anisimov on 07.07.13.
//  Copyright (c) 2013 Andrey Anisimov. All rights reserved.
//

#import "DataStorage.h"
#import "HPAppDelegate.h"

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
    UserFilter *uf = (UserFilter*)[NSEntityDescription insertNewObjectForEntityForName:@"UserFilter" inManagedObjectContext:self.moc];
    uf.maxAge = [param objectForKey:@"maxAge"];
    uf.minAge = [param objectForKey:@"minAge"];
    uf.viewType = [param objectForKey:@"viewType"];
    NSMutableArray *arr = [NSMutableArray new];
    for(NSNumber *p in [param objectForKey:@"genders"]) {
        Gender *gender = (Gender*)[NSEntityDescription insertNewObjectForEntityForName:@"Gender" inManagedObjectContext:self.moc];
        gender.genderType = p;
        [arr addObject:gender];
    }
    uf.gender = [NSSet setWithArray:arr];
    [self saveContext];
    return uf;
    
}

- (UserFilter*) getUserFilter {
    NSArray *fetchedObjects;
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"UserFilter"  inManagedObjectContext: self.moc];
    [fetch setEntity:entityDescription];
    NSError * error = nil;
    fetchedObjects = [self.moc executeFetchRequest:fetch error:&error];
    if([fetchedObjects count] == 1)
        return [fetchedObjects objectAtIndex:0];
    else
        return nil;
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
- (void) createUserEntity:(NSDictionary *)param isCurrent:(BOOL) current {
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
        NSLog(@"%@", user.nameForms);
        [self saveContext];
    }
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

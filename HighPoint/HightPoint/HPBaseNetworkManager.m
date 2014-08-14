//
//  HPBaseNetworkManager.m
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"
#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"
#import "SocketIOPacket.h"
#import "DataStorage.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "NotificationsConstants.h"
#import "UserTokenUtils.h"
#import "CareerPost.h"
#import "Company.h"
#import "Language.h"
#import "User.h"
#import "Contact.h"
#import "HPAppDelegate.h"


static HPBaseNetworkManager *networkManager;
@interface HPBaseNetworkManager ()
@property (nonatomic,strong) SocketIO* socketIO;
@property (nonatomic, strong) NSMutableArray *taskArray;
@end


@implementation HPBaseNetworkManager

+ (HPBaseNetworkManager *) sharedNetworkManager {
    //networkManager = nil;
    @synchronized (self){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            networkManager = [[HPBaseNetworkManager alloc] init];
        });
        return networkManager;
    }
}
# pragma mark -
# pragma mark task monitor
- (void) createTaskArray {
    self.taskArray = [NSMutableArray new];
}
- (void) deleteTaskArray {
    self.taskArray = nil;
}
- (BOOL) isTaskArrayEmpty:(AFHTTPRequestOperationManager*) manager {
    if(self.taskArray && self.taskArray.count > 0) {
        int index = [self.taskArray indexOfObject:manager ];
        if(index != NSNotFound) {
            [self.taskArray removeObjectAtIndex:[self.taskArray indexOfObject:manager ]];
            if(self.taskArray.count == 0) {
                self.taskArray = nil;
                return YES;
            } else return NO;
        } else return NO;
    } else return NO;
}
- (void) addTaskToArray:(AFHTTPRequestOperationManager*) manager {
    if(self.taskArray && manager)   {
        [self.taskArray addObject:manager];

    }
}
# pragma mark -
# pragma mark network status
- (void) startNetworkStatusMonitor {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
- (void) setNetworkStatusMonitorCallback {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];

}
- (void) makeTownByIdRequest {
    NSArray *users = [[[DataStorage sharedDataStorage] allUsersFetchResultsController] fetchedObjects];
    NSLog(@"make town request");
    NSString *ids = @"";

    for (int i = 0; i < users.count; i++) {
        if (((User *)[users objectAtIndex:i]).cityId) {
            ids = [ids stringByAppendingString:[NSString stringWithFormat:@"%@%@", ((User *)[users objectAtIndex:i]).cityId, @","]];
        }
    }
    if ([ids length] > 0) {
        ids = [ids substringToIndex:[ids length] - 1];
    }
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:ids, @"cityIds", nil];
    [self getGeoLocation:param:0];

    param = [[NSDictionary alloc] initWithObjectsAndKeys:[[[URLs getServerURL] stringByReplacingOccurrencesOfString:@":3002" withString:@""] stringByReplacingOccurrencesOfString:@"http://" withString:@""],@"host", @"3002",@"port", nil];
    [[HPBaseNetworkManager sharedNetworkManager] initSocketIO:param];
    
    //NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil];
    User * usr = [[DataStorage sharedDataStorage] getCurrentUser];
    if(usr) {
        [[HPBaseNetworkManager sharedNetworkManager] makeReferenceRequest:[[DataStorage sharedDataStorage] prepareParamFromUser:usr]];
    }
}
# pragma mark -
# pragma mark http requests
- (void) makeAutorizationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kSigninRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    //[self addTaskToArray:manager];

    NSLog(@"auth parameters = %@", param);
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            [UserTokenUtils setUserToken:[[jsonDict objectForKey:@"data"] objectForKey:@"token"]];
            }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}
- (void) makeRegistrationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kRegistrationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];

    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
        }
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
    }];
}
- (void) getGeoLocation:(NSDictionary*) param : (int) mode {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    //[self addTaskToArray:manager];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GEOLOCATION -->: %@", operation.responseString);
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"] ;

                switch (mode) {

                    case 0: {
                        for(NSDictionary *dict in cities) {
                            [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:NO withComplation:nil];
                        }

                        NSArray *users = [[[DataStorage sharedDataStorage] allUsersFetchResultsController] fetchedObjects];
                        for (int i = 0; i < users.count; i++) {
                            NSLog(@"city id = %@", ((User*)[users objectAtIndex:i]).cityId);
                            City * city = [[DataStorage sharedDataStorage]  getCityById:((User*)[users objectAtIndex:i]).cityId];
                            NSLog(@"city name = %@", city.cityName);
                            [[DataStorage sharedDataStorage] setAndSaveCityToUser:((User *) [users objectAtIndex:i]).userId :city];
                        }

                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedUpdateUsersListViews
                                                                                                             object:nil
                                                                                                           userInfo:nil]];
                        break;
                    }

                    case 1: {
                        for(NSDictionary *dict in cities) {
                            [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:NO withComplation:nil];
                        }

                        User *current = [[DataStorage sharedDataStorage] getCurrentUser];
                        City * city = [[DataStorage sharedDataStorage]  getCityById:current.cityId];
                        [[DataStorage sharedDataStorage] setAndSaveCityToUser:current.userId :city];
                        break;
                    }

                    case 2: {
                        if(cities.count == 1) {
                            [[DataStorage sharedDataStorage] createAndSaveCity:cities[0] popular:NO withComplation:^(City *city) {
                                if (city) {
                                    [[DataStorage sharedDataStorage] setAndSaveCityToUserFilter:city];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:nil];
                                }
                            }];
                        }
                        else if(cities.count>1){
#ifdef DEBUG
                            @throw [NSException exceptionWithName:@"" reason:@"Someone lied to me" userInfo:nil];
#endif
                        }
                        break;
                    }

                    default:
                        break;
                }


            }
            else NSLog(@"Error, no valid data");

        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}

- (void) getPointsRequest:(NSInteger) lastPoint {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPointsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    [manager GET:url parameters:[Utils getParameterForPointsRequest:lastPoint] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"POINTS -->: %@", operation.responseString);
        NSLog(@"POINTS");
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                //[[DataStorage sharedDataStorage] createUserEntity:jsonDict];
                NSArray *poi = [[jsonDict objectForKey:@"data"] objectForKey:@"points"];
                for(NSDictionary *dict in poi) {
                    [[DataStorage sharedDataStorage] createAndSavePoint:dict];
                }
                NSDictionary *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                for(NSString *key in usr) {
                    NSDictionary *dict = [usr objectForKey:key];

                   // [self getGeoLocation:param];
                    [[DataStorage sharedDataStorage] createAndSaveUserEntity:[usr objectForKey:key] forUserType:MainListUserType withComplation:nil];
                }

                if([self isTaskArrayEmpty:manager]) {
                    NSLog(@"Stop Queue");
                    [self makeTownByIdRequest];
                }

            }
            else NSLog(@"Error, no valid data");

        }

        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if([self isTaskArrayEmpty:manager]) {
            NSLog(@"Stop Queue");
            [self makeTownByIdRequest];
        }


        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}
- (void) getUsersRequest:(NSInteger) lastUser {
    ///v201405/users
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUsersRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [self addTaskToArray:manager];
    [manager GET:url parameters:[Utils getParameterForUsersRequest:lastUser] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"USERS -->: %@", operation.responseString);
        NSLog(@"USERS");
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];

                for(NSDictionary *dict in usr) {
                    //NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[dict objectForKey:@"cityId"] stringValue] , @"city_ids", nil];
                    //[self getGeoLocation:param];
                    [[DataStorage sharedDataStorage] createAndSaveUserEntity:dict forUserType:MainListUserType withComplation:nil];
                }

                if([self isTaskArrayEmpty:manager]) {
                    NSLog(@"Stop Queue");
                    [self makeTownByIdRequest];
                }
            }
            else NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self isTaskArrayEmpty:manager]) {
            NSLog(@"Stop Queue");
            [self makeTownByIdRequest];
        }
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}

- (void) getCurrentUserRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCurrentUserRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self addTaskToArray:manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"GET CURRENT USER JSON: %@", operation.responseString);
        NSLog(@"GET CURRENT USER JSON");
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict){
                [[DataStorage sharedDataStorage] createAndSaveUserEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"user"] forUserType:CurrentUserType withComplation:nil];
                if([self isTaskArrayEmpty:manager]) {
                    NSLog(@"Stop Queue");
                    [self makeTownByIdRequest];
                }
            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self isTaskArrayEmpty:manager]) {
            NSLog(@"Stop Queue");
            [self makeTownByIdRequest];
        }
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}
- (void) findGeoLocation:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND GEO LOCATION JSON --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {

                NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"];
                NSMutableArray *citiesArr = [NSMutableArray new];

                for(NSDictionary *dict in cities) {
                    City *city = [[DataStorage sharedDataStorage] createTempCity:dict];
                    [citiesArr addObject:city];
                }
                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateCitiesListView object:self userInfo:param];
/*
                NSArray *cities = [jsonDict objectForKey:@"cities"] ;
                    NSMutableArray *citiesArr = [[NSMutableArray alloc] init];
                    for(NSDictionary *dict in cities) {
                        City *city = [[DataStorage sharedDataStorage] createTempCity:dict];
                        [citiesArr addObject:city];
                    }
                    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateCitiesListView object:self userInfo:param];
 */

            } else {
                NSLog(@"Error, no valid data");
            }

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}



#pragma mark - popular cities

- (void) getPopularCitiesRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPopularCitiesRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POPULAR CITIES: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            NSArray *cities = [[jsonDict objectForKey:@"data"] objectForKey:@"cities"] ;
            for(NSDictionary *dict in cities) {
                [[DataStorage sharedDataStorage] createAndSaveCity:dict popular:YES withComplation:nil];
            }
        } else {
            NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}



#pragma mark - application settings

- (void) getApplicationSettingsRequest {
    ///v201405/settings
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kApplicationSettingsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict)
                [[DataStorage sharedDataStorage] createAndSaveApplicationSettingEntity:jsonDict];
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}
- (void) getApplicationSettingsRequestForQueue {
    ///v201405/settings
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCurrentUserFilter];
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil];
}
#pragma mark - user filter

- (void) makeUpdateCurrentUserFilterSettingsRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCurrentUserFilter];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    NSLog(@"USER FILTER PARAMS --> %@", param.description);
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@" FILTER JSON --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                [[DataStorage sharedDataStorage] createAndSaveUserFilterEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"filter"] withComplation:nil];
            } else {
                NSLog(@"Error, no valid data");
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}


#pragma mark - reference

- (void) makeReferenceRequest:(NSDictionary*) param {
    NSString *url = nil;
    User *user = [param objectForKey:@"user"];
    NSMutableDictionary *par = [NSMutableDictionary dictionaryWithDictionary:param];
    [par removeObjectForKey:@"user"];
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kReferenceRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:par success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"REFERENCE REQUEST -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {

                    [[DataStorage sharedDataStorage] linkParameter:[jsonDict objectForKey:@"data"] toUser:user];
                } else {

                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}

#pragma mark - education

- (void) addEducationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kEducationAddRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ADD EDUCATION: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"educationItem"]) {
                    [[DataStorage sharedDataStorage] addAndSaveEducationEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"educationItem"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}


- (void) deleteEducationItemRequest:(NSString*) ids {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kEducationDeleteRequest];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:ids, @"ids", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE EDUCATION ITEMS: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"ids"]) {
                    [[DataStorage sharedDataStorage] deleteAndSaveEducationEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
       //[alert show];

    }];

}


- (void) findSchoolsRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kSchoolsFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND SCHOOLS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *schools = [[jsonDict objectForKey:@"data"] objectForKey:@"schools"] ;
                NSMutableArray *schoolsArr = [[NSMutableArray alloc] init];
                for(NSDictionary *dict in schools) {
                    School *sch = [[DataStorage sharedDataStorage] createTempSchool:dict];
                    [schoolsArr addObject:sch];
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];

            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}

- (void) findSpecialitiesRequest:(NSDictionary*) param {
    NSString *url = nil;
    url =[URLs getServerURL];
    url = [url stringByAppendingString:kSpecialityFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND SPECIALITIES -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *specialities = [[jsonDict objectForKey:@"data"] objectForKey:@"specialities"] ;
                NSMutableArray *specialitiesArr = [[NSMutableArray alloc] init];
                for(NSDictionary *dict in specialities) {
                    Speciality *sp = [[DataStorage sharedDataStorage] createTempSpeciality:dict];
                    [specialitiesArr addObject:sp];
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];

            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}


#pragma mark - plases
- (void) addPlaceRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPlasesAddRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ADD PLACE: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"place"]) {
                    [[DataStorage sharedDataStorage] addAndSavePlaceEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"place"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}


- (void) deletePlaceItemRequest:(NSString*) ids {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPlasesDeleteRequest];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:ids, @"ids", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE PLACES ITEMS: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"ids"]) {
                    [[DataStorage sharedDataStorage] deleteAndSavePlaceEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}

- (void) findPlacesRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPlacesFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND PLACES -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *places = [[jsonDict objectForKey:@"data"] objectForKey:@"places"];
                NSMutableArray *placesArr = [[NSMutableArray alloc] init];
                for(NSDictionary *dict in places) {
                    Place *place = [[DataStorage sharedDataStorage] createTempPlace:dict];
                    [placesArr addObject:place];
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];

            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}


#pragma mark - languages

- (void) addLanguageRequest:(NSString*) langName {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kLanguagesAddRequest];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:langName, @"name", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ADD LANGUAGE: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"language"]) {
                    [[DataStorage sharedDataStorage] addAndSaveLanguageEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"language"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}



- (void) deleteLanguageItemRequest:(NSString*) ids {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kLanguagesDeleteRequest];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:ids, @"ids", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE LANGUAGES ITEMS: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"ids"]) {
                    [[DataStorage sharedDataStorage] deleteAndSaveLanguageEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}

- (void) findLanguagesRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kLanguagesFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND LANGUAGES -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *posts = [[jsonDict objectForKey:@"data"] objectForKey:@"languages"] ;
                NSMutableArray *languagesArr = [[NSMutableArray alloc] init];

                for(NSDictionary *dict in posts) {
                    Language *language = [[DataStorage sharedDataStorage] createTempLanguage:dict];
                    [languagesArr addObject:language];
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];

            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}


#pragma mark companies 

- (void) findCompaniesRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCompaniesFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND COMPANIES -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *posts = [[jsonDict objectForKey:@"data"] objectForKey:@"companies"];
                NSMutableArray *companiesArr = [[NSMutableArray alloc] init];

                for(NSDictionary *dict in posts) {
                    Company *company = [[DataStorage sharedDataStorage] createTempCompany:dict];
                    [companiesArr addObject:company];
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];

            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}



#pragma mark - carrer post

- (void) findPostsRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPostsFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND POSTS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *posts = [[jsonDict objectForKey:@"data"] objectForKey:@"careerPosts"] ;
                NSMutableArray *postsArr = [[NSMutableArray alloc] init];

                for(NSDictionary *dict in posts) {
                    CareerPost *cPost = [[DataStorage sharedDataStorage] createTempCareerPost:dict];
                    [postsArr addObject:cPost];
                }
                //TODO: send
//                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];

            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}


#pragma mark - career

- (void) addCareerItemRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCareerAddRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ADD CAREER ITEM: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"careerItem"]) {
                    [[DataStorage sharedDataStorage] addAndSaveCareerEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"careerItem"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}

- (void) deleteCareerItemRequest:(NSString*) ids {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCareerDeleteRequest];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:ids, @"ids", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE CAREER ITEMS: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"ids"]) {
                    [[DataStorage sharedDataStorage] deleteAndSaveCareerEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}



#pragma mark - point like/unlike

- (void) makePointLikeRequest:(NSNumber*) pointId {
    ///v201405/points/<id>/like
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kPointsLikeRequest, [pointId stringValue]]];
    NSLog(@"url like = %@", url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINT LIKE RESP JSON: --> %@", operation.responseString);
        NSLog(@"LIKE STATUS CODE --> %ld", (long)operation.response.statusCode);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"success"]) {
                    [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId :YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdatePointLike object:self userInfo:nil];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];

}
- (void) makePointUnLikeRequest:(NSNumber*) pointId {
    ///v201405/points/<id>/like
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kPointsUnlikeRequest, [pointId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINT UNLIKE RESP JSON: --> %@", operation.responseString);
        NSLog(@"UNLIKE HEADER --> %@", operation.description);


        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"success"]) {
                    [[DataStorage sharedDataStorage] setAndSavePointLiked:pointId :NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdatePointLike object:self userInfo:nil];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}

#pragma mark - messages
- (void) sendMessageToUser : (NSNumber *) userId param: (NSDictionary *)param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kSendMessageToUserRequest, [userId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SEND MESSAGE RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSDictionary *msg = [[jsonDict objectForKey:@"data"] objectForKey:@"message"];
                if (msg) {
                   [[DataStorage sharedDataStorage] createAndSaveMessage:msg forUserId:userId andMessageType:HistoryMessageType withComplation:nil];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}

- (void) sendFewMessagesToUser : (NSNumber *) userId param: (NSArray *)param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kSendMessagesToUserRequest, [userId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:param,@"data", nil];
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"SEND MESSAGE RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *msgs = [[jsonDict objectForKey:@"data"] objectForKey:@"messages"];
                for (NSDictionary *msg in msgs) {
                    [[DataStorage sharedDataStorage] createAndSaveMessage:msg forUserId:userId andMessageType:HistoryMessageType withComplation:nil];

                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];

    }];
}


#pragma mark - unread message
- (void) getUnreadMessageRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUnreadMessagesRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [self addTaskToArray:manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET UNREAD MESSAGES -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if([self isTaskArrayEmpty:manager]) {
                    NSLog(@"Stop Queue");
                    [self makeTownByIdRequest];
                }
            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        //if([self isTaskArrayEmpty:manager]) {
        //    NSLog(@"Stop Queue");
        //}

    }];

}

#pragma mark - contacts
- (void) getContactsRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGetContactsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [self addTaskToArray:manager];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"GET CONTACTS -->: %@", operation.responseString);
        NSLog(@"GET CONTACTS");
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                [[DataStorage sharedDataStorage] deleteAndSaveAllContacts];
                NSArray *users = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                NSDictionary *lastMsgs = [[jsonDict objectForKey:@"data"] objectForKey:@"messages"];
                for (int i = 0; i < users.count; i++) {
                    [[DataStorage sharedDataStorage] createAndSaveUserEntity:[users objectAtIndex:i] forUserType:ContactUserType withComplation:^(User *user) {
                        for (id key in [lastMsgs allKeys]) {
                            if ([user.userId intValue] == [key intValue]) {
                                [[DataStorage sharedDataStorage] createAndSaveMessage:[lastMsgs objectForKey:key] forUserId:user.userId andMessageType:LastMessageType withComplation:^(Message *lastMsg) {
                                    [[DataStorage sharedDataStorage] createAndSaveContactEntity:user forMessage:lastMsg withComplation:^(id object) {
                                        [self getChatMsgsForUser:user.userId :nil];
                                    }];
                                }];
                                break;
                            }
                        }
                        
                        if ([self isTaskArrayEmpty:manager]) {
                            NSLog(@"Stop Queue");
                            [self makeTownByIdRequest];
                        }
                    }];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateContactListViews object:self userInfo:nil];
            }
            else NSLog(@"Error, no valid data");

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if([self isTaskArrayEmpty:manager]) {
            NSLog(@"Stop Queue");
            [self makeTownByIdRequest];
        }
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }];
}


- (void) deleteContactRequest : (NSNumber *)contactId {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kContactDeleteRequest, [contactId stringValue]]];
    NSLog(@"url remove contact = %@", url);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"DELETE CONTACT RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"id"]) {
                    [[DataStorage sharedDataStorage] deleteAndSaveContact:contactId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateContactListViews object:self userInfo:nil];
                    [[DataStorage sharedDataStorage] deleteAndSaveChatByUserId:contactId];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];

    }];
}

#pragma mark - chat

- (void) getChatMsgsForUser : (NSNumber *) userId : (NSNumber *) afterMsgId {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kUserMessagesRequest, [userId stringValue]]];
    NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:afterMsgId, @"afterMessageId", nil];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET USER MESSAGES RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if ([[jsonDict objectForKey:@"data"] objectForKey:@"messages"]) {
                    User *user = [[DataStorage sharedDataStorage] getUserForId:userId];
                    [[DataStorage sharedDataStorage] createAndSaveChatEntity:user withMessages:[[jsonDict objectForKey:@"data"] objectForKey:@"messages"] withComplation:nil];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
             [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateChatView object:self userInfo:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];

    }];
}

# pragma mark -
# pragma mark socket io methods
//param - dict with keys host, port, user
- (void) initSocketIO:(NSDictionary*) param {
    _socketIO = [[SocketIO alloc] initWithDelegate:self];
    [_socketIO connectToHost:[param objectForKey:@"host"]  onPort:[[param objectForKey:@"port"] intValue]];
    [_socketIO sendEvent:@"join" withData:[param objectForKey:@"user"]];
}
- (void) sendMessage:(NSDictionary*) param {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"777",@"id",@"text message",@"body",@"333", @"destinationId", nil];
    [_socketIO sendEvent:kSendMessage withData:dict];
}
- (void) sendUserActivityStart:(NSDictionary*) param {
    if(_socketIO) {
         [_socketIO sendEvent:kActivityStart withData:param];
    }
}
- (void) sendUserActivityEnd:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kActivityEnd withData:param];
    }
}
- (void) sendUserMessagesRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kMessagesRead withData:param];
    }
}
- (void) sendUserTypingStart:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kTypingStart withData:param];
    }
}
- (void) sendUserTypingFinish:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kTypingFinish withData:param];
    }
}
- (void) sendUserNotificationRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kNotificationRead withData:param];
    }
}
- (void) sendUserAllNotificationRead:(NSDictionary*) param {
    if(_socketIO) {
        [_socketIO sendEvent:kAllNotificationRead withData:param];
    }
}
# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socket.io connected.");
}
//receive event
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"didReceiveEvent()");
    NSLog(@"%@",packet.args);
    NSLog(@"%@",packet.name);
    //parsing incoming messages here

    if([packet.name isEqualToString:@"message"])
    {
        NSArray* args = packet.args;
        NSDictionary* arg = args[0];
    }

    if ([packet.name isEqualToString:kMeUpdate]) {
        NSLog(@"me update args = %@", packet.args);
        NSDictionary *jsonDict = [packet.args objectAtIndex:0];
        if(jsonDict) {
            [[DataStorage sharedDataStorage] deleteAllCities];
            [[DataStorage sharedDataStorage] deleteAndSaveCurrentUser];
        } else {
            NSLog(@"Error, no valid data");
        }

    }

    if ([packet.name isEqualToString:kMessage]) {
        //TODO: write msgs to DB

    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"onError() %@", error);
}


- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socket.io disconnected. did error occur? %@", error);
}

@end

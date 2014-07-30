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
#import "LastMessage.h"
#import "Contact.h"



static HPBaseNetworkManager *networkManager;
@interface HPBaseNetworkManager ()
@property (nonatomic,strong) SocketIO* socketIO;
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
# pragma mark network status
- (void) startNetworkStatusMonitor {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
- (void) setNetworkStatusMonitorCallback {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
}
# pragma mark -
# pragma mark http requests
- (void) makeAutorizationRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kSigninRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    NSLog(@"auth parameters = %@", param);
    [manager POST:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            [UserTokenUtils setUserToken:[[jsonDict objectForKey:@"data"] objectForKey:@"token"]];
            }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}
- (void) getGeoLocation:(NSDictionary*) param {
    //
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GEOLOCATION -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *cities = [jsonDict objectForKey:@"cities"] ;
                NSMutableArray *citiesArr = [[NSMutableArray alloc] init];
                
                for(NSDictionary *dict in cities) {
                    City *city = [[DataStorage sharedDataStorage] createCity:dict];
                    [citiesArr addObject:city];
                }
                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else NSLog(@"Error, no valid data");
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}

- (void) getPointsRequest:(NSInteger) lastPoint {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kPointsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager GET:url parameters:[Utils getParameterForPointsRequest:lastPoint] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POINTS -->: %@", operation.responseString);
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
                    [[DataStorage sharedDataStorage] createPoint:dict];
                }
                NSDictionary *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                for(NSString *key in usr) {
                    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[[usr objectForKey:key] objectForKey:@"cityId"] stringValue] , @"city_ids", nil];
                    
                   // [self getGeoLocation:param];
                    [[DataStorage sharedDataStorage] createUserEntity:[usr objectForKey:key] isCurrent:NO];
                }
            }
            else NSLog(@"Error, no valid data");
            
        }
        
        //NSMutableDictionary *parsedDictionary = [NSMutableDictionary new];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];

}
- (void) getUsersRequest:(NSInteger) lastUser {
    ///v201405/users
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUsersRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    
    [manager GET:url parameters:[Utils getParameterForUsersRequest:lastUser] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"USERS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                //[[DataStorage sharedDataStorage] createUserEntity:jsonDict];
                
                
                
                
                NSArray *usr = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                for(NSDictionary *dict in usr) {
                    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:[[dict objectForKey:@"cityId"] stringValue] , @"city_ids", nil];
                    //[self getGeoLocation:param];
                    [[DataStorage sharedDataStorage] createUserEntity:dict isCurrent:NO];
                }
                
                NSNotification *notification = [NSNotification notificationWithName:kNeedUpdateUsersListViews
                                                                             object:nil
                                                                           userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            else NSLog(@"Error, no valid data");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}

- (void) getCurrentUserRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCurrentUserRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET CURRENT USER JSON: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict)
                [[DataStorage sharedDataStorage] createUserEntity: [[jsonDict objectForKey:@"data"] objectForKey:@"user"] isCurrent:YES];
            else NSLog(@"Error, no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
}
- (void) findGeoLocation:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGeoLocationFindRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"FIND GEO LOCATION JSON --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                NSArray *cities = [jsonDict objectForKey:@"cities"] ;
                NSMutableArray *citiesArr = [[NSMutableArray alloc] init];
                
                for(NSDictionary *dict in cities) {
                    City *city = [[DataStorage sharedDataStorage] createTempCity:dict];
                    [citiesArr addObject:city];
                }
                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateCitiesListView object:self userInfo:param];
            } else {
                NSLog(@"Error, no valid data");
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
                [[DataStorage sharedDataStorage] createApplicationSettingEntity:jsonDict];
            else NSLog(@"Error, no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
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
                // TODO: save ?
            } else {
                NSLog(@"Error, no valid data");
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
    
}


#pragma mark - reference

- (void) makeReferenceRequest:(NSDictionary*) param {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kReferenceRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:url parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"REFERENCE REQUEST -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                
                
//                NSArray *cities = [jsonDict objectForKey:@"cities"] ;
//                NSMutableArray *citiesArr = [[NSMutableArray alloc] init];
//                
//                for(NSDictionary *dict in cities) {
//                    City *city = [[DataStorage sharedDataStorage] createCity:dict];
//                    [citiesArr addObject:city];
//                }
//                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
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
                    [[DataStorage sharedDataStorage] addLEducationEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"educationItem"]];
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
                    [[DataStorage sharedDataStorage] deleteEducationEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
                    [[DataStorage sharedDataStorage] addLPlaceEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"place"]];
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
                    [[DataStorage sharedDataStorage] deletePlaceEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
                    [[DataStorage sharedDataStorage] addLanguageEntityForUser:[[jsonDict objectForKey:@"data"]objectForKey:@"language"]];
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
                    [[DataStorage sharedDataStorage] deleteLanguageEntityFromUser:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
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
                    [[DataStorage sharedDataStorage] addCareerEntityForUser:[[jsonDict objectForKey:@"data"] objectForKey:@"careerItem"]];
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
                    [[DataStorage sharedDataStorage] deleteCareerEntityFromUser:[[jsonDict objectForKey:@"data"]objectForKey:@"ids"]];
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
                    [[DataStorage sharedDataStorage] setPointLiked:pointId :YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdatePointLike object:self userInfo:nil];
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
                    [[DataStorage sharedDataStorage] setPointLiked:pointId :NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdatePointLike object:self userInfo:nil];
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



#pragma mark - contacts
- (void) getContactsRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kGetContactsRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET CONTACTS -->: %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                [[DataStorage sharedDataStorage] deleteAllContacts];
                NSArray *users = [[jsonDict objectForKey:@"data"] objectForKey:@"users"];
                NSDictionary *lastMsgs = [[jsonDict objectForKey:@"data"] objectForKey:@"messages"];
                
                for (int i = 0; i < users.count; i++) {
                    User *user = [[DataStorage sharedDataStorage] createUserEntity:[users objectAtIndex:i] isCurrent:NO];
                    LastMessage * lastMsg;
                    for (id key in [lastMsgs allKeys]) {
                        if ([user.userId intValue] == [key intValue]) {
                            lastMsg = [[DataStorage sharedDataStorage] createLastMessage:[lastMsgs objectForKey:key]: [key intValue]];
                            break;
                        }
                    }
                    [[DataStorage sharedDataStorage] createContactEntity:user :lastMsg];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateContactListViews object:self userInfo:nil];
            }
            else NSLog(@"Error, no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
                    [[DataStorage sharedDataStorage] deleteContact:contactId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateContactListViews object:self userInfo:nil];
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
            [[DataStorage sharedDataStorage] deleteCurrentUser];
            [[DataStorage sharedDataStorage] createUserEntity: [jsonDict objectForKey:@"user"] isCurrent:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateCurrentUserData object:self userInfo:nil];
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

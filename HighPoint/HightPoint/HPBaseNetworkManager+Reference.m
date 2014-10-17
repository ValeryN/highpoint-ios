//
//  HPBaseNetworkManager+Reference.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Reference.h"
#import "HPBaseNetworkManager+Geo.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Reference)
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
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];

            if(jsonDict && ![[jsonDict objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
                NSArray *places = [[jsonDict objectForKey:@"data"] objectForKey:@"places"];
                NSMutableString *str = [NSMutableString new];
                for(NSDictionary *d in places) {
                    City *city = [[DataStorage sharedDataStorage] getCityById:d[@"cityId"]];
                    if(city == nil) {
                        [str appendFormat:@"%d,", [d[@"cityId"] intValue]];
                    }
                    //str = [NSMutableString stringWithString:@"1,2,3,4,5,6"];
                    if(str.length > 0) {
                        NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:str, @"cityIds", nil];
                        [self getGeoLocationForPlaces:param withBlock:^(NSString* result) {
                            [[DataStorage sharedDataStorage] linkParameter:[jsonDict objectForKey:@"data"] toUser:user withComplation:^(NSError *error) {
                                if(!error) {
                                    
                                }
                            }];
                        }];
                    }
                    else [[DataStorage sharedDataStorage] linkParameter:[jsonDict objectForKey:@"data"] toUser:user withComplation:^(NSError *error) {
                        if(!error) {
                            
                        }
                    }];
                }

            } else {
                
                NSLog(@"Error: %@", error.localizedDescription);
                // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
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
                    [[DataStorage sharedDataStorage] createTempCareerPost:dict withComplation:^(CareerPost *cPost) {
                        [postsArr addObject:cPost];
                    }];
                    
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else
                NSLog(@"Error: no valid data");
            
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
                    [[DataStorage sharedDataStorage] createTempCompany:dict withComplation:^(Company *company) {
                        [companiesArr addObject:company];
                    }];
                    
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else
                NSLog(@"Error: no valid data");
            
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
                    [[DataStorage sharedDataStorage] createTempLanguage:dict withComplation:^(Language* language) {
                        [languagesArr addObject:language];
                    }];
                    
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else
                NSLog(@"Error: no valid data");
            
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
                    [[DataStorage sharedDataStorage] createTempPlace:dict withComplation:^(Place *place) {
                        [placesArr addObject:place];
                    }];
                    
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else
                NSLog(@"Error: no valid data");
            
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
                    
                    [[DataStorage sharedDataStorage] createTempSchool:dict withComplation:^(School *school) {
                        [schoolsArr addObject:school];
                    }];
                    
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else
                NSLog(@"Error: no valid data");
            
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
                    [[DataStorage sharedDataStorage] createTempSpeciality:dict withComplation:^(Speciality *sp) {
                        [specialitiesArr addObject:sp];
                    }] ;
                    
                }
                //TODO: send
                //                NSDictionary *param = [[NSDictionary alloc] initWithObjectsAndKeys:citiesArr, @"cities", nil];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateFilterCities object:self userInfo:param];
                
            }
            else
                NSLog(@"Error: no valid data");
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //[alert show];
        
    }];
}



@end

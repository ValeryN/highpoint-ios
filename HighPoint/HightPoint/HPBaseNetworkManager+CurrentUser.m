//
//  HPBaseNetworkManager+CurrentUser.m
//  HighPoint
//
//  Created by Andrey Anisimov on 10.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+CurrentUser.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (CurrentUser)
#pragma mark - current user

- (void) getCurrentUserRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kCurrentUserRequest];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[HPBaseNetworkManager sharedNetworkManager] addTaskToArray:manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"GET CURRENT USER JSON: %@", operation.responseString);
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
                NSLog(@"filter saved");
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"status", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateUserFilterData object:nil userInfo:options];
            } else {
                NSLog(@"Error, no valid data");
                NSLog(@"cant parse filter json");
                NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateUserFilterData object:nil userInfo:options];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        NSLog(@"filter save error");
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@0,@"status", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNeedUpdateUserFilterData object:nil userInfo:options];
        
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
                //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
                //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                //[alert show];
            }
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
                    [[DataStorage sharedDataStorage] addAndSavePlaceEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"place"] forUser:[[DataStorage sharedDataStorage] getCurrentUser]];
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
                    [[DataStorage sharedDataStorage] deleteAndSavePlaceEntityFromUserWithIds:[[jsonDict objectForKey:@"data"] objectForKey:@"ids"]];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                //  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
#pragma mark - photo

- (void) setUserAvatarRequest : (UIImage *) image {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:kUploadAvatarRequest];
    NSData *imageData = UIImagePNGRepresentation(image);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:@"name" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"UPLOAD AVATAR: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if (operation.response.statusCode == 403) {
                NSNumber *errorCode = [jsonDict objectForKey:@"error"];
                if ([errorCode isEqualToValue:@8]) {
                    // show wrong file format error
                }
                if ([errorCode isEqualToValue:@9]) {
                    // show too large file error
                }
                if ([errorCode isEqualToValue:@10]) {
                    // show too small file error
                }
            } else {
                if(jsonDict) {
                    NSDictionary *avatar = [jsonDict objectForKey:@"data"];
                    //save avatar for current user
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//TODO: /v201405/me/avatar/crop
- (void) getUserPhotoRequest {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithString:kGetUserPhotoRequest]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // NSLog(@"GET USER MESSAGES RESP JSON: --> %@", operation.responseString);
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if([[jsonDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                    
                    if([[[jsonDict objectForKey:@"data"] objectForKey:@"photos"] isKindOfClass:[NSArray class]]) {
                        for(id d in [[jsonDict objectForKey:@"data"] objectForKey:@"photos"]) {
                            if([d isKindOfClass:[NSDictionary class]]) {
                                [[DataStorage sharedDataStorage] createAndSavePhotoEntity:d];
                            }
                        }
                    }
                }
                
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
        
        
    }];
    
}

//TODO: /v201405/me/photos/sort

@end
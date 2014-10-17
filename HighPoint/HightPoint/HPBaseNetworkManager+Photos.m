//
//  HPBaseNetworkManager+Photos.m
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager+Photos.h"
#import "URLs.h"
#import "Utils.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "DataStorage.h"
#import "UserTokenUtils.h"
#import "NotificationsConstants.h"

@implementation HPBaseNetworkManager (Photos)
//TODO: /v201405/photos/add //kAddPhotoRequest
- (void) addPhotoRequest:(UIImage*) image andPhotoId:(NSNumber*) id_{
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithString:kAddPhotoRequest]];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    [[self requestOperationManager] POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"image"
                                fileName:@"name.jpg" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if (operation.response.statusCode == HTTPStatusForbidden) {
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
                    if([[[jsonDict objectForKey:@"data"] objectForKey:@"photo"] isKindOfClass:[NSDictionary class]]) {
                        //delete int image
                        [[DataStorage sharedDataStorage] deletePhotoById:id_ withComplation:^(NSError *error) {
                            if(!error) {
                                [[DataStorage sharedDataStorage] createAndSavePhotoEntity:[[jsonDict objectForKey:@"data"] objectForKey:@"photo"] withComplation:^(NSError *error) {
                                    if(!error) {
                                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedUpdateUserPhotos
                                                                                                                             object:nil
                                                                                                                           userInfo:nil]];
                                    }
                                }];
                            }
                        }];
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

}
- (void) deletePhotoRequest : (NSNumber *) photoId {
    NSString *url = nil;
    url = [URLs getServerURL];
    url = [url stringByAppendingString:[NSString stringWithFormat:kDeletePhotoRequest, [photoId stringValue]]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    manager.requestSerializer = [AFHTTPRequestSerializer new];
    [manager.requestSerializer setValue:[UserTokenUtils getUserToken] forHTTPHeaderField:@"Authorization: Bearer"];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSData* jsonData = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        
        if(jsonData) {
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                     options:kNilOptions
                                                                       error:&error];
            if(jsonDict) {
                if (operation.response.statusCode == HTTPStatusForbidden) {
                    //access denied
                    return;
                }
                if (operation.response.statusCode == HTTPStatusNotFound) {
                    //not found
                    return;
                }
                NSNumber *deletedId = [[jsonDict objectForKey:@"data"] objectForKey:@"id"];
                if (deletedId) {
                    
                    [self deleteDeletedItemFromArray:[deletedId intValue]];
                    [[DataStorage sharedDataStorage] deletePhotoById:deletedId withComplation:^(NSError *error) {
                        if(!error) {
                            if([self isDeletedItemArrayEmpty] ) {
                                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNeedUpdateUserPhotos
                                                                                                        object:nil
                                                                                                        userInfo:nil]];
                                [self deleteDeletedItemArray];
                                
                            } else {
                                [self deletePhotoRequest:[self getFirstIndexIntoDeletedArray]];
                            }
                            
                            //
                        }
                    }];
                }
            } else {
                NSLog(@"Error: %@", error.localizedDescription);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.localizedDescription);
    }];
}

@end

//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "User+UserImage.h"
#import "SDWebImageManager.h"
#import "Avatar.h"
#import "NSManagedObject+HighPoint.h"
#import "NSManagedObjectContext+HighPoint.h"

#define IMAGE_NOT_DOWNLOADED @"transparentflower.png"
#define IMAGE_ERROR_DOWNLOAD @"error-256.png"

@implementation User (UserImage)
- (RACSignal *) userImageSignal
{
    //return [RACSignal return:[UIImage imageNamed:@".png"]];
    User* userInContext = [self moveToContext:[NSManagedObjectContext threadContext]];
    NSString* avatarUrl = userInContext.avatar.originalImgSrc;
    SDWebImageOptions options = SDWebImageRetryFailed;
    if(userInContext.isCurrentUser.boolValue) {
        options |= SDWebImageDownloaderHighPriority;
    }

    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        __block BOOL notDownloadCancel = YES;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        manager.imageDownloader.maxConcurrentDownloads = 100;
        [subscriber sendNext:[UIImage imageNamed:IMAGE_NOT_DOWNLOADED]];
        id <SDWebImageOperation> operation = [manager downloadWithURL:[NSURL URLWithString:avatarUrl]
                                                              options: options
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             }
                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                notDownloadCancel = NO;
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                    if (image) {
                                                                        [subscriber sendNext:image];
                                                                        [subscriber sendCompleted];
                                                                    }
                                                                    else {
                                                                        NSLog(@"Failed download %@",avatarUrl);
                                                                        [subscriber sendError:error];
                                                                    }
                                                                });
                                                            }];
        return [RACDisposable disposableWithBlock:^{

            //[operation cancel];

            if(notDownloadCancel) {
                NSLog(@"Cancel not download avatar %@", avatarUrl);
            }
            [operation cancel];

        }];
    }] retry:2] catchTo:[RACSignal return:[UIImage imageNamed:IMAGE_ERROR_DOWNLOAD]]];
}
@end
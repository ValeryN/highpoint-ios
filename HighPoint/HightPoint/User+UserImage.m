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
    User* userInContext = [self moveToContext:[NSManagedObjectContext threadContext]];
    NSString* avatarUrl = userInContext.avatar.originalImgSrc;
    NSURL * imageURL = [NSURL URLWithString:avatarUrl];
    return [[User getPlaceholderImage] takeUntilReplacement:[[User getAvatarFromCacheWithUrl:imageURL] catchTo:[User getAvatarFromNetworkWithUrl:imageURL]]];
}

+ (RACSignal*) getPlaceholderImage{
    return [RACSignal return:[UIImage imageNamed:IMAGE_NOT_DOWNLOADED]];
}

+ (RACSignal *) getAvatarFromCacheWithUrl:(NSURL*)avatarUrl{
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage * imageInCache = [manager.imageCache imageFromDiskCacheForKey:[manager cacheKeyForURL:avatarUrl]];
            if(imageInCache) {
                [subscriber sendNext:imageInCache];
                [subscriber sendCompleted];
            }
            else
                [subscriber sendError:[NSError errorWithDomain:@"sdwebimage.cache.notfound" code:404 userInfo:nil]];


        return nil;
    }] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (RACSignal*) getAvatarFromNetworkWithUrl:(NSURL*) avatarUrl{
    return [[[[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        __block BOOL notDownloadCancel = YES;
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        manager.imageDownloader.maxConcurrentDownloads = 100;
        id <SDWebImageOperation> operation = [manager downloadImageWithURL:  avatarUrl
                                                              options: SDWebImageRetryFailed
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             }
                                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
            if(notDownloadCancel) {
                NSLog(@"Cancel not download avatar %@", avatarUrl);
            }
            [operation cancel];

        }];
    }] retry:2] catchTo:[RACSignal return:[UIImage imageNamed:IMAGE_ERROR_DOWNLOAD]]] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]];
}
@end
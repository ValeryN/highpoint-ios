//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "User+UserImage.h"
#import "SDWebImageManager.h"
#import "Avatar.h"


@implementation User (UserImage)
- (RACSignal *) userImageSignal
{
    @weakify(self);
    return [[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        @strongify(self);
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        id <SDWebImageOperation> operation = [manager downloadWithURL:[NSURL URLWithString:self.avatar.originalImageSrc]
                                                              options:0
                                                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             }
                                                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                                                @strongify(self);
                                                                if (image) {
                                                                    [subscriber sendNext:image];
                                                                    [subscriber sendCompleted];
                                                                }
                                                                else {
                                                                    NSLog(@"Failed download %@",self.avatar.originalImageSrc);
                                                                    [subscriber sendError:error];
                                                                }
                                                            }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }] retry:2] catchTo:[RACSignal empty]];
}
@end
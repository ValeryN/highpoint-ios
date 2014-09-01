//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPRequest.h"
#import "AFHTTPRequestOperationManager.h"


@implementation HPRequest
+ (RACSignal *) getDataFromServerWithUrl:(NSString*) url andParameters:(NSDictionary *) param{
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        //Запрос данных с сервера
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestOperation *operation = [manager GET:url
                                              parameters:param
                                                 success:^(AFHTTPRequestOperation *localOperation, id jsonDict) {
                                                     if (jsonDict) {
                                                         //Получаем JSON и если он пропарсился отправляем на проверку
                                                         [subscriber sendNext:jsonDict];
                                                         [subscriber sendCompleted];
                                                     }
                                                     else {
                                                         [subscriber sendError:[NSError errorWithDomain:@"Json parse error" code:500 userInfo:nil]];
                                                     }
                                                 }
                                                 failure:^(AFHTTPRequestOperation *localOperation, NSError *error) {
                                                     [subscriber sendError:error];
                                                 }];
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
}
@end
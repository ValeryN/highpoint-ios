//
// Created by Eugene on 01.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HPRequest : NSObject
+ (RACSignal *)getDataFromServerWithUrl:(NSString *)url andParameters:(NSDictionary *)param;
@end
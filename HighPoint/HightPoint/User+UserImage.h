//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface User (UserImage)
- (RACSignal *)userImageSignal;
@end
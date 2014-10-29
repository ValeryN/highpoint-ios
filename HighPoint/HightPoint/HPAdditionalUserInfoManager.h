//
//  HPAdditionalUserInfoManager.h
//  HighPoint
//
//  Created by Eugen Antropov on 29/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPAdditionalUserInfoManager : NSObject
+ (HPAdditionalUserInfoManager *)instance;
- (RACSignal*) getCitySignalForId:(NSNumber*) cityId;
@end

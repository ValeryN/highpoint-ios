//
//  HPSettingsDataManager.m
//  HighPoint
//
//  Created by Eugene on 15/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPSettingsDataManager.h"


@implementation HPSettingsDataManager

+ (instancetype) sharedInstance
{
    static HPSettingsDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init{
    self = [super init];
    if(self){
        RACChannelTo(self,soundEnabled,@YES)                              = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"soundEnabled"];
        RACChannelTo(self,notificationType,@(SettingsNotificationStatus)) = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"notificationType"];
        RACChannelTo(self,notificationWriteMessageEnabled,@YES)           = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"notificationWriteMessageEnabled"];
        RACChannelTo(self,notificationLikeYourPointEnabled,@YES)          = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"notificationLikeYourPointEnabled"];
        RACChannelTo(self,notificationPointTimeIsUpEnabled,@YES)          = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"notificationPointTimeIsUpEnabled"];
        RACChannelTo(self,applicationCode,@"")                            = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"applicationCode"];
    }
    return self;
}
@end

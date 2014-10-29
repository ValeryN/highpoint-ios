//
//  HPAdditionalUserInfoManager.m
//  HighPoint
//
//  Created by Eugen Antropov on 29/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAdditionalUserInfoManager.h"
#import "City.h"
#import "HPRequest+GeoLocations.h"

@interface HPAdditionalUserInfoManager()
@property (nonatomic, retain) NSMutableDictionary* cityToLoad;
@end

@implementation HPAdditionalUserInfoManager

static HPAdditionalUserInfoManager *additionalManager;

+ (HPAdditionalUserInfoManager *)instance {
    @synchronized (self) {
        static dispatch_once_t onceToken;
        if (!additionalManager) {
            dispatch_once(&onceToken, ^{
                additionalManager = [[HPAdditionalUserInfoManager alloc] init];
            });
        }
        return additionalManager;
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cityToLoad = [NSMutableDictionary new];
        [[[RACObserve(self, cityToLoad) filter:^BOOL(NSDictionary* value) {
            return [value.allValues containsObject:[NSNull null]];
        }] throttle:0.1] subscribeNext:^(NSDictionary* x) {
            NSArray* citiesIds = [x keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
                return [obj isEqual:[NSNull null]];
            }].allObjects;
            [[HPRequest getCitiesById:citiesIds] subscribeNext:^(NSArray* x) {
                [self willChangeValueForKey:@"cityToLoad"];
                for(City* city in x){
                    [self.cityToLoad setObject:city forKey:city.cityId];
                }
                [self didChangeValueForKey:@"cityToLoad"];
            }];
        }];
        
    }
    return self;
}

- (RACSignal*) getCitySignalForId:(NSNumber*) cityId{
    City* city = [City MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"cityId = %@",cityId] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if(city)
        return [RACSignal return:city];
    else{
        if(![self.cityToLoad objectForKey:cityId])
        {
            [self willChangeValueForKey:@"cityToLoad"];
            [self.cityToLoad setObject:[NSNull null] forKey:cityId];
            [self didChangeValueForKey:@"cityToLoad"];
        }
        return [[[RACObserve(self, cityToLoad) filter:^BOOL(NSDictionary* value) {
            return ![value[cityId] isEqual:[NSNull null]];
        }] map:^id(NSDictionary* value) {
            return value[cityId];
        }] take:1];
    }
}

@end

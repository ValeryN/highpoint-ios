//
//  DataStorage.m
//  HightPoint
//
//  Created by Andrey Anisimov on 07.07.13.
//  Copyright (c) 2013 Andrey Anisimov. All rights reserved.
//

#import "DataStorage.h"
#import "HPAppDelegate.h"

static DataStorage *dataStorage;
@implementation DataStorage
+(DataStorage*) sharedDataStorage{
    @synchronized (self){
        static dispatch_once_t onceToken;
        if (!dataStorage){
            dispatch_once(&onceToken, ^{
                dataStorage = [[DataStorage alloc] init];
                dataStorage.moc = ((HPAppDelegate*)[[UIApplication sharedApplication] delegate]).managedObjectContext;
            });
        }
        return dataStorage;
    }
}
@end

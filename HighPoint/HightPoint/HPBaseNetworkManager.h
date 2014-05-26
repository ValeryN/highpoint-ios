//
//  HPBaseNetworkManager.h
//  HightPoint
//
//  Created by Andrey Anisimov on 22.04.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HPBaseNetworkManager : NSObject
+ (HPBaseNetworkManager*) sharedNetworkManager;
- (void) startNetworkStatusMonitor;
- (void) setNetworkStatusMonitorCallback;
@end

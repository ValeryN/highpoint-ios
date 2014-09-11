//
//  HPBaseNetworkManager+AuthorizationAndRegistration.h
//  HighPoint
//
//  Created by Andrey Anisimov on 10.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (AuthorizationAndRegistration)
- (void) makeAutorizationRequest:(NSDictionary*) param;
- (void) makeRegistrationRequest:(NSDictionary*) param;
@end

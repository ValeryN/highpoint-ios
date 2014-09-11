//
//  HPBaseNetworkManager+Reference.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (Reference)
- (void) makeReferenceRequest:(NSDictionary*) param;
- (void) findPostsRequest:(NSDictionary*) param;
- (void) findCompaniesRequest:(NSDictionary*) param;
- (void) findLanguagesRequest:(NSDictionary*) param;
- (void) findPlacesRequest:(NSDictionary*) param;
- (void) findSchoolsRequest:(NSDictionary*) param;
- (void) findSpecialitiesRequest:(NSDictionary*) param;
@end

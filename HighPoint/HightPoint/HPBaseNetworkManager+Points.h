//
//  HPBaseNetworkManager+Points.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (Points)
- (void) getPointsRequest:(NSInteger) lastPoint;
- (void) getPointLikesRequest: (NSNumber *) pointId;
- (void) makePointLikeRequest:(NSNumber*) pointId;
- (void) makePointUnLikeRequest:(NSNumber*) pointId;
@end

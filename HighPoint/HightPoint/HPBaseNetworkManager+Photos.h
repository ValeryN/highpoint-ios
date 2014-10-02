//
//  HPBaseNetworkManager+Photos.h
//  HighPoint
//
//  Created by Andrey Anisimov on 11.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBaseNetworkManager.h"

@interface HPBaseNetworkManager (Photos)
- (void) deletePhotoRequest : (NSNumber *) photoId;
- (void) addPhotoRequest:(UIImage*) image andPhotoId:(NSNumber*) id_;
@end

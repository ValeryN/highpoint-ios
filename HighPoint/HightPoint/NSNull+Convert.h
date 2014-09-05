//
//  NSNull+Convert.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 05.09.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (Convert)

- (NSNumber *) convertToNSNumber;
- (NSString *) convertToNSString;


@end

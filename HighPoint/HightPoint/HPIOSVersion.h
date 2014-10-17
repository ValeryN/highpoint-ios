//
//  HPIOSVersion.h
//  scade
//
//  Created by Michael on 05.08.13.
//  Copyright (c) 2013 scade.com. All rights reserved.
//



#import <Foundation/Foundation.h>



@interface HPIOSVersion : NSObject

@property (nonatomic, assign) NSInteger major;
@property (nonatomic, assign) NSInteger minor;
@property (nonatomic, assign) NSInteger revision;

+ (instancetype) shared;

- (BOOL) isIOS4;
- (BOOL) isIOS5;
- (BOOL) isIOS6;
- (BOOL) isIOS7OrGreater;
- (BOOL) isIOS7;

- (NSComparisonResult) compare: (HPIOSVersion*)version;
- (NSComparisonResult) compareWithStringVersion: (NSString*)version __unused;

@end
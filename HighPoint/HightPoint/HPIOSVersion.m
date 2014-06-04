//
//  HPIOSVersion.m
//  scade.com
//
//  Created by Michael on 05.08.13.
//  Copyright (c) 2013 scade. All rights reserved.

//

//==============================================================================

#import "HPIOSVersion.h"
#import "HPLanguageStrings.h"

//==============================================================================

@implementation HPIOSVersion

//==============================================================================

+ (instancetype) shared
{
    static HPIOSVersion* systemVersion = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,
    ^{
        NSString* systemVersionString = [[UIDevice currentDevice] systemVersion];
        systemVersion = [[self alloc] initWithStringRepresentation: systemVersionString];
    });

    return systemVersion;
}

//==============================================================================

- (NSString*) description
{
    NSMutableString* result = [NSMutableString stringWithString: @"version "];
    
    [result appendFormat:@"%i.%i (%i)", _major, _minor, _revision];

    return result;
}

//==============================================================================

#pragma mark - Init -

//==============================================================================

- (id) initWithStringRepresentation: (NSString*)string
{
    self = [super init];
    if (self == nil)
        return nil;
    
    [self parseString:string];
    
    return self;
}

//==============================================================================

#pragma mark - Public -

//==============================================================================

- (BOOL) isIOS4
{
    return _major == 4;
}

//==============================================================================

- (BOOL) isIOS5
{
    return _major == 5;
}

//==============================================================================

- (BOOL) isIOS6
{
    return _major == 6;
}

//==============================================================================

- (BOOL) isIOS7OrGreater
{
    return _major >= 7;
}

//==============================================================================

- (BOOL) isIOS7
{
    return _major == 7;
}

//==============================================================================

- (NSComparisonResult) compare: (HPIOSVersion*)version
{
    if (version == nil)
        return NSOrderedDescending;

    if (_major > version.major)
        return NSOrderedDescending;

    if (_major < version.major)
        return NSOrderedAscending;

    if (_minor > version.minor)
        return NSOrderedDescending;

    if (_minor < version.minor)
        return NSOrderedAscending;

    if (_revision > version.revision)
        return NSOrderedDescending;

    if (_revision < version.revision)
        return NSOrderedAscending;

    return NSOrderedSame;
}

//==============================================================================

- (NSComparisonResult) compareWithStringVersion: (NSString*)version
{
    HPIOSVersion* compareVersion = [[HPIOSVersion alloc] initWithStringRepresentation: version];
    return [self compare: compareVersion];
}

//==============================================================================

#pragma mark - Private -

//==============================================================================

- (void) parseString: (NSString*) string
{
    NSArray *components = [string componentsSeparatedByString: NL(@".")];
    [self validateComponents: components withIndex: 0 andSetIntoValue: &_major];
    [self validateComponents: components withIndex: 1 andSetIntoValue: &_minor];
    [self validateComponents: components withIndex: 2 andSetIntoValue: &_revision];
}

//==============================================================================

- (void) validateComponents: (NSArray*)components withIndex: (NSUInteger)index andSetIntoValue: (NSInteger*)value
{
    if(components.count > index && value)
        *value = [components[index] integerValue];
}

//==============================================================================

@end

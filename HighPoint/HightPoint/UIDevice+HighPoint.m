//
//  UIDevice+HighPoint.m
//  scade.com
//
//  Created by Michael on 05.08.13.
//  Copyright (c) 2013 scade. All rights reserved.
//

//==============================================================================

#include <sys/sysctl.h>

#import "UIDevice+HighPoint.h"
#import "HPLanguageStrings.h"

//==============================================================================

@implementation UIDevice (HighPoint)

//==============================================================================

+ (void) hp_printCommonInfo __unused
{
    [[HPIOSVersion shared] description];
    NSLog(@"Warnign: retina: %@", [UIDevice hp_hasRetina] ? @"YES" : @"NO");
    NSLog(@"Warnign: model: %@", [UIDevice hp_deviceFullName]);
}

//==============================================================================

+ (BOOL) hp_isIpadUI
{
    static BOOL isIPad = NO;
    static dispatch_once_t onceIpadToken;
    dispatch_once(
        &onceIpadToken,
        ^
        {
            isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        });

    return isIPad;
}

//==============================================================================

+ (BOOL) hp_isWideScreen
{
    return (BOOL) (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        fabsf([UIScreen mainScreen].bounds.size.height - 568.f) < FLT_EPSILON);
}

//==============================================================================

+ (BOOL) hp_hasRetina
{
    return [[UIScreen mainScreen] respondsToSelector: @selector(scale)] &&
        [[UIScreen mainScreen] scale] == 2;
}

//==============================================================================

//==============================================================================

#pragma mark - Versions -

//==============================================================================

+ (BOOL) hp_isIOS7
{
    return [[self hp_iosVersion] isIOS7];
}

//==============================================================================

+ (BOOL) hp_isIOS6 __unused
{
    return [[self hp_iosVersion] isIOS6];
}

//==============================================================================

+ (BOOL) hp_isIOS5
{
    return [[self hp_iosVersion] isIOS5];
}

//==============================================================================

+ (BOOL) hp_isIOS4
{
    return [[self hp_iosVersion] isIOS4];
}

//==============================================================================

+ (HPIOSVersion*) hp_iosVersion
{
    return [HPIOSVersion shared];
}

//==============================================================================

#pragma mark - Hardware models -

//==============================================================================

+ (EDeviceFamily) hp_deviceFamily
{
    NSString* platform = [self hardware];
    if ([platform hasPrefix: @"iPhone"])
    {
            return EDEVICEFAMILY_IPHONE;
    }

    if ([platform hasPrefix: @"iPod"])
    {
            return EDEVICEFAMILY_IPOD;
    }

    if ([platform hasPrefix: @"iPad"])
    {
            return EDEVICEFAMILY_IPAD;
    }

    if ([platform hasPrefix: @"AppleTV"])
    {
            return EDEVICEFAMILY_TV;
    }

    return EDEVICEFAMILY_UNKNOWN;
}

//==============================================================================

+ (EDevicePlatform) hp_platformType
{
    NSString* platformName = [self hardware];

    // The ever mysterious iFPGA
    if ([platformName isEqualToString: @"iFPGA"])
    {
            return EDEVICEPLATFORM_IFPGA;
    }

    // iPhone
    if ([platformName isEqualToString: @"iPhone1,1"])
    {
            return EDEVICEPLATFORM_1G_IPHONE;
    }

    if ([platformName isEqualToString: @"iPhone1,2"])
    {
            return EDEVICEPLATFORM_3G_IPHONE;
    }

    if ([platformName hasPrefix: @"iPhone2"])
    {
            return EDEVICEPLATFORM_3GS_IPHONE;
    }

    if ([platformName hasPrefix: @"iPhone3"])
    {
            return EDEVICEPLATFORM_4_IPHONE;
    }

    if ([platformName hasPrefix: @"iPhone4"])
    {
            return EDEVICEPLATFORM_4S_IPHONE;
    }

    if ([platformName hasPrefix: @"iPhone5"])
    {
            return EDEVICEPLATFORM_5_IPHONE;
    }

    // iPod
    if ([platformName hasPrefix: @"iPod1"])
    {
            return EDEVICEPLATFORM_1G_IPOD;
    }

    if ([platformName hasPrefix: @"iPod2"])
    {
            return EDEVICEPLATFORM_2G_IPOD;
    }

    if ([platformName hasPrefix: @"iPod3"])
    {
            return EDEVICEPLATFORM_3G_IPOD;
    }

    if ([platformName hasPrefix: @"iPod4"])
    {
            return EDEVICEPLATFORM_4G_IPOD;
    }

    // iPad
    if ([platformName hasPrefix: @"iPad1"])
    {
            return EDEVICEPLATFORM_1G_IPAD;
    }

    if ([platformName hasPrefix: @"iPad2"])
    {
            return EDEVICEPLATFORM_2G_IPAD;
    }

    if ([platformName hasPrefix: @"iPad3"])
    {
            return EDEVICEPLATFORM_3G_IPAD;
    }

    if ([platformName hasPrefix: @"iPad4"])
    {
            return EDEVICEPLATFORM_4G_IPAD;
    }

    // Apple TV
    if ([platformName hasPrefix: @"AppleTV2"])
    {
            return EDEVICEPLATFORM_TV_2;
    }

    if ([platformName hasPrefix: @"AppleTV3"])
    {
            return EDEVICEPLATFORM_TV_3;
    }

    if ([platformName hasPrefix: @"iPhone"])
    {
            return EDEVICEPLATFORM_UNKNOWN_IPHONE;
    }

    if ([platformName hasPrefix: @"iPod"])
    {
            return EDEVICEPLATFORM_UNKNOWN_IPOD;
    }

    if ([platformName hasPrefix: @"iPad"])
    {
            return EDEVICEPLATFORM_UNKNOWN_IPAD;
    }

    if ([platformName hasPrefix: @"AppleTV"])
    {
            return EDEVICEPLATFORM_UNKNOWN_TV;
    }

    // Simulator thanks Jordan Breeding
    if ([platformName hasSuffix: @"86"] || [platformName isEqual: @"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? EDEVICEPLATFORM_SIMULATOR_IPHONE : EDEVICEPLATFORM_SIMULATOR_IPAD;
    }

    return EDEVICEPLATFORM_UNKNOWN;
}

//==============================================================================

+ (BOOL) hp_isSimulator __unused
{
    EDevicePlatform platform = [self hp_platformType];
    if (platform < EDEVICEPLATFORM_1G_IPHONE)
    {
            return YES;
    }

    return NO;
}

//==============================================================================

+ (NSString*) hp_deviceFullName
{
    NSString* fullName = [UIDevice hardware];

    if ([fullName isEqualToString: NL(@"iPhone1,1")])
    {
            return NL(@"iPhone 1G");
    }

    if ([fullName isEqualToString: NL(@"iPhone1,2")])
    {
            return NL(@"iPhone 3G");
    }

    if ([fullName isEqualToString: NL(@"iPhone2,1")])
    {
            return NL(@"iPhone 3GS");
    }

    if ([fullName isEqualToString: NL(@"iPhone3,1")])
    {
            return NL(@"iPhone 4");
    }

    if ([fullName isEqualToString: NL(@"iPhone3,3")])
    {
            return NL(@"Verizon iPhone 4");
    }

    if ([fullName isEqualToString: NL(@"iPhone4,1")])
    {
            return NL(@"iPhone 4S");
    }

    if ([fullName isEqualToString: NL(@"iPhone5,2")])
    {
            return NL(@"iPhone 5");
    }

    if ([fullName isEqualToString: NL(@"iPod1,1")])
    {
            return NL(@"iPod Touch 1G");
    }

    if ([fullName isEqualToString: NL(@"iPod2,1")])
    {
            return NL(@"iPod Touch 2G");
    }

    if ([fullName isEqualToString: NL(@"iPod3,1")])
    {
            return NL(@"iPod Touch 3G");
    }

    if ([fullName isEqualToString: NL(@"iPod4,1")])
    {
            return NL(@"iPod Touch 4G");
    }

    if ([fullName isEqualToString: NL(@"iPad1,1")])
    {
            return NL(@"iPad");
    }

    if ([fullName isEqualToString: NL(@"iPad2,1")])
    {
            return NL(@"iPad 2 (WiFi)");
    }

    if ([fullName isEqualToString: NL(@"iPad2,2")])
    {
            return NL(@"iPad 2 (GSM)");
    }

    if ([fullName isEqualToString: NL(@"iPad2,3")])
    {
            return NL(@"iPad 2 (CDMA)");
    }

    if ([fullName isEqualToString: NL(@"i386")])
    {
            return NL(@"Simulator");
    }

    if ([fullName isEqualToString: NL(@"x86_64")])
    {
            return NL(@"Simulator");
    }

    return fullName;
}

//==============================================================================

+ (NSString*) hp_currentLocale
{
    NSLocale* locale = [NSLocale currentLocale];
    NSString* countryCode = [[locale objectForKey: NSLocaleCountryCode] lowercaseString];
    NSString* languageCode = [[locale objectForKey: NSLocaleLanguageCode] lowercaseString];

    return [NSString stringWithFormat: @"%@-%@", languageCode, countryCode];
}

//==============================================================================

+ (NSString*) hp_carrierName
{
    CTTelephonyNetworkInfo* netinfo = [CTTelephonyNetworkInfo new];
    CTCarrier* carrier = [netinfo subscriberCellularProvider];

    return carrier.carrierName ?: NL(@"SimCarrier");
}


//==============================================================================

#pragma mark - Private section -

//==============================================================================

+ (NSString*) sysInfoByName: (char*) typeSpecifier
{
    size_t size = 0;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);

    char* answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);

    NSString* results = [NSString stringWithCString: answer encoding: NSUTF8StringEncoding];
    free(answer);

    return results;
}

//==============================================================================

+ (NSString*) hardware
{
    return [self sysInfoByName: "hw.machine"];
}

//==============================================================================

+ (BOOL) hp_onlyHaveSpeaker
{
    NSString* deviceType = [UIDevice currentDevice].model;

    if ([deviceType isEqualToString: @"iPhone"])
    {
        return NO;
    }

    return YES;
}
@end

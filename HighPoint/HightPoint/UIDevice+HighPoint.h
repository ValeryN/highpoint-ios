//
//  UIDevice+HighPoint.h
//  scade.com
//
//  Created by Michael on 05.08.13.
//  Copyright (c) 2013 scade. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "HPIOSVersion.h"



typedef enum
{
	EDEVICEFAMILY_IPHONE,
	EDEVICEFAMILY_IPOD,
	EDEVICEFAMILY_IPAD,
	EDEVICEFAMILY_TV,
	EDEVICEFAMILY_UNKNOWN
} EDeviceFamily;

typedef enum
{
	EDEVICEPLATFORM_SIMULATOR,
	EDEVICEPLATFORM_SIMULATOR_IPHONE,
	EDEVICEPLATFORM_SIMULATOR_IPAD,
	EDEVICEPLATFORM_SIMULATOR_TV,


	EDEVICEPLATFORM_1G_IPHONE,
	EDEVICEPLATFORM_3G_IPHONE,
	EDEVICEPLATFORM_3GS_IPHONE,
	EDEVICEPLATFORM_4_IPHONE,
	EDEVICEPLATFORM_4S_IPHONE,
	EDEVICEPLATFORM_5_IPHONE,

	EDEVICEPLATFORM_1G_IPOD,
	EDEVICEPLATFORM_2G_IPOD,
	EDEVICEPLATFORM_3G_IPOD,
	EDEVICEPLATFORM_4G_IPOD,

	EDEVICEPLATFORM_1G_IPAD,
	EDEVICEPLATFORM_2G_IPAD,
	EDEVICEPLATFORM_3G_IPAD,
	EDEVICEPLATFORM_4G_IPAD,

	EDEVICEPLATFORM_TV_2,
	EDEVICEPLATFORM_TV_3,
	EDEVICEPLATFORM_TV_4,

	EDEVICEPLATFORM_UNKNOWN_IPHONE,
	EDEVICEPLATFORM_UNKNOWN_IPOD,
	EDEVICEPLATFORM_UNKNOWN_IPAD,
	EDEVICEPLATFORM_UNKNOWN_TV,
    
	EDEVICEPLATFORM_IFPGA,

	EDEVICEPLATFORM_UNKNOWN
} EDevicePlatform; 


@interface UIDevice (HighPoint)

+ (void) hp_printCommonInfo __unused;

+ (BOOL) hp_isIOS7;
+ (BOOL) hp_isIOS6 __unused;
+ (BOOL) hp_isIOS5;
+ (BOOL) hp_isIOS4;
+ (HPIOSVersion*) hp_iosVersion;

+ (BOOL) hp_hasRetina;
+ (EDeviceFamily) hp_deviceFamily __unused;
+ (EDevicePlatform) hp_platformType;
+ (NSString*) hp_deviceFullName;

+ (BOOL) hp_isWideScreen;
+ (BOOL) hp_isIpadUI;
+ (BOOL) hp_isSimulator __unused;


+ (NSString*) hp_carrierName;
+ (NSString*) hp_currentLocale;

+ (BOOL) hp_onlyHaveSpeaker;
@end

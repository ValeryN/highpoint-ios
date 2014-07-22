//
//  Constants.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#ifndef HightPoint_Constants_h
#define HightPoint_Constants_h

static float const iPhone5ScreenHight = 568.0;
static float const iPhone4ScreenHight = 480.0;
static float const iPhoneScreenWidth = 320.0;
static float const mainScreenSwitchHeight = 32.0;
static float const mainScreenSwitchToBottom_568 = 20.0;
static float const mainScreenSwitchToBottom_480 = 16.0;
static float const mainScreenSwitchToLeft = 64;
static float const mainScreenSwitchWidth = 193;
static float const timeLabelWidth = 100;

//http request constants
static NSString * const kApplicationSettingsRequest = @"/v201405/settings";
static NSString * const kCurrentUserRequest = @"/v201405/me";
static NSString * const kCurrentUserFilter = @"/v201405/me/filter";
static NSString * const kUsersRequest = @"/v201405/users";
static NSString * const kGeoLocationRequest = @"/v201405/geo";
static NSString * const kGeoLocationFindRequest = @"/v201405/geo/find";
static NSString * const kPointsRequest = @"/v201405/points";
static NSString * const kRegistrationRequest = @"/v201405/signup";
static NSString * const kSigninRequest = @"/v201405/signin";
static NSString * const kPointsLikeRequest = @"/v201405/points/%@/like";
static NSString * const kPointsUnlikeRequest = @"/v201405/points/%@/unlike";
static NSString * const kCareerRequest = @"/v201405/me/career";
static NSString * const kLanguagesRequest = @"/v201405/me/languages";
static NSString * const kPlasesRequest = @"/v201405/me/places";
static NSString * const kEducationRequest = @"/v201405/me/education";
static NSString * const kReferenceRequest = @"/v201405/reference";
static NSString * const kPostsFindRequest = @"/v201405/reference/career-posts/find";
static NSString * const kCompaniesFindRequest = @"/v201405/reference/companies/find";
static NSString * const kLanguagesFindRequest = @"/v201405/reference/languages/find";
static NSString * const kPlacesFindRequest = @"/v201405/reference/places/find";

//socket io constants
static NSString * const kSendMessage = @"sendMessage";
static NSString * const kActivityEnd = @"activityEnd";
static NSString * const kActivityStart = @"activityStart";
static NSString * const kMessagesRead = @"messagesRead";
static NSString * const kTypingFinish = @"typingFinish";
static NSString * const kTypingStart = @"typingStart";
static NSString * const kNotificationRead = @"notificationRead";
static NSString * const kAllNotificationRead = @"allNotificationsRead";
static NSString * const kMeUpdate = @"meUpdate";
static NSString * const kMessage = @"message";



#endif

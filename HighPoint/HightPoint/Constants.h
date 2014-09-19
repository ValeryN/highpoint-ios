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
static NSString * const kCurrentUserFilter = @"/v201405/me/filter/update";
static NSString * const kUsersRequest = @"/v201405/users";
static NSString * const kGeoLocationRequest = @"/v201405/geo";
static NSString * const kGeoLocationFindRequest = @"/v201405/geo/cities/find";
static NSString * const kPointsRequest = @"/v201405/points";
static NSString * const kRegistrationRequest = @"/v201405/signup";
static NSString * const kSigninRequest = @"/v201405/signin";
static NSString * const kPointsLikeRequest = @"/v201405/points/%@/like";
static NSString * const kPointsUnlikeRequest = @"/v201405/points/%@/unlike";
static NSString * const kCareerAddRequest = @"/v201405/me/career/add";
static NSString * const kCareerDeleteRequest = @"/v201405/me/career/remove";
static NSString * const kLanguagesAddRequest = @"/v201405/me/languages/add";
static NSString * const kLanguagesDeleteRequest = @"/v201405/me/languages/remove";
static NSString * const kPlasesAddRequest = @"/v201405/me/places/add";
static NSString * const kPlasesDeleteRequest = @"/v201405/me/places/remove";
static NSString * const kEducationAddRequest = @"/v201405/me/education/add";
static NSString * const kEducationDeleteRequest = @"/v201405/me/education/remove";
static NSString * const kReferenceRequest = @"/v201405/reference";
static NSString * const kPostsFindRequest = @"/v201405/reference/career-posts/find";
static NSString * const kCompaniesFindRequest = @"/v201405/reference/companies/find";
static NSString * const kLanguagesFindRequest = @"/v201405/reference/languages/find";
static NSString * const kPlacesFindRequest = @"/v201405/reference/places/find";
static NSString * const kSchoolsFindRequest = @"/v201405/reference/schools/find";
static NSString * const kSpecialityFindRequest = @"/v201405/reference/specialities/find";
static NSString * const kGetContactsRequest = @"/v201405/contacts";
static NSString * const kContactDeleteRequest = @"/v201405/contacts/%@/remove";
static NSString * const kUserMessagesRequest = @"/v201405/users/%@/messages";
static NSString * const kUnreadMessagesRequest = @"/v201405/messages/unread";
static NSString * const kSendMessageToUserRequest = @"/v201405/users/%@/messages/add";
static NSString * const kSendMessagesToUserRequest = @"/v201405/users/%@/messages/add";
static NSString * const kPopularCitiesRequest = @"/v201405/geo/cities/popular";
static NSString * const kPointLikesRequest = @"/v201405/points/%@/liked";
static NSString * const kUserInfoRequest = @"/v201405/users/%@";
static NSString * const kUploadAvatarRequest = @"/v201405/me/avatar/add";
static NSString * const kDeletePhotoRequest = @"/v201405/photos/%@/remove";
static NSString * const kGetUserPhotoRequest = @"/v201405/me/photos";
static NSString * const kSetUserAvatarCrop = @"/v201405/me/avatar/crop";
static NSString * const kUserPhotosSort =  @"/v201405/me/photos/sort";

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


//other
#define months [NSArray arrayWithObjects: @"января", @"февраля",@"марта",@"апреля", @"мая",@"июня",@"июля", @"августа",@"сентября",@"октября", @"ноября",@"декабря", nil]


#endif

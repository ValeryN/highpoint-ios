//
//  HPUserCardOrPoint.m
//  HighPoint
//
//  Created by Michael on 23.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserCardOrPoint.h"
#import "UserPoint.h"
#import "City.h"

//==============================================================================

@implementation HPUserCardOrPoint

//==============================================================================

- (id) init
{
    self = [super init];
    
    if (self == nil)
        return nil;
    
    _isUserPointView = YES;
    
    return self;
}


- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPUserPointView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPUserPointView class]] == NO)
        return nil;
    
    HPUserPointView* newPoint = (HPUserPointView*)nibs[0];
    newPoint.delegate = delegate;
    newPoint.pointDelegate = delegate;
    newPoint.name.text = user.name;
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    newPoint.details.text = [NSString stringWithFormat:@"%@ лет, %@", user.age, cityName];
    UserPoint *point = user.point;
    newPoint.pointText.text = point.pointText;
    [newPoint.heartLike setSelected:[point.pointLiked boolValue]];
    [newPoint initObjects];
    return newPoint;
}


- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPUserCardView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPUserCardView class]] == NO)
        return nil;
    
    HPUserCardView* newCard = (HPUserCardView*)nibs[0];
    newCard.delegate = delegate;
    
    NSLog(@"avatar url = %@", user.avatar.highImageSrc);
    
    NSString *avatarUrlStr = user.avatar.highImageSrc.length > 0 ? [user.avatar.highImageSrc stringByAppendingString:@"?size=s640&ext=jpg"] : @"";
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString: avatarUrlStr]
                                                        options:0
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             newCard.backgroundAvatar.image = image;
         } else {
             //TODO: set placeholder img
             NSLog(@"error image log = %@", error.description);
         }
     }];
    
    
    newCard.name.text = user.name;
    NSString *cityName = user.city.cityName ? user.city.cityName : NSLocalizedString(@"UNKNOWN_CITY_ID", nil);
    newCard.details.text = [NSString stringWithFormat:@"%@ лет, %@", user.age, cityName];
    [newCard initObjects];

    return newCard;
}


- (BOOL) switchUserPoint
{
    _isUserPointView = !_isUserPointView;
    return _isUserPointView;
}


- (BOOL) isUserPoint
{
    return _isUserPointView;
}


@end

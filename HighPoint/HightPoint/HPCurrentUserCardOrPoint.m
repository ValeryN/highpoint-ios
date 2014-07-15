//
//  HPCurrentUserCardOrPoint.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 11.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPCurrentUserCardOrPoint.h"
#import "HPCurrentUserPointView.h"
#import "HPCurrentUserCardView.h"
#import "SDWebImageManager.h"
#import "Avatar.h"

@implementation HPCurrentUserCardOrPoint

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
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPCurrentUserPointView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPCurrentUserPointView class]] == NO)
        return nil;
    
    HPCurrentUserPointView* newPoint = (HPCurrentUserPointView*)nibs[0];
    newPoint.delegate = delegate;
    
    
    
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
             newPoint.bgAvatarImageView.image = image;
             [newPoint setCropedAvatar:image];
         } else {
             //TODO: set placeholder img
             NSLog(@"error image log = %@", error.description);
         }
         [newPoint setBlurForAvatar];
     }];
    [newPoint initObjects];
    return newPoint;
}



- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPCurrentUserCardView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPCurrentUserCardView class]] == NO)
        return nil;
    
    HPCurrentUserCardView* newCard = (HPCurrentUserCardView*)nibs[0];
    newCard.delegate = delegate;
    
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
             newCard.avatarBgImageView.image = image;
         } else {
             //TODO: set placeholder img
             NSLog(@"error image log = %@", error.description);
         }
     }];
    
    
    [self setVisibility:user card:newCard];
    
    newCard.nameLabel.text = user.name;
    newCard.ageAndCitylabel.text = [NSString stringWithFormat:@"%@, %@", user.age, user.cityId];
    [newCard initObjects];
    
    return newCard;
}


#pragma mark - set visibility

- (void) setVisibility :(User *) user card: (HPCurrentUserCardView *)cardView{
    NSLog(@"visibility = %@",user.visibility);
    if ([user.visibility intValue] == 1) {
        cardView.visibilityLabel.text = NSLocalizedString(@"YOUR_PROFILE_VISIBLE", nil);
        cardView.visibilityInfoLabel.hidden = YES;
        cardView.nameLabel.hidden = NO;
        cardView.ageAndCitylabel.hidden = NO;
        cardView.visibleBtn.selected = YES;
        cardView.invisibleBtn.selected = NO;
        cardView.lockBtn.selected = NO;
    }
    if ([user.visibility intValue] == 2) {
        cardView.visibilityLabel.text = NSLocalizedString(@"YOUR_PROFILE_INVISIBLE", nil);
        cardView.visibilityInfoLabel.text = NSLocalizedString(@"YOUR_PROFILE_INVISIBLE_INFO", nil);
        cardView.visibilityInfoLabel.hidden = NO;
        cardView.nameLabel.hidden = YES;
        cardView.ageAndCitylabel.hidden = YES;
        cardView.visibleBtn.selected = NO;
        cardView.invisibleBtn.selected = YES;
        cardView.lockBtn.selected = NO;
        //invisible
    }
    if ([user.visibility intValue] == 3) {
        cardView.visibilityLabel.text = NSLocalizedString(@"YOUR_PROFILE_LOCKED", nil);
        cardView.visibilityInfoLabel.text = NSLocalizedString(@"YOUR_PROFILE_LOCKED_INFO", nil);
        cardView.visibilityInfoLabel.hidden = NO;
        cardView.nameLabel.hidden = YES;
        cardView.ageAndCitylabel.hidden = YES;
        cardView.visibleBtn.selected = NO;
        cardView.invisibleBtn.selected = NO;
        cardView.lockBtn.selected = YES;
        //locked
    }
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

//==============================================================================


@end

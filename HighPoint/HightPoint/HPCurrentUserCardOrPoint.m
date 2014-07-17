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

#pragma mark - init sides

- (UIView*) userPointWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPCurrentUserPointView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPCurrentUserPointView class]] == NO)
        return nil;
    
    self.pointView = (HPCurrentUserPointView*)nibs[0];
    self.pointView.delegate = delegate;
    
    
    
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
             self.pointView.bgAvatarImageView.image = image;
             [self.pointView setCropedAvatar:image];
         } else {
             //TODO: set placeholder img
             NSLog(@"error image log = %@", error.description);
         }
         [self.pointView setBlurForAvatar];
     }];
    [self.pointView initObjects];
    return self.pointView;
}



- (UIView*) userCardWithDelegate: (NSObject<UserCardOrPointProtocol>*) delegate user: (User*) user
{
    NSArray* nibs = [[NSBundle mainBundle] loadNibNamed: @"HPCurrentUserCardView" owner: self options: nil];
    if ([nibs[0] isKindOfClass:[HPCurrentUserCardView class]] == NO)
        return nil;
    self.cardView = (HPCurrentUserCardView*)nibs[0];
    self.cardView.delegate = delegate;
    
    NSString *avatarUrlStr = user.avatar.highImageSrc.length > 0 ? [user.avatar.highImageSrc stringByAppendingString:@"?size=s640&ext=jpg"] : @"";
    NSLog(@"current avatar = %@", avatarUrlStr);
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
             self.cardView.avatarBgImageView.image = image;
         } else {
             //TODO: set placeholder img
             NSLog(@"error image log = %@", error.description);
         }
     }];
    
    
    [self setVisibility:user card:self.cardView];
    
    self.cardView.nameLabel.text = user.name;
    self.cardView.ageAndCitylabel.text = [NSString stringWithFormat:@"%@, %@", user.age, user.cityId];
    [self.cardView initObjects];
    
    return self.cardView;
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


#pragma mark - add modal views
- (void) addPointInfoView: (NSObject<UserCardOrPointProtocol>*) delegate {
    self.pointView.publishPointBtn.hidden = YES;
    self.pointView.pointOptionsView.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.pointView.frame = CGRectMake(self.pointView.frame.origin.x, self.pointView.frame.origin.y - 70, self.pointView.frame.size.width, self.pointView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"point info added");
                         if ([delegate respondsToSelector:@selector(configureSendPointNavigationItem)]) {
                             [delegate configureSendPointNavigationItem];
                         }
                     }];
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

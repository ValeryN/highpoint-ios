//
//  HPAvatar.m
//  HighPoint
//
//  Created by Michael on 26.06.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#define IMAGE_PLACEHOLDER @"img_sample1.png"

#import "HPAvatarView.h"
#import "UIImage+HighPoint.h"
#import "User.h"
#import "User+UserImage.h"

//==============================================================================
@interface HPAvatarView()
@property (nonatomic, weak) IBOutlet UIView* mainView;
@property (nonatomic, weak) IBOutlet UIImageView* avatar;
@property (nonatomic, weak) IBOutlet UIImageView* avatarBorder;
@property (nonatomic, retain) UIImage * borderGreen;
@property (nonatomic, retain) UIImage * borderRed;
@end
@implementation HPAvatarView

//==============================================================================

+ (HPAvatarView*) avatarViewWithUser:(User*) user
{
    HPAvatarView* avatarView = [[self alloc] initWithFrame:(CGRect){0,0,88,88}];
    avatarView.user = user;
    return avatarView;
}

//==============================================================================

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void) sharedInit{
    [[NSBundle mainBundle] loadNibNamed: @"HPAvatarView" owner: self options: nil];
    self.mainView.frame = (CGRect){0,0,self.frame.size};
    [self addSubview:self.mainView];

    RAC(self,avatar.image) = [[[[[RACObserve(self, user) distinctUntilChanged] filter:^BOOL(id value) {
        return value!=nil;
    }] flattenMap:^RACStream *(User *value) {
        return [[RACSignal combineLatest:@[[RACSignal return:value.visibility], [[value userImageSignal] takeUntil:[RACObserve(self, user) skip:1]]]] deliverOn:[RACScheduler scheduler]];
    }] map:^id(RACTuple *value) {
        RACTupleUnpack(NSNumber *visibility, UIImage *userAvatar) = value;
        switch ((UserVisibilityType) visibility.intValue) {
            case UserVisibilityVisible:
                return userAvatar;
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return [userAvatar hp_imageWithGaussianBlur:10];
        }
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]];

    @weakify(self);
    [RACObserve(self.avatar, bounds) subscribeNext:^(id x) {
        @strongify(self);
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = self.avatar.bounds;
        [maskLayer setContents:(id)[[UIImage imageNamed: @"Userpic-Mask"] resizeImageToSize:self.avatar.bounds.size].CGImage];
        self.avatar.layer.mask = maskLayer;
    }];


    self.borderGreen = [UIImage imageNamed:@"Userpic Shape Green"];
    self.borderRed = [UIImage imageNamed:@"Userpic Shape Red"];
    RAC(self,avatarBorder.image) = [[[RACObserve(self, user.online) deliverOn:[RACScheduler scheduler]] map:^id(NSNumber * online) {
        @strongify(self);
        if(online.boolValue){
            return self.borderGreen;
        }
        else{
            return self.borderRed;
        }
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}


@end

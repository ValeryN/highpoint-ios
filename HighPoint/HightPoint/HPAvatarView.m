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
@property (nonatomic, retain) UIImage* maskLayer;
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
    @weakify(self);

    RACSignal * changeUserSignal = [[RACObserve(self,user) filter:^BOOL(id value) {
        return value!=nil;
    }] replayLast];

    RACSignal * changeUserVisibilitySignal = [[changeUserSignal  map:^id(User *value) {
        return value.visibility;    }]  replayLast];
    RACSignal * changeUserOnlineSignal = [[changeUserSignal map:^id(User *value) {
        return value.online;
    }] replayLast];

    RAC(self,avatar.image) = [[[[[[changeUserSignal deliverOn:[RACScheduler scheduler]]  flattenMap:^RACStream *(User* value) {
        return [RACSignal combineLatest:@[[value userImageSignal],changeUserVisibilitySignal,[RACSignal return:value]]];
    }]  map:^id(RACTuple * tuple) {
        RACTupleUnpack(UIImage *userAvatar,NSNumber *visibility,User* user) = tuple;
        switch ((UserVisibilityType) visibility.intValue) {
            case UserVisibilityVisible:
                return RACTuplePack(userAvatar, user);
            case UserVisibilityBlur:
            case UserVisibilityHidden:
                return RACTuplePack([userAvatar hp_imageWithGaussianBlur:10], user);
        }
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]] takeUntilBlock:^BOOL(RACTuple* tuple) {
        @strongify(self);
        RACTupleUnpack(UIImage *userAvatar,User* user) = tuple;
        return ![self.user isEqual:user];
    }]  map:^id(RACTuple* tuple) {
        RACTupleUnpack(UIImage *userAvatar,User* user) = tuple;
        return userAvatar;
    }];

    
    [RACObserve(self.avatar, bounds) subscribeNext:^(id x) {
        @strongify(self);
        CALayer *maskLayer = [CALayer layer];
        maskLayer.frame = self.avatar.bounds;
        [maskLayer setContents:(id)[[UIImage imageNamed: @"Userpic-Mask"] resizeImageToSize:self.avatar.bounds.size].CGImage];
        self.avatar.layer.mask = maskLayer;
    }];


    self.borderGreen = [UIImage imageNamed:@"Userpic Shape Green"];
    self.borderRed = [UIImage imageNamed:@"Userpic Shape Red"];
    RAC(self,avatarBorder.image) = [[changeUserOnlineSignal map:^id(NSNumber * online) {
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

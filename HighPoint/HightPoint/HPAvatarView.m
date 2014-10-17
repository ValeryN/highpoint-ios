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


- (void)prepareForInterfaceBuilder{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"13" ofType:@"jpg"]];
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = self.bounds;
    [maskLayer setContents:(id)[[UIImage imageWithContentsOfFile:[bundle pathForResource:@"Userpic-Mask" ofType:@"png"]] resizeImageToSize:self.bounds.size].CGImage];
    
    UIImageView* imageView = [[UIImageView alloc]  initWithFrame:self.bounds];
    imageView.image = image;
    imageView.layer.mask = maskLayer;
    imageView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:imageView];
}


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
#ifndef TARGET_INTERFACE_BUILDER
        [self sharedInit];
#endif
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#ifndef TARGET_INTERFACE_BUILDER
        [self sharedInit];
#endif
    }
    return self;
}

- (void) sharedInit{
    [[NSBundle mainBundle] loadNibNamed: @"HPAvatarView" owner: self options: nil];
    self.mainView.frame = (CGRect){0,0,self.frame.size};
    [self addSubview:self.mainView];
    @weakify(self);

    RACSignal * prepareForReuse = [self rac_signalForSelector:@selector(setUser:)];
    RACSignal * changeUserSignal = [RACObserve(self,user) replayLast];
    RACSignal * changeUserOnlineSignal = [[changeUserSignal map:^id(User *value) {
        return value.online;
    }] replayLast];

    RAC(self,avatar.image) = [changeUserSignal flattenMap:^RACStream *(User* value) {
        if(value != nil)
            return [[value userImageSignal] takeUntil:prepareForReuse];
        else
            return [RACSignal empty];
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

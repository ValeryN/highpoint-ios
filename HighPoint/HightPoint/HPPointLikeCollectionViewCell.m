//
//  HPPointLikeCollectionViewCell.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPPointLikeCollectionViewCell.h"
#import "User.h"
#import "User+UserImage.h"

@interface HPPointLikeCollectionViewCell()
@property (weak, nonatomic) IBOutlet HPAvatarView *avatarView;
@end

@implementation HPPointLikeCollectionViewCell

#pragma mark - constrains


- (void)bindViewModel:(User*)viewModel {
    self.avatarView.user = viewModel;
}


@end

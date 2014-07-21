//
//  HPPointLikeCollectionViewCell.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 21.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPAvatarView.h"

@interface HPPointLikeCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) HPAvatarView* avatar;
@property (weak, nonatomic) IBOutlet UIView *avatarView;


- (void) configureCell;


@end

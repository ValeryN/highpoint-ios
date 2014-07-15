//
//  HPCurrentUserCardView.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 14.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCardOrPointProtocol.h"

@interface HPCurrentUserCardView : UIView

@property (nonatomic, weak) NSObject<UserCardOrPointProtocol>* delegate;

@property (weak, nonatomic) IBOutlet UILabel *visibilityLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageAndCitylabel;
@property (weak, nonatomic) IBOutlet UIButton *visibleBtn;
@property (weak, nonatomic) IBOutlet UIButton *lockBtn;
@property (weak, nonatomic) IBOutlet UIButton *invisibleBtn;
@property (weak, nonatomic) IBOutlet UILabel *visibilityInfoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarBgImageView;


- (void) initObjects;

@end

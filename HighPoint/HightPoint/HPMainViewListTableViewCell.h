//
//  HPMainViewListTableViewCell.h
//  HightPoint
//
//  Created by Andrey Anisimov on 08.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPMainViewListTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIImageView *showPointButton;
@property (nonatomic, strong) IBOutlet UIImageView *userImage;
@property (nonatomic, strong) IBOutlet UIImageView *userImageBorder;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;
@property (nonatomic, strong) IBOutlet UILabel *secondLabel;
@property (nonatomic, strong) IBOutlet UILabel *point;
@property (nonatomic, strong) IBOutlet UIView *mainInfoGroup;

@end

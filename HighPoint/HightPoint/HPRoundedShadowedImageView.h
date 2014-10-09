//
//  HPRoundedShadowedImageView.h
//  HighPoint
//
//  Created by Eugene on 09/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface HPRoundedShadowedImageView : UIView
@property (nonatomic) IBInspectable UIImage* image;
@property (nonatomic) IBInspectable UIImage* blendImage;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable CGFloat shadowRadius;
@property (nonatomic) IBInspectable CGFloat shadowOpacity;
@property (nonatomic) IBInspectable CGSize shadowOffset;
@end

//
//  UIButton+ExtendedEdges.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 16.10.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ExtendedEdges)

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

-(void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets;

@end

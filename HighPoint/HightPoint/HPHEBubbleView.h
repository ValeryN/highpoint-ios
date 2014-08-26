//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEBubbleView.h"

@class HPBubbleViewDelegate;


@interface HPHEBubbleView : HEBubbleView
@property (nonatomic, retain) NSObject<HEBubbleViewDelegate,HEBubbleViewDataSource>* retainDelegate;
- (void) didHideMenuController;
@end
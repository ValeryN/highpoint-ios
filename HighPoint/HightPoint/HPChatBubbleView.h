//
// Created by Eugene on 17.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger , BubbleType){
    BubbleTypeMine,
    BubbleTypeOther
};

@interface HPChatBubbleView : UIView
@property (nonatomic) BubbleType bubbleType;
@end
//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEBubbleView.h"
#import "HPBubbleTextField.h"


@interface HPBubbleViewDelegate : NSObject <HEBubbleViewDelegate,HEBubbleViewDataSource, HPBubbleTextFieldDelegate, UITextFieldDelegate>
@property (nonatomic, retain) NSArray* dataSource;
@property (nonatomic, retain) NSString* addTextString;

@property (nonatomic, copy) void (^insertTextBlock)(NSString*);
@property (nonatomic, copy) void (^deleteBubbleBlock)(NSManagedObject*);
@end
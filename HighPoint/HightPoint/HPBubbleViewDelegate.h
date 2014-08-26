//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HEBubbleView.h"
#import "HPBubbleTextField.h"

@class HPHEBubbleView;


@interface HPBubbleViewDelegate : NSObject <HEBubbleViewDelegate,HEBubbleViewDataSource, HPBubbleTextFieldDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) HPHEBubbleView* bubbleView;
@property (nonatomic, retain) NSFetchedResultsController* dataSource;
@property (nonatomic, retain) NSString* addTextString;

@property (nonatomic, copy) void (^insertTextBlock)(NSString*);
@property (nonatomic, copy) void (^deleteBubbleBlock)(id);
@property (nonatomic, copy) NSString* (^getTextInfo)(id);

- (instancetype)initWithBubbleView:(HPHEBubbleView *)bubbleView;

+ (instancetype)delegateWithBubbleView:(HPHEBubbleView *)bubbleView;

@end
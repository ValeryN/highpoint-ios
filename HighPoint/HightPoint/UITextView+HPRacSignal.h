//
// Created by Eugene on 19.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextView (HPRacSignal)
- (RACSignal *)rac_textBeginEdit;

- (RACSignal *)rac_textEndEdit;
@end
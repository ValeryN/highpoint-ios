//
//  UITextField+HighPoint.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 23.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UITextField+HighPoint.h"
#import "NSObject+RACDescription.h"
#import "RACDelegateProxy.h"

@implementation UITextField (HighPoint)
static void RACUseDelegateProxy(UITextView*self) {
    if (self.delegate == self.rac_delegateProxy) return;

    self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
    self.delegate = (id)self.rac_delegateProxy;
}

- (void) hp_tuneForSearchTextFieldInContactList :(NSString*) placeholderText
{
    self.font = [UIFont fontWithName: @"FuturaPT-Light" size: 16.0];
    UIColor *textColor = [UIColor colorWithRed: 230.0 / 255.0
                                         green: 236.0 / 255.0
                                          blue: 242.0 / 255.0
                                         alpha: 1.0];
    self.textColor = textColor;
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholderText attributes:@{NSForegroundColorAttributeName: textColor}];
}

- (RACSignal *)rac_textReturnSignal {
    return [[[self rac_signalForControlEvents:UIControlEventEditingDidEndOnExit] takeUntil:self.rac_willDeallocSignal] setNameWithFormat:@"%@ -rac_keyboardReturnSignal", [self rac_description]];
}

- (RACSignal *)rac_isEditing {
    RACSignal * signalStartEditing = [[self rac_signalForControlEvents:UIControlEventEditingDidBegin] map:^id(id value) {
        return @YES;
    }];
    RACSignal * signalStopEditing = [[self rac_signalForControlEvents:UIControlEventEditingDidEndOnExit] map:^id(id value) {
        return @NO;
    }];
    return [[[RACSignal merge:@[signalStartEditing,signalStopEditing]] takeUntil:self.rac_willDeallocSignal] setNameWithFormat:@"%@ -rac_isEditingSignal", [self rac_description]];;
}

@end

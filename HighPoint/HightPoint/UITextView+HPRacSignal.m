//
// Created by Eugene on 19.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "UITextView+HPRacSignal.h"
#import "RACDelegateProxy.h"
#import "NSObject+RACDescription.h"

@implementation UITextView (HPRacSignal)
static void RACUseDelegateProxy(UITextView*self) {
    if (self.delegate == self.rac_delegateProxy) return;

    self.rac_delegateProxy.rac_proxiedDelegate = self.delegate;
    self.delegate = (id)self.rac_delegateProxy;
}

- (RACSignal *)rac_textBeginEdit {
    @weakify(self);
    RACSignal *signal = [[[[[RACSignal
            defer:^{
                @strongify(self);
                return [RACSignal return:RACTuplePack(self)];
            }]
            concat:[self.rac_delegateProxy signalForSelector:@selector(textViewDidBeginEditing:)]]
            reduceEach:^(UITextView *x) {
                return x.text;
            }]
            takeUntil:self.rac_willDeallocSignal]
            setNameWithFormat:@"%@ -rac_textSignal", [self rac_description]];

    RACUseDelegateProxy(self);

    return signal;
}

- (RACSignal *)rac_textEndEdit {
    @weakify(self);
    RACSignal *signal = [[[[[RACSignal
            defer:^{
                @strongify(self);
                return [RACSignal return:RACTuplePack(self)];
            }]
            concat:[self.rac_delegateProxy signalForSelector:@selector(textViewDidEndEditing:)]]
            reduceEach:^(UITextView *x) {
                return x.text;
            }]
            takeUntil:self.rac_willDeallocSignal]
            setNameWithFormat:@"%@ -rac_textSignal", [self rac_description]];

    RACUseDelegateProxy(self);

    return signal;
}
@end
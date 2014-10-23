//
//  UITextField+HighPoint.h
//  HighPoint
//
//  Created by Julia Pozdnyakova on 23.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (HighPoint)

- (void) hp_tuneForSearchTextFieldInContactList :(NSString*) placeholderText;

- (RACSignal *)rac_textReturnSignal;
- (RACSignal *)rac_isEditing;
@end

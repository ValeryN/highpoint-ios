//
//  HPBubbleTextField.h
//  HighPoint
//
//  Created by Andrey Anisimov on 05.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HPBubbleTextFieldDelegate <NSObject>
@optional
- (void)backSpaceTap;
@end

@interface HPBubbleTextField : UITextField <UIKeyInput>
@property (nonatomic, assign) id<HPBubbleTextFieldDelegate> backSpaceDelegate;
@end

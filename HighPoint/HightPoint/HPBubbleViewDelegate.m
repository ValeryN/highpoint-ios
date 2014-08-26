//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBubbleViewDelegate.h"
#import "PSMenuItem.h"


@implementation HPBubbleViewDelegate {

}


- (NSInteger)numberOfItemsInBubbleView:(HEBubbleView *)bubbleView {
    return self.dataSource.count+1;
}

- (NSString*) textStringForIndex:(NSInteger) index inBubbleView:(HEBubbleView *)bubbleView {
    if([self isLastElementForIndex:index inBubbleView:bubbleView])
        return self.addTextString;

    return self.dataSource[(NSUInteger) index];
}

- (BOOL) isLastElementForIndex:(NSInteger) index inBubbleView:(HEBubbleView *)bubbleView{
    return ([self numberOfItemsInBubbleView:bubbleView] - index == 1);
}

- (HEBubbleViewItem *)bubbleView:(HEBubbleView *)bubbleView bubbleItemForIndex:(NSInteger)index {

    NSString *itemIdentifier = @"bubble";

    HEBubbleViewItem *bubble = [bubbleView dequeueItemUsingReuseIdentifier:itemIdentifier];
    UITextField * textField;
    if (!bubble) {
        bubble = [[HEBubbleViewItem alloc] initWithReuseIdentifier:itemIdentifier];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 28)];
        [[RACObserve(bubble.textLabel,frame) distinctUntilChanged] subscribeNext:^(NSValue * x) {
            textField.frame = x.CGRectValue;
        }];
        [bubble insertSubview:textField aboveSubview:bubble.textLabel];
        textField.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textField.textColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        [[textField rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(id x) {
            bubble.textLabel.hidden = YES;
        }];
        [[textField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(UITextField * textField1) {
            if([textField1.text isEqualToString:@""]) {
                bubble.textLabel.hidden = NO;
            }
        }];
        textField.delegate = self;
        @weakify(self);
        [[[self rac_signalForSelector:@selector(textFieldShouldReturn:) fromProtocol:@protocol(UITextFieldDelegate)] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(RACTuple *tuple) {
            @strongify(self);
            RACTupleUnpack(UITextField * textField1) = tuple;
            [self bubbleView:bubbleView insertBubbleWithText:textField1.text];
            textField1.text = @"";
            [textField1 resignFirstResponder];
        }];
        bubble.userInfo[@"textField"] = textField;
    }
    else{
        textField = bubble.userInfo[@"textField"];
    }

    bubble.unselectedBGColor = [UIColor clearColor];
    bubble.textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    if(![self isLastElementForIndex:index inBubbleView:bubbleView]){
        bubble.unselectedBorderColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.3];
        bubble.unselectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        bubble.selectedBorderColor = [UIColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:112.0f/255.0f alpha:1];
        bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
        bubble.selectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        textField.hidden = YES;
    }
    else{
        bubble.unselectedBorderColor = [UIColor clearColor];
        bubble.unselectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.4];
        bubble.selectedBorderColor = [UIColor clearColor];
        bubble.selectedBGColor = [UIColor clearColor];
        bubble.selectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.4];
        textField.hidden = NO;
    }

    bubble.textLabel.text = [self textStringForIndex:index inBubbleView:bubbleView];
    return bubble;
}

-(BOOL)bubbleView:(HEBubbleView *)bubbleView shouldShowMenuForBubbleItemAtIndex:(NSInteger)index
{
    return ![self isLastElementForIndex:index inBubbleView:bubbleView];
}

-(NSArray *)bubbleView:(HEBubbleView *)bubbleView menuItemsForBubbleItemAtIndex:(NSInteger)index
{
    @weakify(self);
    NSNumber *blockInt = @(index);
    PSMenuItem *actionDelete = [[PSMenuItem alloc] initWithTitle:@"Delete" block:^{
        @strongify(self);
        [self bubbleView:bubbleView deleteItemWithIndex:blockInt.integerValue];
    }];
    return @[actionDelete];
}

- (void)bubbleView:(HEBubbleView *)bubbleView deleteItemWithIndex:(NSInteger)index{
     if(self.deleteBubbleBlock)
         self.deleteBubbleBlock;
}

- (void)bubbleView:(HEBubbleView *) bubbleView insertBubbleWithText:(NSString*) text{
    if(self.insertTextBlock)
        self.insertTextBlock(text);
}
@end
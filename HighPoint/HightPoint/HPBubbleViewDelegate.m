//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBubbleViewDelegate.h"
#import "PSMenuItem.h"
#import "HPHEBubbleView.h"
#import "HPHEBubbleViewItem.h"


@implementation HPBubbleViewDelegate {

}

- (instancetype)initWithBubbleView:(HPHEBubbleView *)bubbleView {
    self = [super init];
    if (self) {
        self.bubbleView = bubbleView;
    }

    return self;
}

+ (instancetype)delegateWithBubbleView:(HPHEBubbleView *)bubbleView {
    return [[self alloc] initWithBubbleView:bubbleView];
}


- (NSInteger)numberOfItemsInBubbleView:(HEBubbleView *)bubbleView {
    id <NSFetchedResultsSectionInfo> sectionInfo =
            [[self dataSource] sections][0];

    return [sectionInfo numberOfObjects]+1;
}

- (id) getNSManagedObjectAtIndex:(NSInteger) index{
    return [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (NSString*) textStringForIndex:(NSInteger) index inBubbleView:(HEBubbleView *)bubbleView {
    if([self isLastElementForIndex:index inBubbleView:bubbleView])
        return self.addTextString;
    NSAssert(self.getTextInfo,@"function getTextInfo from NSManagedObject requered");
    return self.getTextInfo([self getNSManagedObjectAtIndex:index]);
}

- (BOOL) isLastElementForIndex:(NSInteger) index inBubbleView:(HEBubbleView *)bubbleView{
    return ([self numberOfItemsInBubbleView:bubbleView] - index == 1);
}

- (HEBubbleViewItem *)bubbleView:(HEBubbleView *)bubbleView bubbleItemForIndex:(NSInteger)index {

    NSString *itemIdentifier = @"bubble";

    HPHEBubbleViewItem *bubble = (HPHEBubbleViewItem *) [bubbleView dequeueItemUsingReuseIdentifier:itemIdentifier];
    if (!bubble) {
        bubble = [[HPHEBubbleViewItem alloc] initWithReuseIdentifier:itemIdentifier];
        bubble.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 28)];
        [[RACObserve(bubble.textLabel,frame) distinctUntilChanged] subscribeNext:^(NSValue * x) {
            bubble.textField.frame = x.CGRectValue;
        }];
        [bubble insertSubview:bubble.textField aboveSubview:bubble.textLabel];
        bubble.textField.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        bubble.textField.textColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        [[bubble.textField rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(id x) {
            bubble.textLabel.hidden = YES;
        }];
        [[bubble.textField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(UITextField * textField1) {
            if([textField1.text isEqualToString:@""]) {
                bubble.textLabel.hidden = NO;
            }
        }];
        bubble.textField.delegate = self;
    }

    bubble.unselectedBGColor = [UIColor clearColor];
    bubble.textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    if(![self isLastElementForIndex:index inBubbleView:bubbleView]){
        bubble.unselectedBorderColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.3];
        bubble.unselectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        bubble.selectedBorderColor = [UIColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:112.0f/255.0f alpha:1];
        bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
        bubble.selectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        bubble.textField.hidden = YES;
    }
    else{
        bubble.unselectedBorderColor = [UIColor clearColor];
        bubble.unselectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.4];
        bubble.selectedBorderColor = [UIColor clearColor];
        bubble.selectedBGColor = [UIColor clearColor];
        bubble.selectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.4];
        bubble.textField.hidden = NO;
    }

    bubble.textLabel.text = [self textStringForIndex:index inBubbleView:bubbleView];
    return bubble;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self bubbleView:self.bubbleView insertBubbleWithText:textField.text];
    textField.text = @"";
    [textField resignFirstResponder];
    [textField removeFromSuperview];
    return NO;
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
         self.deleteBubbleBlock([self getNSManagedObjectAtIndex:index]);

}

- (void)bubbleView:(HEBubbleView *) bubbleView insertBubbleWithText:(NSString*) text{
    if(self.insertTextBlock)
        self.insertTextBlock(text);
}

@end
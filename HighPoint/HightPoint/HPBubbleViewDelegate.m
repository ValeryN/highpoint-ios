//
// Created by Eugene on 25.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPBubbleViewDelegate.h"
#import "PSMenuItem.h"
#import "HPHEBubbleView.h"
#import "HPHEBubbleViewItem.h"

@interface HPBubbleViewDelegate ()
@property(nonatomic) BOOL needToReloadAfterControllerComplete;
@property(nonatomic, retain) NSMutableArray *indexedArrayOfBubbleViewItem;
@end

@implementation HPBubbleViewDelegate {

}

- (instancetype)initWithBubbleView:(HPHEBubbleView *)bubbleView {
    self = [super init];
    if (self) {
        self.bubbleView = bubbleView;
        self.indexedArrayOfBubbleViewItem = [NSMutableArray new];
    }

    return self;
}

+ (instancetype)delegateWithBubbleView:(HPHEBubbleView *)bubbleView {
    return [[self alloc] initWithBubbleView:bubbleView];
}

- (void)setDataSource:(NSFetchedResultsController *)dataSource {
    _dataSource = dataSource;
    dataSource.delegate = self;
}

- (NSInteger)numberOfItemsInBubbleView:(HEBubbleView *)bubbleView {
    id <NSFetchedResultsSectionInfo> sectionInfo =
            [[self dataSource] sections][0];

    return [sectionInfo numberOfObjects]+(self.withEditMode?1:0);
}

- (id) getNSManagedObjectAtIndex:(NSInteger) index{
    return [self.dataSource objectAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (NSString*) textStringForIndex:(NSInteger) index inBubbleView:(HEBubbleView *)bubbleView {
    if([self isLastElementForIndex:index inBubbleView:bubbleView] && self.withEditMode)
        return self.addTextString;
    NSAssert(self.getTextInfo,@"function getTextInfo from NSManagedObject requered");
    return self.getTextInfo([self getNSManagedObjectAtIndex:index]);
}

- (BOOL) isLastElementForIndex:(NSInteger) index inBubbleView:(HEBubbleView *)bubbleView{
    return ([self numberOfItemsInBubbleView:bubbleView] - index == 1);
}

- (HEBubbleViewItem *)bubbleView:(HEBubbleView *)bubbleView bubbleItemForIndex:(NSInteger)index {
    NSString *itemIdentifier;
    if ([self isLastElementForIndex:index inBubbleView:bubbleView] && self.withEditMode) {
        itemIdentifier = @"bubbleAdd";
    }
    else {
        itemIdentifier = @"bubble";
    }

    HPHEBubbleViewItem *bubble = (HPHEBubbleViewItem *) [bubbleView dequeueItemUsingReuseIdentifier:itemIdentifier];
    if (!bubble) {
        bubble = [[HPHEBubbleViewItem alloc] initWithReuseIdentifier:itemIdentifier];
        bubble.textField = [[HPBubbleTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 28)];
        [[RACObserve(bubble.textLabel,frame) distinctUntilChanged] subscribeNext:^(NSValue * x) {
            bubble.textField.frame = x.CGRectValue;
        }];
        [bubble insertSubview:bubble.textField aboveSubview:bubble.textLabel];
        bubble.textField.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        bubble.textField.textColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        if(self.withEditMode){
            [[bubble.textField rac_signalForControlEvents:UIControlEventEditingDidBegin] subscribeNext:^(id x) {
                bubble.textLabel.hidden = YES;
            }];
        }

        UIColor * caretColor = bubble.textField.tintColor;
        [[bubble.textField rac_signalForControlEvents:UIControlEventEditingDidEnd] subscribeNext:^(UITextField * textField1) {
            bubble.textField.tintColor = caretColor;
            [self.bubbleView.activeBubble setSelected:NO animated:NO];
            self.bubbleView.activeBubble = nil;
            if([textField1.text isEqualToString:@""]) {
                bubble.textLabel.hidden = NO;
            }
        }];

        if(self.withEditMode){
            @weakify(self);
            [bubble.textField.backSpaceSignal subscribeNext:^(id x) {
                @strongify(self);
                if ([bubble.textField.text isEqualToString:@""] && [self numberOfItemsInBubbleView:self.bubbleView] > 1) {
                    if(!self.bubbleView.activeBubble) {
                        bubble.textField.tintColor = [UIColor clearColor];
                        self.bubbleView.activeBubble = self.indexedArrayOfBubbleViewItem[(NSUInteger) (bubble.index - 1)];
                        [self.bubbleView.activeBubble setSelected:YES animated:YES];

                        [[[bubble.textField.rac_textSignal skip:1] take:1] subscribeNext:^(id x) {
                            bubble.textField.tintColor = caretColor;
                            [self.bubbleView.activeBubble setSelected:NO animated:YES];
                            self.bubbleView.activeBubble = nil;

                        }];
                    }
                    else {
                        bubble.textField.tintColor = caretColor;
                        [self.bubbleView.activeBubble setSelected:NO animated:NO];
                        self.bubbleView.activeBubble = nil;
                        [self bubbleView:bubbleView deleteItemWithIndex:[self numberOfItemsInBubbleView:self.bubbleView] - 2];
                    }
                }
            }];
        }

        bubble.textField.delegate = self;
    }

    bubble.unselectedBGColor = [UIColor clearColor];
    bubble.textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    if(!self.withEditMode){
        bubble.unselectedBorderColor = [UIColor colorWithRed:80.f/255.f green:227.f/255.f blue:194.f/255.f alpha:1.f];
        bubble.unselectedTextColor = [UIColor colorWithRed:80.f/255.f green:227.f/255.f blue:194.f/255.f alpha:1.f];
        bubble.selectedBorderColor = [UIColor colorWithRed:80.f/255.f green:227.f/255.f blue:194.f/255.f alpha:1.f];
        bubble.selectedBGColor = [UIColor clearColor];
        bubble.selectedTextColor = [UIColor colorWithRed:80.f/255.f green:227.f/255.f blue:194.f/255.f alpha:1.f];
        bubble.textField.hidden = YES;
    }
    else if([self isLastElementForIndex:index inBubbleView:bubbleView]){
        bubble.unselectedBorderColor = [UIColor clearColor];
        bubble.unselectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.4];
        bubble.selectedBorderColor = [UIColor clearColor];
        bubble.selectedBGColor = [UIColor clearColor];
        bubble.selectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.4];
        bubble.textField.hidden = NO;
    }
    else{
        bubble.unselectedBorderColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:0.3];
        bubble.unselectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        bubble.selectedBorderColor = [UIColor colorWithRed:255.0f/255.0f green:102.0f/255.0f blue:112.0f/255.0f alpha:1];
        bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
        bubble.selectedTextColor = [UIColor colorWithRed:230.0f/255.0f green:236.0f/255.0f blue:242.0f/255.0f alpha:1];
        bubble.textField.hidden = YES;
    }

    bubble.textLabel.text = [self textStringForIndex:index inBubbleView:bubbleView];

    if (self.indexedArrayOfBubbleViewItem.count > index) {
        [self.indexedArrayOfBubbleViewItem removeObjectAtIndex:(NSUInteger) index];
    }
    [self.indexedArrayOfBubbleViewItem insertObject:bubble atIndex:(NSUInteger) index];

    return bubble;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        [self bubbleView:self.bubbleView insertBubbleWithText:textField.text];
        textField.text = @"";
    }
    [textField resignFirstResponder];
    return NO;
}

-(BOOL)bubbleView:(HEBubbleView *)bubbleView shouldShowMenuForBubbleItemAtIndex:(NSInteger)index
{
    return ![self isLastElementForIndex:index inBubbleView:bubbleView];
}

-(NSArray *)bubbleView:(HEBubbleView *)bubbleView menuItemsForBubbleItemAtIndex:(NSInteger)index
{
    if (self.withEditMode) {
        @weakify(self);
        NSNumber *blockInt = @(index);
        PSMenuItem *actionDelete = [[PSMenuItem alloc] initWithTitle:@"Delete" block:^{
            @strongify(self);
            [self bubbleView:bubbleView deleteItemWithIndex:blockInt.integerValue];
        }];
        return @[actionDelete];
    }
    
    return nil;
}

- (void)bubbleView:(HEBubbleView *)bubbleView deleteItemWithIndex:(NSInteger)index{
    if (self.deleteBubbleBlock) {
         self.deleteBubbleBlock([self getNSManagedObjectAtIndex:index]);
    }


}

- (void)bubbleView:(HEBubbleView *) bubbleView insertBubbleWithText:(NSString*) text{
    if(self.insertTextBlock)
        self.insertTextBlock(text);
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            self.needToReloadAfterControllerComplete = YES;

        case NSFetchedResultsChangeDelete:
            [self.bubbleView removeItemAtIndex:indexPath.row animated:YES];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.needToReloadAfterControllerComplete) {
        [self.bubbleView reloadData];
        self.needToReloadAfterControllerComplete = NO;
    }
}
@end
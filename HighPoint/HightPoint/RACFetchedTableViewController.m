//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACFetchedTableViewController.h"
#import "RACTableViewController.h"
#import "HPChatMsgTableViewCell.h"

@interface RACFetchedTableViewController ()
@property(nonatomic, retain) NSFetchedResultsController *data;
@property(nonatomic, retain) NSString * defaultCellIdentifier;
@property(nonatomic, weak) UITableView *rac_tableView;
@property(nonatomic, retain) NSMutableDictionary * cellClass;
@property(nonatomic) NSMutableDictionary * rowHeight;

@property(nonatomic, retain) NSMutableArray *sizesTmpArray;
@property(nonatomic, retain) NSMutableArray *sizesArray;

@property(nonatomic, retain) NSMutableDictionary* indexToInsertInUpdate;
@property(nonatomic, retain) NSMutableDictionary* indexToDeleteInUpdate;

@property(nonatomic, retain) NSMutableArray* sectionToInsertInUpdate;
@property(nonatomic, retain) NSMutableArray* sectionToDeleteInUpdate;
@end

#define DYNAMIC_KEY @(-1)
@implementation RACFetchedTableViewController {

}
- (void)configureTableView:(UITableView *)tableView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    if (self.cachedCellHeight) {
        self.sizesTmpArray = [NSMutableArray new];
    }
    self.cellClass = [NSMutableDictionary new];
    self.rowHeight = [NSMutableDictionary new];

    self.rac_tableView = tableView;
    _data = nil;

    UITableViewCell * cell = [self addTemplateCell:templateCellNib];
    self.defaultCellIdentifier = cell.reuseIdentifier;

    tableView.dataSource = self;

    @weakify(self);
    [source subscribeNext:^(NSFetchedResultsController *x) {
        @strongify(self);
        if (self.cachedCellHeight && [[self.rowHeight allValues] containsObject:DYNAMIC_KEY]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                @strongify(self);
                [self calculateHeightBeforeLoading:x];

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    self.data = x;
                    [tableView reloadData];
                    self.data.delegate = self;
                });
            });
        }
        else {
            self.data = x;
            self.data.delegate = self;
            [tableView reloadData];
        }
    }];

    if (tableView.delegate == nil)
        tableView.delegate = self;

    NSObject <UITableViewDelegate> *delegate = tableView.delegate;
    tableView.delegate = nil;
    self.selectRowSignal = [[delegate rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] map:^id(RACTuple *value) {
        @strongify(self);
        RACTupleUnpack(UITableView *tableView, NSIndexPath *indexPath) = value;
        return [[self data] objectAtIndexPath:indexPath];
    }];
    tableView.delegate = delegate;

}

- (UITableViewCell*)addTemplateCell:(UINib *)templateCellNib {
    UITableViewCell *cell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    self.cellClass[cell.reuseIdentifier] = NSStringFromClass(cell.class);
    [self.rac_tableView registerNib:templateCellNib forCellReuseIdentifier:cell.reuseIdentifier];
    if (![cell.class respondsToSelector:@selector(heightForRowWithModel:)]) {
        CGFloat rowHeight = cell.bounds.size.height;
        self.rowHeight[cell.reuseIdentifier] = @(rowHeight);
    }
    else{
        self.rowHeight[cell.reuseIdentifier] = DYNAMIC_KEY;
    }
    return cell;
}

- (void)calculateHeightBeforeLoading:(NSFetchedResultsController *)resultsController {
    @synchronized (self.sizesArray) {
        [self deleteCacheAllHeight];
        for (Message *message in resultsController.fetchedObjects) {
            NSString* cellIdentifier = [self cellIdentifierForModel:message];
            if ([self.rowHeight[cellIdentifier] isEqual:DYNAMIC_KEY]) {
                NSIndexPath * path = [resultsController indexPathForObject:message];
                CGFloat height = [NSClassFromString(self.cellClass[cellIdentifier]) heightForRowWithModel:message];
                if (self.sizesTmpArray.count <= path.section)
                    [self.sizesTmpArray insertObject:[NSMutableArray new] atIndex:(NSUInteger) path.section];
                NSMutableArray* sectionArray = ((NSMutableArray *) self.sizesTmpArray[(NSUInteger) path.section]);
                [sectionArray insertObject:@(height) atIndex:(NSUInteger) path.row];
            }
        }
        [self updateCacheHeight];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self data] sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((id <NSFetchedResultsSectionInfo>) [[self data] sections][(NSUInteger) section]).numberOfObjects;
}

- (NSString*)cellIdentifierForModel:(id)model{
    return self.defaultCellIdentifier;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [[self data] objectAtIndexPath:indexPath];
    id <RACTableViewCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifierForModel:model]];
    [cell bindViewModel:model];
    return (UITableViewCell *) cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = [[self data] objectAtIndexPath:indexPath];
    NSString* cellIdentifier = [self cellIdentifierForModel:model];
    if ([self.rowHeight[cellIdentifier] isEqual:DYNAMIC_KEY]) {
        if (self.cachedCellHeight) {
            return [self getCacheHeightForIndexPath:indexPath];
        }
        else {
            CGFloat height = [NSClassFromString(self.cellClass[cellIdentifier]) heightForRowWithModel:model];
            return height;
        }

    }
    else {
        return ((NSNumber *)self.rowHeight[cellIdentifier]).floatValue;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.rac_tableView beginUpdates];
    self.indexToDeleteInUpdate = [NSMutableDictionary new];
    self.indexToInsertInUpdate = [NSMutableDictionary new];
    self.sectionToInsertInUpdate = [NSMutableArray new];
    self.sectionToDeleteInUpdate = [NSMutableArray new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.sectionToInsertInUpdate addObject:@(sectionIndex)];
            [self.rac_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.sectionToDeleteInUpdate addObject:@(sectionIndex)];
            [self.rac_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            NSAssert(false, @"Not implemented");
            break;
        case NSFetchedResultsChangeUpdate:
            [self.rac_tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.rac_tableView;
    NSString* cellIdentifier = [self cellIdentifierForModel:anObject];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            if ([self.rowHeight[cellIdentifier] isEqual:DYNAMIC_KEY]) {
                self.indexToInsertInUpdate[newIndexPath] = @([NSClassFromString(self.cellClass[cellIdentifier]) heightForRowWithModel:anObject]);
            }
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self deleteHeightAtIndexPath:indexPath];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            //Must be updated by RAC
            break;

        case NSFetchedResultsChangeMove:
            self.indexToDeleteInUpdate[indexPath] = @YES;
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if ([self.rowHeight[cellIdentifier] isEqual:DYNAMIC_KEY]) {
                self.indexToInsertInUpdate[newIndexPath] = @([NSClassFromString(self.cellClass[cellIdentifier]) heightForRowWithModel:anObject]);
            }
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSArray * arrayToDeleteSection = [self.sectionToDeleteInUpdate sortedArrayUsingSelector:@selector(compare:)];
    for(NSNumber *number in arrayToDeleteSection){
        [self deleteSectionAtIndex:number.unsignedIntegerValue];
    }

    NSArray * arrayToInsertSection = [self.sectionToInsertInUpdate sortedArrayUsingSelector:@selector(compare:)];
    for(NSNumber *number in arrayToInsertSection){
        [self insertSectionAtIndex:number.unsignedIntegerValue];
    }

    NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
    NSSortDescriptor *sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
    NSArray* indexToDelete = [[[self.indexToDeleteInUpdate.allKeys sortedArrayUsingDescriptors:@[sectionDescriptor,rowDescriptor]] reverseObjectEnumerator] allObjects];
    for(NSIndexPath * path in indexToDelete)
        [self deleteHeightAtIndexPath:path];
    
    NSArray* indexToInsert = [self.indexToInsertInUpdate.allKeys sortedArrayUsingDescriptors:@[sectionDescriptor,rowDescriptor]];
    for(NSIndexPath * path in indexToInsert)
        [self insertHeight:((NSNumber*)self.indexToInsertInUpdate[path]).floatValue forIndexPath:path];
    [self.rac_tableView endUpdates];
}

- (CGFloat)getCacheHeightForIndexPath:(NSIndexPath *)path {
    return ((NSNumber *) self.sizesArray[(NSUInteger) path.section][(NSUInteger) path.row]).floatValue;
}

- (void)setHeight:(CGFloat)height forIndexPath:(NSIndexPath *)path {
    self.sizesArray[(NSUInteger) path.section][(NSUInteger) path.row] = @(height);
}

- (void)insertHeight:(CGFloat)height forIndexPath:(NSIndexPath *)path {
    if (self.sizesArray.count <= path.section)
        [self insertSectionAtIndex:path.section];
    NSMutableArray* sectionArray = ((NSMutableArray *) self.sizesTmpArray[(NSUInteger) path.section]);
    [sectionArray insertObject:@(height) atIndex:(NSUInteger) path.row];
}

- (void)deleteHeightAtIndexPath:(NSIndexPath *)path {
    [((NSMutableArray *) self.sizesArray[(NSUInteger) path.section]) removeObjectAtIndex:(NSUInteger) path.row];
}

- (void)insertSectionAtIndex:(NSInteger)index {
    [self.sizesArray insertObject:[NSMutableArray new] atIndex:(NSUInteger) index];
}

- (void)deleteSectionAtIndex:(NSInteger)index {
    [self.sizesArray removeObjectAtIndex:(NSUInteger) index];
}

- (void)deleteCacheAllHeight {
    self.sizesTmpArray = [NSMutableArray new];
}
- (void)updateCacheHeight{
    self.sizesArray = self.sizesTmpArray;
}
@end
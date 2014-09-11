//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACFetchedTableViewController.h"
#import "RACTableViewController.h"
#import "HPChatMsgTableViewCell.h"

@interface RACFetchedTableViewController ()
@property(nonatomic, retain) NSFetchedResultsController *data;
@property(nonatomic, retain) NSString *cellIdentifier;
@property(nonatomic, weak) UITableView *rac_tableView;
@property(nonatomic, retain) Class cellClass;
@property(nonatomic) CGFloat rowHeight;
@property(nonatomic, retain) NSMutableDictionary *sizesCache;
@property(nonatomic, retain) NSMutableDictionary *sizeCacheByObjectId;
@end

@implementation RACFetchedTableViewController {

}
- (void)configureTableView:(UITableView *)tableView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    if (self.cachedCellHeightByModelId) {
        self.sizesCache = [NSMutableDictionary new];
        self.sizeCacheByObjectId = [NSMutableDictionary new];
    }
    UITableViewCell *cell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    self.cellClass = cell.class;
    self.cellIdentifier = cell.reuseIdentifier;

    self.rac_tableView = tableView;
    _data = nil;

    tableView.dataSource = self;

    @weakify(self);
    [source subscribeNext:^(NSFetchedResultsController* x) {
        @strongify(self);
        if (self.cachedCellHeightByModelId && [cell.class respondsToSelector:@selector(heightForRowWithModel:)]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSMutableDictionary *newSizesDict = [NSMutableDictionary new];
                for(Message* message in x.fetchedObjects)
                {
                    NSManagedObjectID *objectID = message.objectID;
                    if(!self.sizeCacheByObjectId[objectID]){
                        self.sizeCacheByObjectId[objectID] = @([cell.class heightForRowWithModel:message]);
                    }
                    NSString* key = [self.class stringRepresentationIndexPath:[x indexPathForObject:message]];
                    newSizesDict[key] = self.sizeCacheByObjectId[objectID];
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    self.data = x;
                    self.sizesCache = newSizesDict;
                    [tableView reloadData];
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

    [tableView registerNib:templateCellNib forCellReuseIdentifier:self.cellIdentifier];

    if (![cell.class respondsToSelector:@selector(heightForRowWithModel:)]) {
        tableView.rowHeight = cell.bounds.size.height;
        self.rowHeight = cell.bounds.size.height;;
    }

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self data] sections].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((id <NSFetchedResultsSectionInfo>) [[self data] sections][(NSUInteger) section]).numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <RACTableViewCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    [cell bindViewModel:[[self data] objectAtIndexPath:indexPath]];
    return (UITableViewCell *) cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.cellClass respondsToSelector:@selector(heightForRowWithModel:)]) {
        if (self.cachedCellHeightByModelId) {
            NSString* key = [self.class stringRepresentationIndexPath:indexPath];
            if (!self.sizesCache[key]) {
                NSObject <RACTableViewCellProtocol> *cell = (id <RACTableViewCellProtocol>) self.cellClass;
                self.sizesCache[key] = @([cell.class heightForRowWithModel:[[self data] objectAtIndexPath:indexPath]]);
            }
            return ((NSNumber *) self.sizesCache[key]).floatValue;
        }
        else {
            NSObject <RACTableViewCellProtocol> *cell = (id <RACTableViewCellProtocol>) self.cellClass;
            CGFloat height = [cell.class heightForRowWithModel:[[self data] objectAtIndexPath:indexPath]];
            return height;
        }

    }
    else {
        return self.rowHeight;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.rac_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    self.sizesCache = [NSMutableDictionary new];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.rac_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
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

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            //Must be updated by RAC
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.rac_tableView endUpdates];
}
+ (NSString*) stringRepresentationIndexPath:(NSIndexPath *) path{
    return  [NSString stringWithFormat:@"%d,%d",path.section,path.item];
}
@end
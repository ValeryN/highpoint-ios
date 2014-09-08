//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACFetchedTableViewController.h"
#import "RACTableViewController.h"

@interface RACFetchedTableViewController ()
@property(nonatomic, retain) NSFetchedResultsController *data;
@property(nonatomic, retain) NSString *cellIdentifier;
@end

@implementation RACFetchedTableViewController {

}
- (void)configureTableViewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    _data = nil;
    @weakify(self);
    [source subscribeNext:^(id x) {
        @strongify(self);
        self.data = x;
        self.data.delegate = self;
        [self.tableView reloadData];
    }];

    if (self.tableView.delegate == nil)
        self.tableView.delegate = self;

    NSObject <UITableViewDelegate> *delegate = self.tableView.delegate;
    self.tableView.delegate = nil;
    self.selectRowSignal = [[delegate rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] map:^id(RACTuple *value) {
        @strongify(self);
        RACTupleUnpack(UITableView *tableView, NSIndexPath *indexPath) = value;
        return [[self data] objectAtIndexPath:indexPath];
    }];
    self.tableView.delegate = delegate;
    UITableViewCell * cell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    self.cellIdentifier = cell.reuseIdentifier;
    [self.tableView registerNib:templateCellNib forCellReuseIdentifier:self.cellIdentifier];
    self.tableView.rowHeight = cell.bounds.size.height;

    self.tableView.dataSource = self;
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

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            NSAssert(false, @"Not implemented");
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;

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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
@end
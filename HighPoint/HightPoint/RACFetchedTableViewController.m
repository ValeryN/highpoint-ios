//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACFetchedTableViewController.h"
#import "RACTableViewController.h"

@interface RACFetchedTableViewController ()
@property(nonatomic, retain) NSFetchedResultsController *data;
@property(nonatomic, retain) UITableViewCell *templateCell;
@end

@implementation RACFetchedTableViewController {

}
- (void)configureTableViewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    _data = nil;
    [source subscribeNext:^(id x) {
        _data = x;
        [self.tableView reloadData];
    }];

    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    [self.tableView registerNib:templateCellNib forCellReuseIdentifier:_templateCell.reuseIdentifier];
    self.tableView.rowHeight = _templateCell.bounds.size.height;
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
    id <RACTableViewCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:_templateCell.reuseIdentifier];
    [cell bindViewModel:[[self data] objectAtIndexPath:indexPath]];
    return (UITableViewCell *) cell;
}

@end
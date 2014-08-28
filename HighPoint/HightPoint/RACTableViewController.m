//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACTableViewController.h"

@interface RACTableViewController ()
@property(nonatomic, retain) NSArray *data;
@property(nonatomic, retain) UITableViewCell *templateCell;
@end

@implementation RACTableViewController {

}
- (void)configureTableViewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    _data = [NSArray array];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <RACTableViewCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:_templateCell.reuseIdentifier];
    [cell bindViewModel:_data[(NSUInteger) indexPath.row]];
    return (UITableViewCell *) cell;
}

@end
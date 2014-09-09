//
// Created by Eugene on 28.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACTableViewController.h"
#import "HPChatMsgTableViewCell.h"

@interface RACTableViewController ()
@property(nonatomic, retain) NSArray *data;
@property(nonatomic, retain) UITableViewCell *templateCell;
@end

@implementation RACTableViewController {

}
- (void)configureTable:(UITableView*) tableView viewWithSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    _data = [NSArray array];
    @weakify(self);
    [source subscribeNext:^(id x) {
        @strongify(self);
        self.data = x;
        [tableView reloadData];
    }];

    if (tableView.delegate == nil)
        tableView.delegate = self;

    NSObject <UITableViewDelegate> *delegate = tableView.delegate;
    tableView.delegate = nil;
    self.selectRowSignal = [[delegate rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:) fromProtocol:@protocol(UITableViewDelegate)] map:^id(RACTuple *value) {
        @strongify(self);
        RACTupleUnpack(UITableView *tableView, NSIndexPath *indexPath) = value;
        return _data[(NSUInteger) indexPath.row];
    }];
    tableView.delegate = delegate;

    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    [tableView registerNib:templateCellNib forCellReuseIdentifier:_templateCell.reuseIdentifier];

    if(![_templateCell.class respondsToSelector:@selector(heightForRowWithModel:)]) {
        tableView.rowHeight = _templateCell.bounds.size.height;
    }

    tableView.dataSource = self;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([_templateCell respondsToSelector:@selector(heightForRowWithModel:)]) {
        NSObject <RACTableViewCellProtocol>* cell = (id <RACTableViewCellProtocol>) _templateCell;
        return [cell.class heightForRowWithModel:_data[(NSUInteger) indexPath.row]];
    }
    else{
        return _templateCell.bounds.size.height;
    }
}
@end
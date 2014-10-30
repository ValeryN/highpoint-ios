//
//  RACCollectionViewController.m
//  HighPoint
//
//  Created by Eugene on 30/10/14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACCollectionViewController.h"
#import "RACTableViewController.h"

@interface RACCollectionViewController()
@property(nonatomic, retain) NSArray *data;
@property(nonatomic, retain) UITableViewCell *templateCell;
@property(nonatomic) CGSize collectionViewElementSize;
@property(nonatomic, weak) UICollectionView * rac_collectionView;
@end
@implementation RACCollectionViewController
- (void)configureCollectionView: (UICollectionView*) collectionView withSignal:(RACSignal *)source andTemplateCell:(UINib *)templateCellNib {
    _data = nil;
    @weakify(self);
    
    if (collectionView.delegate == nil)
        collectionView.delegate = self;
    
    NSObject <UICollectionViewDelegate> *delegate = collectionView.delegate;
    collectionView.delegate = nil;
    self.selectRowSignal = [[delegate rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:) fromProtocol:@protocol(UICollectionViewDelegate)] map:^id(RACTuple *value) {
        @strongify(self);
        RACTupleUnpack(UICollectionView *uiCollectionView, NSIndexPath *indexPath) = value;
        return self.data[(NSUInteger) indexPath.row];
    }];
    collectionView.delegate = delegate;
    
    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    [collectionView registerNib:templateCellNib forCellWithReuseIdentifier:_templateCell.reuseIdentifier];
    self.collectionViewElementSize = _templateCell.bounds.size;
    self.rac_collectionView = collectionView;
    collectionView.dataSource = self;
    
    [source subscribeNext:^(id x) {
        @strongify(self);
        self.data = x;
        [collectionView reloadData];
    }];
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionViewElementSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id <RACTableViewCellProtocol> cell = [cv dequeueReusableCellWithReuseIdentifier:_templateCell.reuseIdentifier forIndexPath:indexPath];
    [cell bindViewModel:self.data[(NSUInteger) indexPath.row]];
    return (UICollectionViewCell *) cell;
}
@end

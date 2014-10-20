//
// Created by Eugene on 02.09.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "RACFetchedCollectionViewController.h"
#import "RACTableViewController.h"


@interface RACFetchedCollectionViewController ()
@property(nonatomic, retain) NSFetchedResultsController *data;
@property(nonatomic, retain) UITableViewCell *templateCell;
@property(nonatomic) CGSize collectionViewElementSize;
@property(nonatomic, retain) NSMutableArray *objectChanges;
@property(nonatomic, retain) NSMutableArray *sectionChanges;
@property(nonatomic, weak) UICollectionView * rac_collectionView;
@end

@implementation RACFetchedCollectionViewController {
}

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
        return [[self data] objectAtIndexPath:indexPath];
    }];
    collectionView.delegate = delegate;

    _templateCell = [[templateCellNib instantiateWithOwner:nil options:nil] firstObject];
    [collectionView registerNib:templateCellNib forCellWithReuseIdentifier:_templateCell.reuseIdentifier];
    self.collectionViewElementSize = _templateCell.bounds.size;
    self.rac_collectionView = collectionView;
    collectionView.dataSource = self;
    
    [source subscribeNext:^(id x) {
        @strongify(self);
        self.objectChanges = [NSMutableArray new];
        self.sectionChanges = [NSMutableArray new];
        self.data = x;
        self.data.delegate = self;
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
    return [[self data] sections].count;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return ((id <NSFetchedResultsSectionInfo>) [[self data] sections][(NSUInteger) section]).numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id <RACTableViewCellProtocol> cell = [cv dequeueReusableCellWithReuseIdentifier:_templateCell.reuseIdentifier forIndexPath:indexPath];
    [cell bindViewModel:[[self data] objectAtIndexPath:indexPath]];
    return (UICollectionViewCell *) cell;
}

#pragma mark NSFetchedControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    NSMutableDictionary *change = [NSMutableDictionary new];

    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
        default:
            break;
    }

    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    NSMutableDictionary *change = [NSMutableDictionary new];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
//        Shoul be updated by rac
//        case NSFetchedResultsChangeUpdate:
//            change[@(type)] = indexPath;
//            break;
//
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([_sectionChanges count] > 0) {
        [self.rac_collectionView performBatchUpdates:^{

            for (NSDictionary *change in _sectionChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type) {
                        case NSFetchedResultsChangeInsert:
                            [self.rac_collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.rac_collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.rac_collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        default:
                            break;
                    }
                }];
            }
        }                             completion:nil];
    }

    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0) {

        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.rac_collectionView.window == nil) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.rac_collectionView reloadData];

        } else {

            [self.rac_collectionView performBatchUpdates:^{

                for (NSDictionary *change in _objectChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {

                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [self.rac_collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.rac_collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.rac_collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.rac_collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }

    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self.objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    shouldReload = [self.rac_collectionView numberOfItemsInSection:indexPath.section] == 0;
                    break;
                case NSFetchedResultsChangeDelete:
                    shouldReload = [self.rac_collectionView numberOfItemsInSection:indexPath.section] == 1;
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }

    return shouldReload;
}

@end
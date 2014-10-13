//
//  RACollectionViewTripletLayout.m
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/25/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import "RACollectionViewTripletLayout.h"

@interface RACollectionViewTripletLayout()

@property (nonatomic, assign) NSInteger numberOfCells;
@property (nonatomic, assign) CGFloat numberOfLines;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat sectionSpacing;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, strong) NSArray *oldArray;
@property (nonatomic, strong) NSMutableArray *largeCellSizeArray;
@property (nonatomic, strong) NSMutableArray *smallCellSizeArray;

@end

@implementation RACollectionViewTripletLayout

#pragma mark - Over ride flow layout methods

- (void)prepareLayout
{
    [super prepareLayout];

    //delegate
    self.delegate = (id<RACollectionViewDelegateTripletLayout>)self.collectionView.delegate;
    //collection view size
    _collectionViewSize = self.collectionView.bounds.size;
    //some values
    _itemSpacing = 0;
    _lineSpacing = 0;
    _sectionSpacing = 0;
    _insets = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        _itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        _lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        _sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        _insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
}

- (id<RACollectionViewDelegateTripletLayout>)delegate
{
    return (id<RACollectionViewDelegateTripletLayout>)self.collectionView.delegate;
}

- (CGSize)collectionViewContentSize
{
    CGSize contentSize = CGSizeMake(_collectionViewSize.width, 0);
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfLines = ceil((CGFloat)[self.collectionView numberOfItemsInSection:i] / 3.f);
        CGFloat lineHeight = numberOfLines * ([_largeCellSizeArray[i] CGSizeValue].height + _lineSpacing) - _lineSpacing;
        contentSize.height += lineHeight;
    }
    contentSize.height += _insets.top + _insets.bottom + _sectionSpacing * (self.collectionView.numberOfSections - 1);
    NSInteger numberOfItemsInLastSection = [self.collectionView numberOfItemsInSection:self.collectionView.numberOfSections - 1];
    if ((numberOfItemsInLastSection - 1) % 3 == 0 && (numberOfItemsInLastSection - 1) % 6 != 0) {
        contentSize.height -= [_smallCellSizeArray[self.collectionView.numberOfSections - 1] CGSizeValue].height + _itemSpacing;
    }
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    BOOL shouldUpdate = [self shouldUpdateAttributesArray];
    if (CGRectEqualToRect(_oldRect, rect) && !shouldUpdate) {
        return _oldArray;
    }
    _oldRect = rect;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfCellsInSection = [self.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < numberOfCellsInSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }
    }
    _oldArray = attributesArray;
    return  attributesArray;
}

//needs override
- (BOOL)shouldUpdateAttributesArray
{
    return NO;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    //cellSize
    CGFloat largeCellSideLength = (2.f * (_collectionViewSize.width - _insets.left - _insets.right) - _itemSpacing) / 3.f;
    CGFloat smallCellSideLength = (largeCellSideLength - _itemSpacing) / 2.f;
    _largeCellSize = CGSizeMake(largeCellSideLength, largeCellSideLength);
    _smallCellSize = CGSizeMake(smallCellSideLength, smallCellSideLength);
    if ([self.delegate respondsToSelector:@selector(collectionView:sizeForLargeItemsInSection:)]) {
        if (!CGSizeEqualToSize([self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:indexPath.section], RACollectionViewTripletLayoutStyleSquare)) {
            _largeCellSize = [self.delegate collectionView:self.collectionView sizeForLargeItemsInSection:indexPath.section];
            _smallCellSize = CGSizeMake(_collectionViewSize.width - _largeCellSize.width - _itemSpacing - _insets.left - _insets.right, (_largeCellSize.height / 2.f) - (_itemSpacing / 2.f));
        }
    }
    if (!_largeCellSizeArray) {
        _largeCellSizeArray = [NSMutableArray array];
    }
    if (!_smallCellSizeArray) {
        _smallCellSizeArray = [NSMutableArray array];
    }
    _largeCellSizeArray[indexPath.section] = [NSValue valueWithCGSize:_largeCellSize];
    _smallCellSizeArray[indexPath.section] = [NSValue valueWithCGSize:_smallCellSize];
    
    //section height
    CGFloat sectionHeight = 0;
    for (NSInteger i = 0; i <= indexPath.section - 1; i++) {
        NSInteger cellsCount = [self.collectionView numberOfItemsInSection:i];
        CGFloat largeCellHeight = [_largeCellSizeArray[i] CGSizeValue].height;
        CGFloat smallCellHeight = [_smallCellSizeArray[i] CGSizeValue].height;
        NSInteger lines = ceil((CGFloat)cellsCount / 3.f);
        sectionHeight += lines * (_lineSpacing + largeCellHeight) + _sectionSpacing;
        if ((cellsCount - 1) % 3 == 0 && (cellsCount - 1) % 6 != 0) {
            sectionHeight -= smallCellHeight + _itemSpacing;
        }
    }
    if (sectionHeight > 0) {
        sectionHeight -= _lineSpacing;
    }
    
    NSInteger line = indexPath.item / 3;
    CGFloat lineSpaceForIndexPath = _lineSpacing * line;
    CGFloat lineOriginY = _largeCellSize.height * line + sectionHeight + lineSpaceForIndexPath + _insets.top;
    CGFloat rightSideLargeCellOriginX = _collectionViewSize.width - _largeCellSize.width - _insets.right;
    CGFloat rightSideSmallCellOriginX = _collectionViewSize.width - _smallCellSize.width - _insets.right;

    if (indexPath.item % 6 == 0) {//0,6,12
        attribute.frame = CGRectMake(_insets.left, lineOriginY, _largeCellSize.width, _largeCellSize.height);
    }else if ((indexPath.item + 1) % 6 == 0) {//5, 11
        attribute.frame = CGRectMake(rightSideLargeCellOriginX, lineOriginY, _largeCellSize.width, _largeCellSize.height);
    }else if (line % 2 == 0) {
        if (indexPath.item % 2 != 0) {//1,7,13
            attribute.frame = CGRectMake(rightSideSmallCellOriginX, lineOriginY, _smallCellSize.width, _smallCellSize.height);
        }else {//2,8,14
            attribute.frame =CGRectMake(rightSideSmallCellOriginX, lineOriginY + _smallCellSize.height + _itemSpacing, _smallCellSize.width, _smallCellSize.height);
        }
    }else {
        if (indexPath.item % 2 != 0) {//3,9,15
            attribute.frame = CGRectMake(_insets.left, lineOriginY, _smallCellSize.width, _smallCellSize.height);
        }else {//4,10
            attribute.frame =CGRectMake(_insets.left, lineOriginY + _smallCellSize.height + _itemSpacing, _smallCellSize.width, _smallCellSize.height);
        }
    }
    if([self.collectionView numberOfItemsInSection:indexPath.section] - indexPath.row == 1) {
        
        if (indexPath.item % 6 == 0) {//0,6,12
            attribute.frame = CGRectMake(_insets.left, lineOriginY, 320.0, _largeCellSize.height);
        }else if ((indexPath.item + 1) % 6 == 0) {//5, 11
            attribute.frame = CGRectMake(rightSideLargeCellOriginX, lineOriginY, _largeCellSize.width, _largeCellSize.height);
        }else if (line % 2 == 0) {
            if (indexPath.item % 2 != 0) {//1,7,13
                attribute.frame = CGRectMake(rightSideSmallCellOriginX, lineOriginY, _smallCellSize.width, _smallCellSize.height * 2 + 6);
            }else {//2,8,14
                attribute.frame =CGRectMake(rightSideSmallCellOriginX, lineOriginY + _smallCellSize.height + _itemSpacing, _smallCellSize.width, _smallCellSize.height);
            }
        }else {
            if (indexPath.item % 2 != 0) {//3,9,15
                attribute.frame = CGRectMake(_insets.left, lineOriginY, 320.0, _largeCellSize.height/2);
            }else {//4,10
                attribute.frame =CGRectMake(rightSideLargeCellOriginX, lineOriginY, _largeCellSize.width, _smallCellSize.height);
            }
        }
        //attribute.frame = CGRectMake(_insets.left, lineOriginY, 320.0, _largeCellSize.height);
        return attribute;
    }
    return attribute;
}

@end

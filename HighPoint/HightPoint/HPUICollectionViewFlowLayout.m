//
//  HPUICollectionViewFlowLayout.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 01.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUICollectionViewFlowLayout.h"

@implementation HPUICollectionViewFlowLayout

- (void)awakeFromNib
{
    self.itemSize = CGSizeMake(320.0, 418.0);
    self.minimumInteritemSpacing = 10.0;
    self.minimumLineSpacing = 10.0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.sectionInset = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
}


- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalOffset = proposedContentOffset.x;
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemOffset = layoutAttributes.frame.origin.x;
        if (ABS(itemOffset - horizontalOffset) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemOffset - horizontalOffset;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}
@end

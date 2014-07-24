//
//  HPUserProfileViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 27.05.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

//==============================================================================

#import "HPUserProfileViewController.h"
#import "Utils.h"
#import "HPImageCollectionViewCell.h"
#import "HPUserInfoTableHeaderView.h"
#import "HPUserInfoFirstRowTableViewCell.h"
#import "HPUserInfoSecondRowTableViewCell.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
//==============================================================================

@implementation HPUserProfileViewController

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor colorWithRed: 30.0/255.0
//                                                green: 29.0/255.0
//                                                 blue: 48.0/255.0
//                                                alpha: 1.0];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HPImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cellID"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    //self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    [self setupPhotosArray];
}
- (void)setupPhotosArray
{
    [_photosArray removeAllObjects];
    _photosArray = nil;
    _photosArray = [NSMutableArray array];
    for (NSInteger i = 1; i <= 15; i++) {
        NSString *photoName = [NSString stringWithFormat:@"%ld.jpg",(long)i];
        UIImage *photo = [UIImage imageNamed:photoName];
        [_photosArray addObject:photo];
    }
    //Eye.png
    UIImage *photo = [UIImage imageNamed:@"Camera"];
    [_photosArray addObject:photo];
////////////////////////////////
    self.userDataSource = @[@"РАСХОДЫ", @"ЛЮБИМЫЕ МЕСТА", @"ЯЗЫКИ", @"ОБРАЗОВАНИЕ", @"КАРЬЕРА"];
    NSArray *place1 = @[@"Dulwich Park", @"Greenwich", @"Covent Garden", @"Borough Market", @"The Hob"];
    NSArray *place2 = @[@"Notre Dame", @"De la Concorde", @"De la Bastille", @"Brasserie Bofinger", @"Promenade Plantee"];
    NSArray *place3 = @[@"Anthology Film Archives", @"Bamonte's", @"Housing Works Bookstore Cafe", @"Shopsin's", @"The Hog Pit"];
    self.placeCityDataSource = @{@"London": place1, @"Paris": place2, @"New York": place3};
    NSDictionary *ed1 = @{@"Академия гос. службы":@"Руководитель"};
    NSDictionary *ed2 = @{@"МФТИ":@"Физик-лирик"};
    NSDictionary *ed3 = @{@"Кыштымский заборостроительный техникум":@"Сортировщик 6 разряда"};
    self.educationDataSource = @[ed1,ed2, ed3];
    ed1 = @{@"Правительство":@"Председатель"};
    ed2 = @{@"Администрация Кыштымского района":@"Начальник департамента"};
    ed3 = @{@"ЖЭУ №5":@"Сантехник"};
    self.carrierDataSource = @[ed1,ed2, ed3];
////////////////////////////////
    
}

//==============================================================================

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photosArray.count;
}

- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumInteritemSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (CGFloat)minimumLineSpacingForCollectionView:(UICollectionView *)collectionView
{
    return 5.f;
}

- (UIEdgeInsets)insetsForCollectionView:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(5.f, 0, 5.f, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForLargeItemsInSection:(NSInteger)section
{
    return RACollectionViewTripletLayoutStyleSquare; //same as default !
}

- (UIEdgeInsets)autoScrollTrigerEdgeInsets:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(50.f, 0, 50.f, 0);
   
}

- (UIEdgeInsets)autoScrollTrigerPadding:(UICollectionView *)collectionView
{
    return UIEdgeInsetsMake(64.f, 0, 0, 0);
    
}

- (CGFloat)reorderingItemAlpha:(UICollectionView *)collectionview
{
    return .3f;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    UIImage *image = [_photosArray objectAtIndex:fromIndexPath.item];
    [_photosArray removeObjectAtIndex:fromIndexPath.item];
    [_photosArray insertObject:image atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    //if (toIndexPath.section == 0) {
    //    return NO;
    //}
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.section == 0) {
    //    return NO;
    //}
    return YES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //if (indexPath.section == 0) {
    //    static NSString *cellID = @"headerCell";
    //    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    //    return cell;
    //}else {
    
    static NSString *cellID = @"cellID";
    HPImageCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
    [cell.imageView removeFromSuperview];
    cell.imageView.frame = cell.bounds;
    cell.imageView.image = _photosArray[indexPath.item];
    if(_photosArray.count - indexPath.row == 1) {
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        
        //cell.contentView.layer.masksToBounds = YES;
        cell.contentView.layer.cornerRadius = 2;
        cell.contentView.layer.borderWidth = 2.0;
        cell.contentView.layer.borderColor =  [UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1].CGColor;
    } else {
        cell.contentView.layer.borderColor =  [UIColor clearColor].CGColor;
    }
    
    [cell.contentView addSubview:cell.imageView];
    return cell;
    //}
}

#pragma mark - table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //return [[UIView alloc] initWithFrame:CGRectZero];
    HPUserInfoTableHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"HPUserInfoTableHeaderView" owner:self options:nil] objectAtIndex:0];
    headerView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    headerView.headerTextLabel.backgroundColor = [UIColor clearColor];
    headerView.headerTextLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0 ];
    headerView.headerTextLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    headerView.headerTextLabel.text = [self.userDataSource objectAtIndex:section];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *townCellIdentifier = @"FirstRowCellIdent";
    static NSString *cellIdentifier = @"CellIdent";
    
    if(indexPath.row == 0 && indexPath.section == 0) {
        HPUserInfoFirstRowTableViewCell *townCell;
        townCell = (HPUserInfoFirstRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:townCellIdentifier];
        if (townCell == nil) {
            townCell = [[HPUserInfoFirstRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:townCellIdentifier];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserInfoFirstRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserInfoFirstRowTableViewCell class]])
                {
                    townCell = (HPUserInfoFirstRowTableViewCell *)currentObject;
                    break;
                }
            }
        }
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return [self configureFirstCell:townCell];
    }
    else if (indexPath.row == 0 && indexPath.section == 1) {
        HPUserInfoSecondRowTableViewCell *townCell;
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserInfoSecondRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserInfoSecondRowTableViewCell class]])
                {
                    townCell = (HPUserInfoSecondRowTableViewCell *)currentObject;
                    break;
                }
            }
        }
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return [self configureSecondCell:townCell];
    }
    else if (indexPath.row == 0 && indexPath.section == 2) {
        HPUserInfoFirstRowTableViewCell *townCell;
        townCell = (HPUserInfoFirstRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:townCellIdentifier];
        if (townCell == nil) {
            townCell = [[HPUserInfoFirstRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:townCellIdentifier];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserInfoFirstRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserInfoFirstRowTableViewCell class]])
                {
                    townCell = (HPUserInfoFirstRowTableViewCell *)currentObject;
                    break;
                }
            }
        }
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return [self configureThirdCell:townCell];
    }
    else if (indexPath.row == 0 && indexPath.section == 3) {
        HPUserInfoSecondRowTableViewCell *townCell;
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserInfoSecondRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserInfoSecondRowTableViewCell class]])
                {
                    townCell = (HPUserInfoSecondRowTableViewCell *)currentObject;
                    break;
                }
            }
        }
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return [self configureFourCell:townCell];
    }
    else if (indexPath.row == 0 && indexPath.section == 4) {
        
        HPUserInfoSecondRowTableViewCell *townCell;
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserInfoSecondRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserInfoSecondRowTableViewCell class]])
                {
                    townCell = (HPUserInfoSecondRowTableViewCell *)currentObject;
                    break;
                }
            }
        }
        
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return [self configureFifthCell:townCell];
    }
    return nil;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.userDataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 && indexPath.section == 0) {
        return [self getFirstRowHeight];
    }
    else if(indexPath.row == 0 && indexPath.section == 1) {
        return [self getSecondRowHeight];
    }
    else if(indexPath.row == 0 && indexPath.section == 2) {
        return [self getThirdRowHeight];
    }
    else if(indexPath.row == 0 && indexPath.section == 3) {
        return [self getFourRowHeight];
    }
    else if(indexPath.row == 0 && indexPath.section == 4) {
        return [self getFifthRowHeight];
    }
    else return 100;
}
#pragma mark -
#pragma mark - configure table cells
- (UITableViewCell*) configureFirstCell:(HPUserInfoFirstRowTableViewCell*) cell {
    
    //UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, cell.contentView.frame.size.width - 26, cell.contentView.frame.size.height)];
    cell.cellTextLabel.backgroundColor = [UIColor clearColor];
    cell.cellTextLabel.numberOfLines = 0;
    cell.cellTextLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    cell.cellTextLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    cell.cellTextLabel.textAlignment = NSTextAlignmentLeft;
    //[cell.contentView addSubview:textLabel];
    NSMutableString *text;
    if([self.user.gender intValue] == 2) {
        text = [NSMutableString stringWithString:@"Привыкла"];
    } else {
        text = [NSMutableString stringWithString:@"Привык"];
    }
    [text appendFormat:@" тратить на развлечения от $%d до $%d за вечер",[self.user.minentertainment.amount intValue],  [self.user.maxentertainment.amount intValue] ] ;//[Utils currencyConverter: self.user.minentertainment.currency]
    
    cell.cellTextLabel.text = text;
    return cell;
}
- (UITableViewCell*) configureSecondCell:(UITableViewCell*) cell {
    UIView *t = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50.0, 40.0)];
    t.backgroundColor = [UIColor whiteColor];
    //[cell.contentView addSubview:t];
    NSArray *keys = [self.placeCityDataSource allKeys];
    CGFloat shift = 10.0;
    NSInteger bubbleTag = 0;
    for(NSString *key in keys) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, shift, cell.contentView.frame.size.width - 26, 20.0)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel.textAlignment = NSTextAlignmentLeft;
        CGFloat calcHeight = [self calculateSectionHeight:[self.placeCityDataSource objectForKey:key]] + 20;
        HEBubbleView *bubbleView = [[HEBubbleView alloc] initWithFrame:CGRectMake(10, shift + 20.0, 320, calcHeight)];
        shift = shift + calcHeight;
        textLabel.text = key;
        [cell.contentView addSubview:textLabel];
        bubbleView.layer.cornerRadius = 1;
        bubbleView.bubbleDataSource = self;
        bubbleView.bubbleDelegate = self;
        //self.bubbleView.selectionStyle = HEBubbleViewSelectionStyleNone;
        bubbleView.backgroundColor = [UIColor clearColor];
        bubbleView.itemHeight = 20.0;
        bubbleView.itemPadding = 5.0;
        bubbleView.tag = bubbleTag;
        [cell.contentView addSubview:bubbleView];
        bubbleTag++;
        [bubbleView reloadData];
    }
    //cell.cellTextLabel.hidden = YES;
    //textLabel.text = text;
    return cell;
}
- (UITableViewCell*) configureThirdCell:(HPUserInfoFirstRowTableViewCell*) cell {
    
    cell.cellTextLabel.backgroundColor = [UIColor clearColor];
    cell.cellTextLabel.numberOfLines = 0;
    cell.cellTextLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    cell.cellTextLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    cell.cellTextLabel.textAlignment = NSTextAlignmentLeft;
    //[cell.contentView addSubview:textLabel];
    NSMutableString *text = [NSMutableString stringWithString:@""];
    NSArray *languages = @[@"Русский",@"Английский", @"Албанский", @"Китайский", @"Хинди"];//[self.user.language allObjects];
    for(NSString *lng in languages) {
        [text appendString:lng];
        [text appendString:@", "];
    }
    if(text.length > 2) {
        NSRange rng;
        rng.length = 2;
        rng.location = text.length -2;
        [text deleteCharactersInRange:rng];
    }
    cell.cellTextLabel.text = text;
    return cell;
}
- (UITableViewCell*) configureFourCell:(UITableViewCell*) cell {
    return [self configureCell:cell forDataSource:self.educationDataSource];
}
- (UITableViewCell*) configureFifthCell:(UITableViewCell*) cell {
    return [self configureCell:cell forDataSource:self.carrierDataSource];
}
- (UITableViewCell*) configureCell:(UITableViewCell*) cell  forDataSource:(NSArray*) dataSource {
    CGFloat shift = 5.0;
    //cell.cellTextLabel.hidden = YES;
    CGSize constrainedSize = CGSizeMake(300.0  , 9999);
    for(NSDictionary *dict in dataSource) {
        UILabel *textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, shift, 300.0, 20.0)];
        textLabel1.backgroundColor = [UIColor clearColor];
        textLabel1.numberOfLines = 0;
        textLabel1.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel1.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel1.textAlignment = NSTextAlignmentLeft;
        textLabel1.text = [[dict allKeys] objectAtIndex:0];
        [cell.contentView addSubview:textLabel1];
        CGFloat h1 = [self GetSizeOfLabelForGivenText:textLabel1 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, shift + h1, 300.0, 20.0)];
        textLabel2.backgroundColor = [UIColor clearColor];
        textLabel2.numberOfLines = 0;
        textLabel2.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel2.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel2.textAlignment = NSTextAlignmentLeft;
        textLabel2.text = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
        [cell.contentView addSubview:textLabel2];
        CGFloat h2 = [self GetSizeOfLabelForGivenText:textLabel2 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        shift = shift + h1 + h2;
    }
    return cell;
}
#pragma mark -
#pragma mark - calculate table row height
- (CGFloat) getFirstRowHeight {
    return 49.0;
}
- (CGFloat) getSecondRowHeight {
    NSArray *keys = [self.placeCityDataSource allKeys];
    CGFloat totalHeight = 0.0;
    for(NSString *key in keys) {
        NSArray *cont = [self.placeCityDataSource objectForKey:key];
        
        CGFloat totalRowWidth = 0.0;
        for(NSString *val in cont) {
            totalRowWidth = totalRowWidth + ceil([val sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0]}].width) + 28.0;
            if (totalRowWidth > 320.0) break;
        }
        totalHeight = totalHeight + 75.0 + 25.0;
    }
    
    return totalHeight;
}
- (CGFloat) getThirdRowHeight {
    return 49.0;
}
- (CGFloat) getFourRowHeight {
    
    return [self getHeightForDataSource:self.educationDataSource];
}
- (CGFloat) getFifthRowHeight {
    return [self getHeightForDataSource:self.carrierDataSource];
}
- (CGFloat) getHeightForDataSource:(NSArray*) dataSource {
    CGFloat totalHeight = 0.0;
    CGSize constrainedSize = CGSizeMake(300.0  , 9999);
    for(NSDictionary *dict in dataSource) {
        UILabel *textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 300.0, 20.0)];
        textLabel1.backgroundColor = [UIColor clearColor];
        textLabel1.numberOfLines = 0;
        textLabel1.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel1.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel1.textAlignment = NSTextAlignmentLeft;
        textLabel1.text = [[dict allKeys] objectAtIndex:0];
        CGFloat h1 = [self GetSizeOfLabelForGivenText:textLabel1 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 300.0, 20.0)];
        textLabel2.backgroundColor = [UIColor clearColor];
        textLabel2.numberOfLines = 0;
        textLabel2.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel2.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel2.textAlignment = NSTextAlignmentLeft;
        textLabel2.text = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
        CGFloat h2 = [self GetSizeOfLabelForGivenText:textLabel2 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        totalHeight = totalHeight + h1 + h2 + 5;
    }
    return totalHeight;
}
- (CGFloat) calculateSectionHeight:(NSArray*) content {
    CGFloat totalRowWidth = 0.0;
    CGFloat totalHeight = 0.0;
    for(NSString *val in content) {
        totalRowWidth = totalRowWidth + ceil([val sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0]}].width) + 28.0;
        if (totalRowWidth > 320.0) {
            totalHeight = totalHeight + 68.0 + 8;
            totalRowWidth = 0.0;
        }
    }
    return totalHeight;
}
-(CGSize) GetSizeOfLabelForGivenText:(UILabel*)label Font:(UIFont*)fontForLabel Size:(CGSize) constraintSize{
    label.numberOfLines = 0;
    CGRect labelRect = [label.text boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:fontForLabel} context:nil];
    return (labelRect.size);
}

#pragma mark -
#pragma mark - HEBubbleViewDataSource

- (NSInteger)numberOfItemsInBubbleView:(HEBubbleView *)bubbleView {
    NSArray *keys = [self.placeCityDataSource allKeys];
    NSString *key = [keys objectAtIndex:bubbleView.tag];
    NSArray *sources = [self.placeCityDataSource objectForKey:key];
    return sources.count;
}


- (HEBubbleViewItem *)bubbleView:(HEBubbleView *)bubbleView bubbleItemForIndex:(NSInteger)index {
    
    NSString *itemIdentifier = @"bubble";
    
    HEBubbleViewItem *bubble = [bubbleView dequeueItemUsingReuseIdentifier:itemIdentifier];
    if (!bubble) {
        bubble = [[HEBubbleViewItem alloc] initWithReuseIdentifier:itemIdentifier];
    }
    bubble.unselectedBorderColor = [UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1];
    bubble.unselectedBGColor = [UIColor clearColor];
    //bubble.unselectedBGColor = [UIColor clearColor];
    bubble.unselectedTextColor = [UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1];
    bubble.selectedBorderColor = [UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1];
    bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
    bubble.selectedTextColor = [UIColor colorWithRed:80.0/255.0 green:227.0/255.0 blue:194.0/255.0 alpha:1];
    
    NSArray *keys = [self.placeCityDataSource allKeys];
    NSString *key = [keys objectAtIndex:bubbleView.tag];
    NSArray *sources = [self.placeCityDataSource objectForKey:key];
    
    [bubble.textLabel setText:[sources objectAtIndex:index]];
    return bubble;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   
    if(_photosArray.count - indexPath.row == 1) {
        
    }
    
    /*
    if (_photosArray.count == 1) {
        return;
    }
    [self.collectionView performBatchUpdates:^{
        [_photosArray removeObjectAtIndex:indexPath.item];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self.collectionView reloadData];
    }];
    */
}
-(IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //open photo
            self.collectionView.hidden = NO;
            self.infoTableView.hidden = YES;
            break;}
        case 1:{
            //open info
            self.collectionView.hidden = YES;
            self.infoTableView.hidden = NO;
            
            break;}
    }
}

//==============================================================================

- (IBAction)downButtonTap: (id)sender
{
    if ([self.delegate respondsToSelector: @selector(profileWillBeHidden)])
        [self.delegate profileWillBeHidden];

    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

//==============================================================================

@end

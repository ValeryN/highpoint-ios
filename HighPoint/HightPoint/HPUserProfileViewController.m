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
#import "HPUserProfileTableHeaderView.h"

#import "HPUserInfoSecondRowTableViewCell.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
#import "UIDevice+HighPoint.h"
#import "HPMakeAvatarViewController.h"
#import "NMRangeSlider.h"

//#undef SCREEN_HEIGHT
//#ifdef IS_IPHONE_5
//#define SCREEN_HEIGHT 568
//#else
//#define SCREEN_HEIGHT 480
//#endif
#define ScreenBound       ([[UIScreen mainScreen] bounds])
#define ScreenHeight      (ScreenBound.size.height)


#define CONSTRAINT_GREENBUTTON_FROM_BOTTOM 47.0
#define CONSTRAINT_TRASHBUTTON_FROM_LEFT 274.0
#define FIRST_ROW_HEIGHT_CONST 90.0
#define BIBBLE_VIEW_WIDTH_CONST 290.0
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
    [self fixUserConstraint];
    
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    self.carousel.pagingEnabled = YES;
    self.carousel.hidden = YES;
    self.backButton.hidden = YES;
    self.barTitle.hidden = YES;
    
    self.carousel.backgroundColor = [UIColor colorWithRed: 30.0/255.0
                                     green: 29.0/255.0
                                     blue: 48.0/255.0
                                     alpha: 1.0];
}
- (void) fixUserConstraint
{
    
    if (![UIDevice hp_isWideScreen])
    {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        self.carousel.translatesAutoresizingMaskIntoConstraints = YES;
        self.infoTableView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.collectionView
                                                              attribute: NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: self.view
                                                              attribute: NSLayoutAttributeHeight
                                                             multiplier: 0.88
                                                               constant: 0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.infoTableView
                                                              attribute: NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: nil
                                                              attribute: NSLayoutAttributeHeight
                                                             multiplier: 1.0
                                                               constant: 417]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.carousel
                                                              attribute: NSLayoutAttributeHeight
                                                              relatedBy: NSLayoutRelationEqual
                                                                 toItem: self.view
                                                              attribute: NSLayoutAttributeHeight
                                                             multiplier: 1.0
                                                               constant: 0]];

        
        }
}

- (void)setupPhotosArray
{
    [_photosArray removeAllObjects];
    _photosArray = nil;
    _photosArray = [NSMutableArray array];
    for (NSInteger i = 1; i <= 16; i++) {
        NSString *photoName = [NSString stringWithFormat:@"%ld.jpg",(long)i];
        UIImage *photo = [UIImage imageNamed:photoName];
        [_photosArray addObject:photo];
    }
    //Eye.png
    UIImage *photo = [UIImage imageNamed:@"Camera"];
    [_photosArray addObject:photo];
////////////////////////////////
    self.userDataSource = @[@"РАСХОДЫ", @"ЛЮБИМЫЕ МЕСТА", @"ЯЗЫКИ", @"ОБРАЗОВАНИЕ", @"КАРЬЕРА"];
    NSMutableArray *place1 = [NSMutableArray arrayWithArray:@[@"Dulwich Park", @"Greenwich", @"Covent Garden", @"Borough Market", @"The Hob", @"Добавить место"]];
    NSMutableArray *place2 = [NSMutableArray arrayWithArray:@[@"Notre Dame", @"De la Concorde", @"De la Bastille", @"Brasserie Bofinger", @"Promenade Plantee", @"Добавить место"]];
    NSMutableArray *place3 = [NSMutableArray arrayWithArray:@[@"Anthology Film Archives", @"Bamonte's", @"Housing Works Bookstore Cafe", @"Shopsin's", @"The Hog Pit", @"Добавить место"]];
    self.placeCityDataSource = [NSMutableDictionary dictionaryWithDictionary:@{@"London": place1, @"Paris": place2, @"New York": place3}];
    NSArray *ed1 = @[@"Академия гос. службы",@"Руководитель", @"c 1917"];
    NSArray *ed2 = @[@"МФТИ",@"Физик-лирик", @"c 2004"];
    NSArray *ed3 = @[@"Кыштымский заборостроительный техникум",@"Сортировщик 6 разряда", @"c 2010"];
    self.educationDataSource = [NSMutableArray arrayWithArray:@[ed1,ed2, ed3]];
    ed1 = @[@"Правительство",@"Председатель", @""];
    ed2 = @[@"Администрация Кыштымского района",@"Начальник департамента", @""];
    ed3 = @[@"ЖЭУ №5",@"Сантехник", @""];
    self.carrierDataSource = [NSMutableArray arrayWithArray:@[ed1,ed2, ed3]];
    
    self.languages = [NSMutableArray arrayWithArray:@[@"Русский",@"Английский", @"Албанский", @"Китайский", @"Хинди", @"Добавить язык"]];
////////////////////////////////
    
}

//==============================================================================
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.automaticallyAdjustsScrollViewInsets = NO; //fix table header places
    self.prepareForDeleteIndex = -1;


}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}
#pragma mark - collection view
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
    HPUserProfileTableHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"HPUserProfileTableHeaderView" owner:self options:nil] objectAtIndex:0];
    headerView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
    headerView.headerTextLabel.backgroundColor = [UIColor clearColor];
    headerView.headerTextLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0 ];
    headerView.headerTextLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    headerView.headerTextLabel.text = [self.userDataSource objectAtIndex:section];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *townCellIdentifier = @"FirstRowCellIdent";
    static NSString *cellIdentifier1 = @"CellIdent1";
    static NSString *cellIdentifier2 = @"CellIdent2";
    static NSString *cellIdentifier3 = @"CellIdent3";
    static NSString *cellIdentifier4 = @"CellIdent4";
    static NSString *cellIdentifier5 = @"CellIdent5";
    
    if(indexPath.row == 0 && indexPath.section == 0) {
        HPUserProfileFirstRowTableViewCell *townCell;
        townCell = (HPUserProfileFirstRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (townCell == nil) {
            townCell = [[HPUserProfileFirstRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserProfileFirstRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserProfileFirstRowTableViewCell class]])
                {
                    townCell = (HPUserProfileFirstRowTableViewCell *)currentObject;
                    break;
                }
            }
        }
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return [self configureFirstCell:townCell];
    }
    else if (indexPath.row == 0 && indexPath.section == 1) {
        HPUserInfoSecondRowTableViewCell *townCell;
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier2];
            
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
        HPUserInfoSecondRowTableViewCell *townCell;
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier3];
            
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
        return [self configureThirdCell:townCell];
    }
    else if (indexPath.row == 0 && indexPath.section == 3) {
        HPUserInfoSecondRowTableViewCell *townCell;
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier4];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier4];
            
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
        townCell = (HPUserInfoSecondRowTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier5];
        if (townCell == nil) {
            townCell = [[HPUserInfoSecondRowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier5];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"HPUserInfoSecondRowTableViewCell" owner:nil options:nil];
            
            for(id currentObject in topLevelObjects)
            {
                if([currentObject isKindOfClass:[HPUserInfoSecondRowTableViewCell class]])
                {
                    townCell = (HPUserInfoSecondRowTableViewCell *)currentObject;
                    break;
                }
            }
            townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
            UITableViewCell *cell = [self configureFifthCell:townCell];
            return cell;
        }
        
        townCell.contentView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
        return townCell;
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
//entertainment price
- (UITableViewCell*) configureFirstCell:(HPUserProfileFirstRowTableViewCell*) cell {
    
    //UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, cell.contentView.frame.size.width - 26, cell.contentView.frame.size.height)];
    cell.cellTextLabel.backgroundColor = [UIColor clearColor];
    cell.cellTextLabel.numberOfLines = 0;
    cell.cellTextLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
    cell.cellTextLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
    cell.cellTextLabel.textAlignment = NSTextAlignmentLeft;
    cell.delegate = self;
    cell.user = self.user;
    [cell configureSlider:NO];
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
//user favorite places
- (UITableViewCell*) configureSecondCell:(UITableViewCell*) cell {
    
    for(UIView *v in  [cell.contentView subviews]) {
        if(v.tag != 7007 && v.tag != 7008)
            [v removeFromSuperview];
    }
    //[cell.contentView addSubview:t];
    NSArray *keys = [self.placeCityDataSource allKeys];
    CGFloat shift = 10.0;
    NSInteger bubbleTag = 0;
    for(NSString *key in keys) {
        //add block label
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0, shift, cell.contentView.frame.size.width - 26, 20.0)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.numberOfLines = 0;
        textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.text = key;
        textLabel.tag = 21000 + bubbleTag;
        [cell.contentView addSubview:textLabel];
        
        UIButton* deleteButton = [UIButton buttonWithType: UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(12, shift, 22.0, 22.0);
        [deleteButton setBackgroundImage: [UIImage imageNamed:@"Remove"] forState: UIControlStateNormal];
        [deleteButton setBackgroundImage: [UIImage imageNamed:@"Remove Tap"] forState: UIControlStateHighlighted];
        deleteButton.tag = 21000 + bubbleTag;
        [deleteButton addTarget: self
                         action: @selector(deletePlace:)
            forControlEvents: UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
        
        HEBubbleView *bubbleView = [[HEBubbleView alloc] initWithFrame:CGRectMake(41.0, shift + 20.0, BIBBLE_VIEW_WIDTH_CONST, 50.0)];
        bubbleView.layer.cornerRadius = 1;
        bubbleView.bubbleDataSource = self;
        bubbleView.bubbleDelegate = self;
        //self.bubbleView.selectionStyle = HEBubbleViewSelectionStyleNone;
        bubbleView.backgroundColor = [UIColor clearColor];
        bubbleView.itemHeight = 20.0;
        bubbleView.itemPadding = 5.0;
        bubbleView.tag = bubbleTag;
        
        bubbleTag++;
        [bubbleView reloadData];
        //CGSize s = bubbleView.contentSize;
        CGRect rect = bubbleView.frame;
        rect.size.height = bubbleView.contentSize.height;
        bubbleView.frame = rect;
        [cell.contentView addSubview:bubbleView];
        shift = shift + bubbleView.frame.size.height + 20.0;
    }
    //add new town
    HPAddNewTownView *customView = [HPAddNewTownView createView];
    CGRect viewFrame = customView.frame;
    customView.label.text = @"Добавить город";
    viewFrame.origin.x = 0;
    viewFrame.origin.y = shift;
    customView.frame = viewFrame;
    customView.delegate = self;
    [cell.contentView addSubview:customView];
      return cell;
}
//user languages
- (UITableViewCell*) configureThirdCell:(UITableViewCell*) cell {
    
    for(UIView *v in  [cell.contentView subviews]) {
        if(v.tag != 7007)
            [v removeFromSuperview];
    }
    
    CGFloat shift = 10.0;
    HEBubbleView *bubbleView = [[HEBubbleView alloc] initWithFrame:CGRectMake(41.0, shift, BIBBLE_VIEW_WIDTH_CONST, 50.0)];
    bubbleView.layer.cornerRadius = 1;
    bubbleView.bubbleDataSource = self;
    bubbleView.bubbleDelegate = self;
    //self.bubbleView.selectionStyle = HEBubbleViewSelectionStyleNone;
    bubbleView.backgroundColor = [UIColor clearColor];
    bubbleView.itemHeight = 20.0;
    bubbleView.itemPadding = 5.0;
    bubbleView.tag = 1001;
    [bubbleView reloadData];
    //CGSize s = bubbleView.contentSize;
    CGRect rect = bubbleView.frame;
    rect.size.height = bubbleView.contentSize.height;
    bubbleView.frame = rect;
    [cell.contentView addSubview:bubbleView];
    return cell;
}
- (UITableViewCell*) configureFourCell:(UITableViewCell*) cell {
    return [self configureCell:cell forDataSource:self.educationDataSource andText:@"Добавить учебное заведение"];
}
- (UITableViewCell*) configureFifthCell:(UITableViewCell*) cell {
    return [self configureCell:cell forDataSource:self.carrierDataSource andText:@"Добавить достижение"];
}
- (UITableViewCell*) configureCell:(UITableViewCell*) cell  forDataSource:(NSArray*) dataSource andText:(NSString*) text{
    for(UIView *v in  [cell.contentView subviews]) {
        if(v.tag != 7007)
            [v removeFromSuperview];
    }
    
    CGFloat shift = 5.0;
    //cell.cellTextLabel.hidden = YES;
    CGSize constrainedSize = CGSizeMake(300.0  , 9999);
    int index = 0;
    for(NSArray *dict in dataSource) {
        UILabel *textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(46.0, shift, BIBBLE_VIEW_WIDTH_CONST - 40, 60.0)];
        textLabel1.backgroundColor = [UIColor clearColor];
        textLabel1.numberOfLines = 0;
        textLabel1.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel1.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel1.textAlignment = NSTextAlignmentLeft;
        textLabel1.text = [dict objectAtIndex:0];
        
        if([text isEqualToString:@"Добавить учебное заведение"]) {
            textLabel1.tag = 23000 + index;
        }
        if([text isEqualToString:@"Добавить достижение"]) {
            textLabel1.tag = 24000 + index;
        }
        
        CGFloat h1 = [self GetSizeOfLabelForGivenText:textLabel1 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        CGRect tempRect = textLabel1.frame;
        tempRect.size.height = h1;
        textLabel1.frame = tempRect;
        [cell.contentView addSubview:textLabel1];
        
        
        UIButton* deleteButton = [UIButton buttonWithType: UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(12, shift, 22.0, 22.0);
        [deleteButton setBackgroundImage: [UIImage imageNamed:@"Remove"] forState: UIControlStateNormal];
        [deleteButton setBackgroundImage: [UIImage imageNamed:@"Remove Tap"] forState: UIControlStateHighlighted];
        [deleteButton addTarget: self
                         action: @selector(deleteEducationOrWork:)
               forControlEvents: UIControlEventTouchUpInside];
        
        if([text isEqualToString:@"Добавить учебное заведение"]) {
            deleteButton.tag = 23000 + index;
        }
        if([text isEqualToString:@"Добавить достижение"]) {
            deleteButton.tag = 24000 + index;
        }
        
        [cell.contentView addSubview:deleteButton];
        
        
        UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(46.0, shift + h1, BIBBLE_VIEW_WIDTH_CONST- 40, 60.0)];
        textLabel2.backgroundColor = [UIColor clearColor];
        textLabel2.numberOfLines = 0;
        textLabel2.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel2.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel2.textAlignment = NSTextAlignmentLeft;
        textLabel2.text = [dict objectAtIndex:1];
        CGFloat h2 = [self GetSizeOfLabelForGivenText:textLabel2 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        tempRect = textLabel2.frame;
        tempRect.size.height = h2;
        textLabel2.frame = tempRect;
        [cell.contentView addSubview:textLabel2];
        
        UILabel *textLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(46.0, shift + h1 + h2, BIBBLE_VIEW_WIDTH_CONST- 40, 60.0)];
        textLabel3.backgroundColor = [UIColor clearColor];
        textLabel3.numberOfLines = 0;
        textLabel3.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel3.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1.0];
        textLabel3.textAlignment = NSTextAlignmentLeft;
        textLabel3.text = [dict objectAtIndex:2];
        CGFloat h3 = [self GetSizeOfLabelForGivenText:textLabel3 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        tempRect = textLabel3.frame;
        tempRect.size.height = h3;
        textLabel3.frame = tempRect;
        [cell.contentView addSubview:textLabel3];
        index ++;
        
        
        shift = shift + h1 + h2 + h3;
    }
    HPAddNewTownView *customView = [HPAddNewTownView createView];
    
    customView.frame = CGRectMake(0, 0, 320, 46);
    CGRect viewFrame = customView.frame;
    customView.label.text = text;
    viewFrame.origin.x = 0;
    viewFrame.origin.y = shift;
    customView.frame = viewFrame;
    customView.delegate = self;
    [cell.contentView addSubview:customView];
    return cell;
}
#pragma mark -
#pragma mark - calculate table row height
- (CGFloat) getFirstRowHeight {
    return FIRST_ROW_HEIGHT_CONST;
}
- (CGFloat) getSecondRowHeight {
    NSArray *keys = [self.placeCityDataSource allKeys];
    NSInteger bubbleTag = 0;
    CGFloat totalHeight = 20.0;
    for(int i = 0; i< keys.count; i++) {
        //add block label
        HEBubbleView *bubbleView = [[HEBubbleView alloc] initWithFrame:CGRectMake(41.0, totalHeight + 20.0, BIBBLE_VIEW_WIDTH_CONST, 50.0)];
        bubbleView.layer.cornerRadius = 1;
        bubbleView.bubbleDataSource = self;
        bubbleView.bubbleDelegate = self;
        bubbleView.itemHeight = 20.0;
        bubbleView.itemPadding = 5.0;
        bubbleView.tag = bubbleTag;
        bubbleTag++;
        [bubbleView reloadData];
        CGRect rect = bubbleView.frame;
        rect.size.height = bubbleView.contentSize.height;
        bubbleView.frame = rect;
        totalHeight = totalHeight + bubbleView.frame.size.height + 20.0;
    }
    return totalHeight + 48.0;
}
- (CGFloat) getThirdRowHeight {
    CGFloat totalHeight = 20.0;
    HEBubbleView *bubbleView = [[HEBubbleView alloc] initWithFrame:CGRectMake(41.0, totalHeight, BIBBLE_VIEW_WIDTH_CONST, 50.0)];
    bubbleView.layer.cornerRadius = 1;
    bubbleView.bubbleDataSource = self;
    bubbleView.bubbleDelegate = self;
    bubbleView.itemHeight = 20.0;
    bubbleView.itemPadding = 5.0;
    bubbleView.tag = 1001;
    
    [bubbleView reloadData];
    CGRect rect = bubbleView.frame;
    rect.size.height = bubbleView.contentSize.height;
    bubbleView.frame = rect;
    totalHeight = bubbleView.frame.size.height + totalHeight;
    //return 99.0;
    return totalHeight;
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
    for(NSArray *dict in dataSource) {
        UILabel *textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 300.0, 20.0)];
        textLabel1.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel1.textAlignment = NSTextAlignmentLeft;
        textLabel1.text = [dict  objectAtIndex:0];
        CGFloat h1 = [self GetSizeOfLabelForGivenText:textLabel1 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 300.0, 20.0)];
        textLabel2.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel2.textAlignment = NSTextAlignmentLeft;
        textLabel2.text = [dict objectAtIndex:1];
        CGFloat h2 = [self GetSizeOfLabelForGivenText:textLabel2 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        UILabel *textLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0, 300.0, 20.0)];
        textLabel3.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        textLabel3.textAlignment = NSTextAlignmentLeft;
        textLabel3.text = [dict objectAtIndex:2];
        CGFloat h3 = [self GetSizeOfLabelForGivenText:textLabel3 Font:[UIFont fontWithName:@"FuturaPT-Book" size:16.0 ] Size:constrainedSize].height;
        totalHeight = totalHeight + h1 + h2 + h3 + 5;
    }
    return totalHeight + 48;
}
- (CGFloat) calculateSectionHeight:(NSArray*) content {
    CGFloat totalRowWidth = 0.0;
    CGFloat totalHeight = 0.0;
    for(NSString *val in content) {
        totalRowWidth = totalRowWidth + ceil([val sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"FuturaPT-Book" size:16.0]}].width + 14);
        if (totalRowWidth > BIBBLE_VIEW_WIDTH_CONST) {
            totalHeight = totalHeight + 80;
            totalRowWidth = 0.0;
        }
    }
    NSLog(@"%f", totalHeight);
    return totalHeight;
}
-(CGSize) GetSizeOfLabelForGivenText:(UILabel*)label Font:(UIFont*)fontForLabel Size:(CGSize) constraintSize{
    label.numberOfLines = 0;
    CGRect labelRect = [label.text boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:fontForLabel} context:nil];
    return (labelRect.size);
}
- (void) sliderValueChange:(NMRangeSlider*) sender {
    
}
#pragma mark -
#pragma mark - HEBubbleViewDataSource

- (NSInteger)numberOfItemsInBubbleView:(HEBubbleView *)bubbleView {
    if(bubbleView.tag >= 0 && bubbleView.tag < 1000) {
        return [self getSourcesArray:bubbleView].count;
    } else {
        return self.languages.count;
    }
}
- (NSArray*) getSourcesArray:(HEBubbleView *)bubbleView {
    NSArray *keys = [self.placeCityDataSource allKeys];
    NSString *key = [keys objectAtIndex:bubbleView.tag];
    NSArray *sources = [self.placeCityDataSource objectForKey:key];
    return sources;
}

- (HEBubbleViewItem *)bubbleView:(HEBubbleView *)bubbleView bubbleItemForIndex:(NSInteger)index {
    
    NSString *itemIdentifier = @"bubble";
    
    HEBubbleViewItem *bubble = [bubbleView dequeueItemUsingReuseIdentifier:itemIdentifier];
    if (!bubble) {
        bubble = [[HEBubbleViewItem alloc] initWithReuseIdentifier:itemIdentifier];
    }
    NSLog(@"%d", bubbleView.tag);
    if(bubbleView.tag >= 0 && bubbleView.tag < 1000) {
        if([self getSourcesArray:bubbleView].count - index != 1) {
            bubble.unselectedBorderColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.3];
            bubble.unselectedBGColor = [UIColor clearColor];
            //bubble.unselectedBGColor = [UIColor clearColor];
            bubble.unselectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1];
            bubble.selectedBorderColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.3];
            bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
            bubble.selectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1];
        } else {
            bubble.unselectedBorderColor = [UIColor clearColor];
            bubble.unselectedBGColor = [UIColor clearColor];
            //bubble.unselectedBGColor = [UIColor clearColor];
            bubble.unselectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
            bubble.selectedBorderColor = [UIColor clearColor];
            bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
            bubble.selectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
        }
        bubble.textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        NSArray *keys = [self.placeCityDataSource allKeys];
        NSString *key = [keys objectAtIndex:bubbleView.tag];
        NSArray *sources = [self.placeCityDataSource objectForKey:key];
        [bubble.textLabel setText:[sources objectAtIndex:index]];
        
        if(self.currentBubble.tag == bubbleView.tag && index == self.prepareForDeleteIndex) {
            bubble.unselectedBorderColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1];
            bubble.selectedBorderColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1];
        }
        
        
        return bubble;
    } else {
        if(self.languages.count - index != 1) {
            bubble.unselectedBorderColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.3];
            bubble.unselectedBGColor = [UIColor clearColor];
            //bubble.unselectedBGColor = [UIColor clearColor];
            bubble.unselectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1];
            bubble.selectedBorderColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.3];
            bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
            bubble.selectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1];
        } else {
            bubble.unselectedBorderColor = [UIColor clearColor];
            bubble.unselectedBGColor = [UIColor clearColor];
            //bubble.unselectedBGColor = [UIColor clearColor];
            bubble.unselectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
            bubble.selectedBorderColor = [UIColor clearColor];
            bubble.selectedBGColor = [UIColor clearColor];//[UIColor colorWithRed:0.784 green:0.847 blue:0.910 alpha:1];
            bubble.selectedTextColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:0.4];
        }
        bubble.textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
        //NSArray *keys = [self.placeCityDataSource allKeys];
        //NSString *key = [keys objectAtIndex:bubbleView.tag];
        //NSArray *sources = [self.placeCityDataSource objectForKey:key];
        [bubble.textLabel setText:[self.languages objectAtIndex:index]];
        if(self.currentBubble.tag == bubbleView.tag && index == self.prepareForDeleteIndex) {
            bubble.unselectedBorderColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1];
            bubble.selectedBorderColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1];
        }

        return bubble;
    }
}
#pragma mark -
#pragma mark - UITextFieldDelegate for text into bubble
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    [textField resignFirstResponder];
    if(textField.text.length > 0 && textField.tag >= 0 && textField.tag < 1000) { //adding place
        NSLog(@"%@", self.placeCityDataSource);
        NSArray *keys = [self.placeCityDataSource allKeys];
        NSString *key = [keys objectAtIndex:textField.tag];
        NSMutableArray *sources = [self.placeCityDataSource objectForKey:key];
        [[self.placeCityDataSource objectForKey:key] insertObject:textField.text atIndex:sources.count - 1];
        NSLog(@"%@", self.placeCityDataSource);
        //[self.currentBubble removeFromSuperview];
        
    } else if(textField.text.length > 0 && textField.tag == 1001) { //adding language
        
        [self.languages insertObject:textField.text atIndex:self.languages.count -1];
        
    }
    [self.currentBubble reloadData];
    [self.infoTableView reloadData];
    return YES;
}
- (void) backSpaceTap {
    if(self.currentBubbleTextField.text.length == 0) {
        
        NSMutableArray *arr = [NSMutableArray new];
        for( id v in self.currentBubble.subviews) {
            if([v isKindOfClass:[HEBubbleViewItem class]]) {
                [arr addObject:v];
            }
        }
        if(arr.count >= 2) {
            self.backSpaceTapCount++;
            self.prepareForDeleteIndex = arr.count - 2;
            [self.currentBubble reloadData];
            [self.currentBubbleTextField becomeFirstResponder];
            if(self.backSpaceTapCount == 2) {
                self.backSpaceTapCount = 0;
                if(self.currentBubble.tag >= 0 && self.currentBubble.tag < 1000) {
                    NSArray *keys = [self.placeCityDataSource allKeys];
                    NSString *key = [keys objectAtIndex:self.currentBubbleTextField.tag];
                    [[self.placeCityDataSource objectForKey:key] removeObjectAtIndex:self.prepareForDeleteIndex];
                } else {
                    [self.languages removeObjectAtIndex:self.prepareForDeleteIndex];
                }
                self.prepareForDeleteIndex = -1;
                [self.currentBubble reloadData];
                [self.infoTableView reloadData];
            }
        }
    }
}
- (void)bubbleView:(HEBubbleView *)bubbleView didSelectBubbleItemAtIndex:(NSInteger)index {
    
    int i = 0;
    for( id v in bubbleView.subviews) {
        if([v isKindOfClass:[HEBubbleViewItem class]]) {
            if(i == index) {
                HEBubbleViewItem *bubble = (HEBubbleViewItem*) v;
                NSLog(@"%@", bubble.textLabel.text);
                if([bubble.textLabel.text isEqualToString:@"Добавить место"] || [bubble.textLabel.text isEqualToString:@"Добавить язык"]) {
                    HPBubbleTextField *inpText = [[HPBubbleTextField alloc] initWithFrame:CGRectMake(0, 0, bubble.frame.size.width, bubble.frame.size.height)];
                    inpText.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0 ];
                    inpText.textAlignment = NSTextAlignmentCenter;
                    bubble.textLabel.hidden = YES;
                    inpText.textColor = [UIColor colorWithRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1];
                    [bubble insertSubview:inpText aboveSubview:bubble.textLabel];
                    inpText.delegate = self;
                    inpText.backSpaceDelegate = self;
                    inpText.tag = bubbleView.tag;
                    self.currentBubble = bubbleView;
                    self.currentBubbleTextField = inpText;
                    [inpText becomeFirstResponder];
                    break;
                }
            }
        }
        i++;
    }
    //
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   if(_photosArray.count - indexPath.row == 1) {
        [self addPhotoMenuShow];
    } else {
        [self.carousel scrollToItemAtIndex:indexPath.row animated:NO];
        
        [UIView transitionWithView:self.view
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                        animations:^ {
                            self.carousel.hidden = NO;
                            self.collectionView.hidden = YES;
                            self.segmentControl.hidden = YES;
                            self.downButton.hidden = YES;
                            self.backButton.hidden = NO;
                            self.barTitle.hidden = NO;
                        }
                        completion:^(BOOL finished){
                            
                        }];
        
        self.barTitle.font = [UIFont fontWithName:@"FuturaPT-Light" size:18.0f];
        self.barTitle.textColor = [UIColor whiteColor];
        self.barTitle.text = [NSString stringWithFormat:@"%d из %d",self.carousel.currentItemIndex + 1, _photosArray.count - 1];
        
        if(!self.greenButton && !self.tappedGreenButton) {
            self.greenButton = [Utils getViewForGreenButtonForText:@"Сделать юзерпиком"  andTapped:NO];
            self.tappedGreenButton = [Utils getViewForGreenButtonForText:@"Сделать юзерпиком"  andTapped:YES];
            CGRect rect = self.greenButton.frame;
            rect.origin.x = 17.0;
            rect.origin.y = ScreenHeight - CONSTRAINT_GREENBUTTON_FROM_BOTTOM;
            self.greenButton.frame = rect;
            self.tappedGreenButton.frame = rect;
  
            
            UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
            newButton.frame = rect;
            [newButton addTarget: self
                          action: @selector(makeAvatarTapDown)
                forControlEvents: UIControlEventTouchDown];
            [newButton addTarget: self
                          action: @selector(makeAvatarTapUp)
                forControlEvents: UIControlEventTouchUpInside];
            self.tappedGreenButton.hidden = YES;
            [self.view addSubview:self.greenButton];
            [self.view addSubview:self.tappedGreenButton];
            [self.view addSubview:newButton];
            
            self.deletButton = [UIButton buttonWithType: UIButtonTypeCustom];
            self.deletButton.frame = CGRectMake(CONSTRAINT_TRASHBUTTON_FROM_LEFT, ScreenHeight - CONSTRAINT_GREENBUTTON_FROM_BOTTOM, 32.0, 32.0);
            [self.deletButton setBackgroundImage: [UIImage imageNamed:@"Trash"] forState: UIControlStateNormal];
            [self.deletButton setBackgroundImage: [UIImage imageNamed:@"Trash Tap"] forState: UIControlStateHighlighted];
            [self.deletButton addTarget: self
                          action: @selector(deleteImage)
                forControlEvents: UIControlEventTouchUpInside];
            [self.view addSubview:self.deletButton];
        }
        //self.infoTableView.hidden = YES;
    }
}
- (void) makeAvatarTapDown {
    self.greenButton.hidden = YES;
    self.tappedGreenButton.hidden = NO;
}
- (void) makeAvatarTapUp {
    self.greenButton.hidden = NO;
    self.tappedGreenButton.hidden = YES;
    HPMakeAvatarViewController *avaView = [[HPMakeAvatarViewController alloc] initWithNibName: @"HPMakeAvatarViewController" bundle: nil];
    
    UIImage *image = [self.photosArray objectAtIndex:self.carousel.currentItemIndex];
    
    //
    
    //avaView.cImg = image;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:avaView animated:YES];
    avaView.sourceImage = image;
    
    //[self addChildViewController: avaView];
    //[self.view addSubview: avaView.view];
    //[avaView didMoveToParentViewController:self];
}
- (void) deleteImage {
    [self.photosArray removeObjectAtIndex:self.carousel.currentItemIndex];
    [self.collectionView reloadData];
    [self.carousel reloadData];
}
- (void) addPhotoMenuShow {
    if (!self.addPhotoViewController) {
        self.addPhotoViewController = [[HPAddPhotoMenuViewController alloc] initWithNibName: @"HPAddPhotoMenuViewController" bundle: nil];
        self.addPhotoViewController.delegate = self;
    }
    
    self.addPhotoViewController.screenShoot = [self blureCurrentSelfView];
    [self addChildViewController: self.addPhotoViewController];
    [self.view addSubview: self.addPhotoViewController.view];
    [self.addPhotoViewController didMoveToParentViewController:self];
    
    //self.addPhotoViewController.modalPresentationStyle = UIModalPresentationCustom;
    //[self presentViewController:self.addPhotoViewController animated:YES completion:nil];
}
#pragma mark -
#pragma mark - HPAddNewTownViewDelegate
- (void) showNextView:(HPAddNewTownView*) view {
    if([view.label.text isEqualToString:@"Добавить город"]) {
        HPSelectTownViewController *town = [[HPSelectTownViewController alloc] initWithNibName: @"HPSelectTown" bundle: nil];
        town.delegate = self;
        //self.savedDelegate = self.navigationController.delegate;
        self.navigationController.delegate = nil;
        [self.navigationController pushViewController:town animated:YES];
        NSLog(@"%@", self.navigationController);
    } else if([view.label.text isEqualToString:@"Добавить учебное заведение"]) {
        HPAddEducationViewController *education = [[HPAddEducationViewController alloc] initWithNibName: @"HPAddEducationViewController" bundle: nil];
        education.isItForEducation = YES;
        education.delegate = self;
        self.navigationController.delegate = nil;
        [self.navigationController pushViewController:education animated:YES];
    }else if([view.label.text isEqualToString:@"Добавить достижение"]) {
        HPAddEducationViewController *education = [[HPAddEducationViewController alloc] initWithNibName: @"HPAddEducationViewController" bundle: nil];
        education.isItForEducation = NO;
        education.delegate = self;
        self.navigationController.delegate = nil;
        [self.navigationController pushViewController:education animated:YES];
    }
}
- (void) deletePlace:(id) sender {
    UIButton *but = (UIButton*) sender;
    NSLog(@"%d", but.tag);
    but.selected = !but.selected;
    NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:0 inSection:1] ;
    UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath:nowIndex];
    if(but.selected) {
        [but setBackgroundImage: [UIImage imageNamed:@"Cancel"] forState: UIControlStateNormal];
        [but setBackgroundImage: [UIImage imageNamed:@"Cancel Tap"] forState: UIControlStateHighlighted];
        if(cell) {
            NSArray *viewArray = [cell.contentView subviews];
            int num = 0;
            for(id v in viewArray) {
                if([v isKindOfClass:[UILabel class]]) {
                    UILabel *l = (UILabel*) v;
                    if(but.tag == l.tag) {
                        NSLog(@"ooo");
                        UIButton *realDelete = [[UIButton alloc] initWithFrame:CGRectMake(220, l.frame.origin.y, 100, 23)];
                        realDelete.tag = 7008;
                        [realDelete setContentMode:UIViewContentModeScaleAspectFit];
                        realDelete.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16];
                        [realDelete setTitle:@"Удалить" forState:UIControlStateNormal];
                        [realDelete setTitle:@"Удалить" forState:UIControlStateHighlighted];
                        [realDelete setTitleColor:[UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1] forState:UIControlStateNormal];
                        [realDelete setTitleColor:[UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1] forState:UIControlStateHighlighted];
                        [cell.contentView addSubview:realDelete];
                        break;
                    }
                    num ++;
                }
            }
        }

        
        } else {
            [but setBackgroundImage: [UIImage imageNamed:@"Remove"] forState: UIControlStateNormal];
            [but setBackgroundImage: [UIImage imageNamed:@"Remove Tap"] forState: UIControlStateHighlighted];
            if(cell) {
                NSArray *viewArray = [cell.contentView subviews];
                for(id v in viewArray) {
                    if([v isKindOfClass:[UIButton class]]) {
                        UIButton *l = (UIButton*) v;
                        if(l.tag == 7008) {
                            [l removeFromSuperview];
                            break;
                        }
                    }
                }
            }

    }
    
    
    //get cell for adding delete button
    //[self.infoTableView reloadData];
}
- (void) deleteEducationOrWork:(id) sender {
    UIButton *but = (UIButton*) sender;
    NSLog(@"%d", but.tag/1000 - 20);
    but.selected = !but.selected;
    
    NSIndexPath *nowIndex = [NSIndexPath indexPathForRow:0 inSection:but.tag/1000 - 20] ;
    UITableViewCell *cell = [self.infoTableView cellForRowAtIndexPath:nowIndex];
    
    if(but.selected) {
        [but setBackgroundImage: [UIImage imageNamed:@"Cancel"] forState: UIControlStateNormal];
        [but setBackgroundImage: [UIImage imageNamed:@"Cancel Tap"] forState: UIControlStateHighlighted];
        if(cell) {
            NSArray *viewArray = [cell.contentView subviews];
            int num = 0;
            for(id v in viewArray) {
                if([v isKindOfClass:[UILabel class]]) {
                    UILabel *l = (UILabel*) v;
                    NSLog(@"%d", but.tag);
                    NSLog(@"%d", l.tag);
                    if(but.tag == l.tag) {
                        NSLog(@"ooo");
                        UIButton *realDelete = [[UIButton alloc] initWithFrame:CGRectMake(220, l.frame.origin.y, 100, 23)];
                        realDelete.tag = 7008;
                        [realDelete setContentMode:UIViewContentModeScaleAspectFit];
                        realDelete.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16];
                        [realDelete setTitle:@"Удалить" forState:UIControlStateNormal];
                        [realDelete setTitle:@"Удалить" forState:UIControlStateHighlighted];
                        [realDelete setTitleColor:[UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1] forState:UIControlStateNormal];
                        [realDelete setTitleColor:[UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:112.0/255.0 alpha:1] forState:UIControlStateHighlighted];
                        [cell.contentView addSubview:realDelete];
                        break;
                    }
                    num ++;
                }
            }
        }

    } else {
        [but setBackgroundImage: [UIImage imageNamed:@"Remove"] forState: UIControlStateNormal];
        [but setBackgroundImage: [UIImage imageNamed:@"Remove Tap"] forState: UIControlStateHighlighted];
        if(cell) {
            NSArray *viewArray = [cell.contentView subviews];
            for(id v in viewArray) {
                if([v isKindOfClass:[UIButton class]]) {
                    UIButton *l = (UIButton*) v;
                    if(l.tag == 7008) {
                        [l removeFromSuperview];
                        break;
                    }
                }
            }
        }
    }
}
//delegate
- (void) viewWillBeHidden:(UIImage*) img {
    [self.addPhotoViewController.view removeFromSuperview];
    [self.addPhotoViewController removeFromParentViewController];
    if(img && _photosArray.count > 0) {
        [_photosArray insertObject:img atIndex:_photosArray.count-1];
        [self.collectionView reloadData];
        [self.carousel reloadData];
    }
}
#pragma mark -
#pragma mark - HPSelectTownViewControllerDelegate
- (void) newTownSelected:(City*) city {
    NSMutableArray *places = [NSMutableArray arrayWithArray:@[@"Добавить место"]];
    [self.placeCityDataSource setObject:places forKey:city.cityName];
    [self.infoTableView reloadData];
}
#pragma mark -
#pragma mark - HPAddEducationViewControllerDelegate
- (void) newEducationSelected:(NSArray*) edu {
    [self.educationDataSource addObject:edu];
     [self.infoTableView reloadData];
}
- (void) newWorkPlaceSelected:(NSArray*) work {
    [self.carrierDataSource addObject:work];
    [self.infoTableView reloadData];
}
#pragma mark -
#pragma mark - background blure function
- (UIImage*) blureCurrentSelfView {
    NSLog(@"blur capture");
    //self.view.alpha = 0;
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the UIImage
    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 2] forKey: @"inputRadius"]; //change number to increase/decrease blur
    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
    
    //Cropimage
    CIVector *cropRect =[CIVector vectorWithX:self.view.frame.origin.x Y:self.view.frame.origin.y Z: self.view.frame.size.width W: self.view.frame.size.height];
    CIFilter *cropFilter = [CIFilter filterWithName:@"CICrop"];
    [cropFilter setValue:resultImage forKey:@"inputImage"];
    [cropFilter setValue:cropRect forKey:@"inputRectangle"];
    CIImage *croppedImage = [cropFilter valueForKey:@"outputImage"];
    return [[UIImage alloc] initWithCIImage:croppedImage];
}
-(IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //open photo
            if(self.carousel.hidden) {
                self.collectionView.hidden = NO;
            } else {
                self.collectionView.hidden = YES;
            }
            self.infoTableView.hidden = YES;
            break;}
        case 1:{
            //open info
            if(self.carousel.hidden) {
                self.collectionView.hidden = YES;
            } else {
                self.carousel.hidden = YES;
                self.collectionView.hidden = YES;
            }
            self.infoTableView.hidden = NO;
            
            break;}
    }
}
- (IBAction)backButtonTap:(id)sender {
    
    [self.greenButton removeFromSuperview];
    [self.tappedGreenButton removeFromSuperview];
    self.tappedGreenButton = nil;
    self.greenButton = nil;
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve //any animation
                    animations:^ {
                        self.carousel.hidden = YES;
                        self.collectionView.hidden = NO;
                        self.segmentControl.hidden = NO;
                        self.barTitle.hidden = YES;
                        self.downButton.hidden = NO;
                        self.backButton.hidden = YES;
                        self.deletButton.hidden = YES;
                    }
                    completion:^(BOOL finished){
                        
                    }];
    
    
    
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
#pragma mark - iCarousel data source -

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return _photosArray.count - 1;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    view = [[UIImageView alloc] initWithImage: [_photosArray objectAtIndex:index]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, 320.0, 200);
    
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.clipsToBounds = YES;
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    view.frame = rect;
    return view;
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    //self.tapState = !self.tapState;
    //if(self.tapState) {
    //    [self moveGreenButtonDown];
    //    [self movePhotoViewToLeft];
    //    [self hideTopBar];
    //} else {
    //    [self moveGreenButtonUp];
    //    [self movePhotoViewToRight];
    //    [self showTopBar];
    //}
    
}
- (CGFloat)carousel: (iCarousel *)carousel valueForOption: (iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionFadeMin:
            return -1;
        case iCarouselOptionFadeMax:
            return 1;
        case iCarouselOptionFadeRange:
            return 2.0;
        case iCarouselOptionCount:
            return 10;
        case iCarouselOptionSpacing:
            return value * 1.3;
        default:
            return value;
    }
}

- (CGFloat)carouselItemWidth:(iCarousel*)carousel
{
    return 320;
}
- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate {
    //self.bannerView.contentOffset
    //self.manScroll = YES;
}
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel {
    
    NSLog(@"%d", carousel.currentItemIndex);
    self.barTitle.text = [NSString stringWithFormat:@"%d из %d",self.carousel.currentItemIndex + 1, _photosArray.count - 1];
    //self.pageControl.currentPage = carousel.currentItemIndex;
    //self.bannerIndex = carousel.currentItemIndex;
    //self.manScroll = NO;
    
}

@end

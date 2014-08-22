//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileInfoEditTabViewController.h"
#import "HPUserProfileTableHeaderView.h"
#import "HPUserProfileFirstRowTableViewCell.h"
#import "HPUserInfoSecondRowTableViewCell.h"
#import "HEBubbleView.h"
#import "HPAddNewTownCellView.h"
#import "MinEntertainmentPrice.h"
#import "MaxEntertainmentPrice.h"

@interface HPUserProfileInfoEditTabViewController()
@property(nonatomic, strong) NSArray *userDataSource;
@property(nonatomic, strong) NSMutableDictionary *placeCityDataSource;
@property(nonatomic, strong) NSMutableArray *languages;
@property(nonatomic, strong) NSMutableArray *educationDataSource;
@property(nonatomic, strong) NSMutableArray *carrierDataSource;
@property (strong, nonatomic) User *user;
@property (nonatomic,weak) IBOutlet UITableView *editInfoTableView;
@end

#define CONSTRAINT_GREENBUTTON_FROM_BOTTOM 47.0
#define CONSTRAINT_TRASHBUTTON_FROM_LEFT 274.0
#define FIRST_ROW_HEIGHT_CONST 90.0
#define BIBBLE_VIEW_WIDTH_CONST 290.0

@implementation HPUserProfileInfoEditTabViewController
- (void)viewDidLoad {
    [super viewDidLoad];



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
    [self.editInfoTableView reloadData];
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
    HPAddNewTownCellView *customView = [HPAddNewTownCellView createView];
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
    HPAddNewTownCellView *customView = [HPAddNewTownCellView createView];

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
@end
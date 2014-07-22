//
//  HPUserInfoViewController.m
//  HighPoint
//
//  Created by Julia Pozdnyakova on 10.07.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserInfoViewController.h"
#import "HPTownTableViewCell.h"
#import "HPAddPhotoMenuViewController.h"
#import "Utils.h"
#import "MaxEntertainmentPrice.h"
#import "MinEntertainmentPrice.h"
#import "HPUserInfoFirstRowTableViewCell.h"
#import "HPUserInfoSecondRowTableViewCell.h"
#import "HPUserInfoTableHeaderView.h"
#define GREEN_BUTTON_BOTTOM 20
#define PHOTOS_NUMBER 4
#define SPACE_BETWEEN_PHOTOS 20


@interface HPUserInfoViewController ()
{
    HPAddPhotoMenuViewController *addPhotoViewController;
}

@end

@implementation HPUserInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createSegmentedController];
    [self createNavigationItem];
    [self createGreenButton];
    
    self.infoTableView.delegate = self;
    self.infoTableView.dataSource = self;
    
    self.carousel.dataSource = self;
    self.carousel.delegate = self;
    
    self.topBarView.translatesAutoresizingMaskIntoConstraints = YES;
    self.infoTableView.backgroundColor = [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0];
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
    
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self createPhotoCountView];
    //self.view.backgroundColor = [UIColor greenColor];
    //self.carousel.hidden = YES;
    //self.infoTableView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation bar switch

- (void) createSegmentedController
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"FuturaPT-Light" size:15], UITextAttributeFont,
                                [UIColor colorWithRed:30.0/255.0 green:29.0/255.0 blue:48.0/255.0 alpha:1.0], UITextAttributeTextColor, nil];
    
    NSDictionary *highlightedAttributes = [NSDictionary
                                           dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"FuturaPT-Light" size:15], UITextAttributeFont, [UIColor colorWithRed:80.0/255.0 green:226.0/255.0 blue:193.0/255.0 alpha:1.0], UITextAttributeTextColor, nil];
    
    [self.navSegmentedController setTitleTextAttributes:highlightedAttributes  forState:UIControlStateNormal];
    [self.navSegmentedController setTitleTextAttributes: attributes forState:UIControlStateSelected];
    
}

-(IBAction)segmentedControlValueDidChange:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:{
            //open photo
            self.infoTableView.hidden = YES;
            self.carousel.hidden = NO;
            self.photoCountView.hidden = NO;
            [self createGreenButton];
            break;}
        case 1:{
            //open info
            self.infoTableView.hidden = NO;
            self.carousel.hidden = YES;
            self.photoCountView.hidden = YES;
            NSLog(@"%@", self.user);
            [self removeGreenButton];
            break;}
    }
}

#pragma mark - create navigation item
- (void) createNavigationItem
{

    UIBarButtonItem* backButton = [self createBarButtonItemWithImage: [UIImage imageNamed:@"Down.png"]
                                                     highlighedImage: [UIImage imageNamed:@"Down Tap.png"]
                                                              action: @selector(backbuttonTaped:)];
    self.navigationItem.leftBarButtonItem = backButton;
}
- (UIBarButtonItem*) createBarButtonItemWithImage: (UIImage*) image
                                  highlighedImage: (UIImage*) highlighedImage
                                           action: (SEL) action
{
    UIButton* newButton = [UIButton buttonWithType: UIButtonTypeCustom];
    newButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [newButton setBackgroundImage: image forState: UIControlStateNormal];
    [newButton setBackgroundImage: highlighedImage forState: UIControlStateHighlighted];
    [newButton addTarget: self
                  action: action
        forControlEvents: UIControlEventTouchUpInside];
    
    UIBarButtonItem* newbuttonItem = [[UIBarButtonItem alloc] initWithCustomView: newButton];
    
    return newbuttonItem;
}
- (void) createPhotoCountView {
    self.photoCountView.backgroundColor = [UIColor clearColor];
    self.photoCountView.translatesAutoresizingMaskIntoConstraints = YES;
    UIView *temp = [Utils getFhotoCountViewForText:@"1/1"];
    CGRect fr = self.photoCountView.frame;
    fr.size.width = temp.frame.size.width;
    fr.size.height = temp.frame.size.height;
    self.photoCountView.frame = fr;
    [self.photoCountView addSubview:temp];
    
    //self.photoCountView.hidden = YES;
}
- (IBAction) backbuttonTaped: (id) sender
{
    if([self.delegate respondsToSelector:@selector(profileWillBeHidden)]) {
        [self.delegate profileWillBeHidden];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - green button
- (void) removeGreenButton {
    [self.sendMessage.view removeFromSuperview];
    [self.sendMessage removeFromParentViewController];
    self.sendMessage = nil;
}
- (void) createGreenButton
{
    if(!self.sendMessage) {
        self.sendMessage = [[HPGreenButtonVC alloc] initWithNibName: @"HPGreenButtonVC" bundle: nil];
        self.sendMessage.view.translatesAutoresizingMaskIntoConstraints = YES;
        self.sendMessage.delegate = self;
        [self.sendMessage initObjects:@"Написать ей"];
        CGRect rect = self.sendMessage.view.frame;
        CGRect bounds = [UIScreen mainScreen].bounds;
        rect.origin.x = (bounds.size.width - rect.size.width) / 2.0f;
        rect.origin.y = bounds.size.height - rect.size.height - GREEN_BUTTON_BOTTOM;
        self.sendMessage.view.frame = rect;
        [self addChildViewController: self.sendMessage];
        [self.view addSubview: self.sendMessage.view];
        [self.sendMessage didMoveToParentViewController:self];
        [self createGreenButtonsConstraint];
    }
}
- (void) createGreenButtonsConstraint
{
    [self.sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: self.sendMessage.view
                                                                 attribute: NSLayoutAttributeWidth
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: self.sendMessage.view.frame.size.width]];
    
    [self.sendMessage.view addConstraint:[NSLayoutConstraint constraintWithItem: self.sendMessage.view
                                                                 attribute: NSLayoutAttributeHeight
                                                                 relatedBy: NSLayoutRelationEqual
                                                                    toItem: nil
                                                                 attribute: NSLayoutAttributeNotAnAttribute
                                                                multiplier: 1.0
                                                                  constant: self.sendMessage.view.frame.size.height]];
}
#pragma mark - component animation

- (void) moveGreenButtonDown
{
    if(self.sendMessage) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.sendMessage.view.frame;
             rect.origin.y = rect.origin.y + 100;
             self.sendMessage.view.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}

//==============================================================================

- (void) moveGreenButtonUp
{
    if(self.sendMessage) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.sendMessage.view.frame;
             rect.origin.y = rect.origin.y - 100;
             self.sendMessage.view.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}
- (void) movePhotoViewToLeft
{
    if(self.photoCountView) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.photoCountView.frame;
             rect.origin.x = rect.origin.x - 150;
             self.photoCountView.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}

//==============================================================================

- (void) movePhotoViewToRight
{
    if(self.photoCountView) {
        [UIView animateWithDuration: 0.5
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations: ^
         {
             CGRect rect = self.photoCountView.frame;
             rect.origin.x = rect.origin.x + 150;
             self.photoCountView.frame = rect;
         }
                         completion: ^(BOOL finished)
         {
         }];
    }
}
- (void) hideTopBar {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}
- (void) showTopBar {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}
//==============================================================================


- (void) greenButtonPressed: (HPGreenButtonVC*) button
{
    NSLog(@"Green button pressed");
}


#pragma mark - add photo 


- (IBAction)addPhotoBtnTap:(id)sender {
    [self addPhotoMenuShow];
}


- (void) addPhotoMenuShow {
    if (!addPhotoViewController) {
        addPhotoViewController = [[HPAddPhotoMenuViewController alloc] initWithNibName: @"HPAddPhotoMenuViewController" bundle: nil];
    }
    [[[[[UIApplication sharedApplication]delegate] window] rootViewController].view addSubview:addPhotoViewController.view];
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



#pragma mark - iCarousel data source -

- (NSUInteger)numberOfItemsInCarousel: (iCarousel*) carousel
{
    return PHOTOS_NUMBER;
}

- (UIView*)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    view = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"img_sample"]];
    CGRect rect = CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    view.frame = rect;
    return view;
}
- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index{
    self.tapState = !self.tapState;
    if(self.tapState) {
        [self moveGreenButtonDown];
        [self movePhotoViewToLeft];
        [self hideTopBar];
    } else {
        [self moveGreenButtonUp];
        [self movePhotoViewToRight];
        [self showTopBar];
    }
    
    
}
- (UITapGestureRecognizer*) addTapGesture
{
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGest.cancelsTouchesInView = NO;
    tapGest.numberOfTouchesRequired = 1;
    [tapGest setDelegate:self];
    return tapGest;
}
- (void)tapGesture:(UIPanGestureRecognizer *)recognizer {
    [self moveGreenButtonDown];
}

#pragma mark - iCarousel delegate -

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


@end

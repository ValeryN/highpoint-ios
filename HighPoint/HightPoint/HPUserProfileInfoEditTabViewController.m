//
// Created by Eugene on 22.08.14.
// Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPUserProfileInfoEditTabViewController.h"
#import "HPUserProfileTableHeaderView.h"
#import "HEBubbleView.h"
#import "HPAddNewTownCellView.h"
#import "MinEntertainmentPrice.h"
#import "MaxEntertainmentPrice.h"
#import "NSManagedObjectContext+HighPoint.h"
#import "HPBubbleViewDelegate.h"
#import "HPHEBubbleView.h"
#import "DataStorage.h"

@interface HPUserProfileInfoEditTabViewController ()
@property(strong, nonatomic) User *user;

@property(nonatomic, weak) IBOutlet UITableView *editInfoTableView;

@property(nonatomic, retain) NSMutableDictionary *bubbleViewsCache;
@property(nonatomic, retain) NSFetchedResultsController *favoritePlaceFetchedResultController;
@property(nonatomic, retain) NSFetchedResultsController *educationFetchedResultController;
@property(nonatomic, retain) NSFetchedResultsController *careerFetchedResultController;
@end

#define BUBBLE_VIEW_WIDTH_CONST 290.0f

typedef NS_ENUM(NSUInteger, UserProfileCellType) {
    UserProfileCellTypeSpending,
    UserProfileCellTypeFavoritePlaces,
    UserProfileCellTypeLanguages,
    UserProfileCellTypeEducation,
    UserProfileCellTypeCareer,

    UserProfileCellCount
};

@implementation HPUserProfileInfoEditTabViewController

- (NSFetchedResultsController *)favoritePlaceFetchedResultController {
    if (!_favoritePlaceFetchedResultController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"cityId" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@", self.user]];
        _favoritePlaceFetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext threadContext] sectionNameKeyPath:@"cityId" cacheName:nil];
        if (![_favoritePlaceFetchedResultController performFetch:nil]) {
            NSAssert(false, @"Error occurred");
        }
        _favoritePlaceFetchedResultController.delegate = self;
    }
    return _favoritePlaceFetchedResultController;
}

- (NSFetchedResultsController *)educationFetchedResultController {
    if (!_educationFetchedResultController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Education"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fromYear" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@", self.user]];
        _educationFetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext threadContext] sectionNameKeyPath:nil cacheName:nil];
        if (![_educationFetchedResultController performFetch:nil]) {
            NSAssert(false, @"Error occurred");
        }
        _educationFetchedResultController.delegate = self;
    }
    return _educationFetchedResultController;
}

- (NSFetchedResultsController *)careerFetchedResultController {
    if (!_careerFetchedResultController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Career"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fromYear" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@", self.user]];
        _careerFetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext threadContext] sectionNameKeyPath:nil cacheName:nil];
        if (![_careerFetchedResultController performFetch:nil]) {
            NSAssert(false, @"Error occurred");
        }
        _careerFetchedResultController.delegate = self;
    }
    return _careerFetchedResultController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"HPUserProfileFirstRowTableViewCell" bundle:nil] forCellReuseIdentifier:@"UserProfileCellTypeSpending"];
    [self.tableView registerNib:[UINib nibWithNibName:@"HPUserInfoSecondRowTableViewCell" bundle:nil] forCellReuseIdentifier:@"HPUserInfoSecondRowTableViewCell"];
    self.user = [DataStorage sharedDataStorage].getCurrentUser;
    NSAssert(self.user, @"CurrentUser is nil");
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *sectionsArray = @[@"РАСХОДЫ", @"ЛЮБИМЫЕ МЕСТА", @"ЯЗЫКИ", @"ОБРАЗОВАНИЕ", @"КАРЬЕРА"];
    HPUserProfileTableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"HPUserProfileTableHeaderView" owner:self options:nil][0];
    headerView.backgroundColor = [UIColor colorWithRed:30.0f / 255.0f green:29.0f / 255.0f blue:48.0f / 255.0f alpha:1.0];
    headerView.headerTextLabel.backgroundColor = [UIColor clearColor];
    headerView.headerTextLabel.font = [UIFont fontWithName:@"FuturaPT-Light" size:15.0];
    headerView.headerTextLabel.textColor = [UIColor colorWithRed:230.0f / 255.0f green:236.0f / 255.0f blue:242.0f / 255.0f alpha:1.0];
    headerView.headerTextLabel.text = sectionsArray[(NSUInteger) section];

    UIView *separator = [[UIView alloc] initWithFrame:(CGRect) {13, 47.5f, 294, 0.5f}];
    separator.backgroundColor = [UIColor colorWithRed:230.f / 255.f green:236.f / 255.f blue:242.f / 255.f alpha:0.25];
    [headerView addSubview:separator];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self getCellIdentifierForIndexPath:indexPath]];
    cell.contentView.backgroundColor = [UIColor colorWithRed:30.0f / 255.0f green:29.0f / 255.0f blue:48.0f / 255.0f alpha:1.0];
    switch ([self getCellTypeForIndexPath:indexPath]) {
        case UserProfileCellTypeSpending:
            [self configureFirstCell:(HPUserProfileFirstRowTableViewCell *) cell];
            break;
        case UserProfileCellTypeFavoritePlaces:
            [self configureFavoritePlaceCell:cell withIndexPath:indexPath];
            break;
        case UserProfileCellTypeLanguages:
            [self configureThirdCell:cell];
            break;
        case UserProfileCellTypeEducation:
        case UserProfileCellTypeCareer:
            [self configureEducationOrCareerCell:cell forIndexPath:indexPath];
            break;
        case UserProfileCellCount:
            break;
    }

    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch ((UserProfileCellType) section) {
        case UserProfileCellTypeSpending:
            return 1;
        case UserProfileCellTypeFavoritePlaces:
            return [[self favoritePlaceFetchedResultController] sections].count + 1;
        case UserProfileCellTypeLanguages:
            return 1;
        case UserProfileCellTypeEducation:
            return ((id <NSFetchedResultsSectionInfo>) [[self educationFetchedResultController] sections][0]).numberOfObjects + 1;
        case UserProfileCellTypeCareer:
            return ((id <NSFetchedResultsSectionInfo>) [[self careerFetchedResultController] sections][0]).numberOfObjects + 1;
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return UserProfileCellCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self getCellTypeForIndexPath:indexPath]) {
        case UserProfileCellTypeSpending:
            return [self getFirstRowHeight];
        case UserProfileCellTypeFavoritePlaces:
            return [self getSecondRowHeightWithIndexPath:indexPath];
        case UserProfileCellTypeLanguages:
            return [self getThirdRowHeight];
        case UserProfileCellTypeEducation:
            return [self getHeightForEducationOrCareerCellWithIndexPath:indexPath];
        case UserProfileCellTypeCareer:
            return [self getHeightForEducationOrCareerCellWithIndexPath:indexPath];
        case UserProfileCellCount:
            break;
    }
    return 0;
}

#pragma mark -
#pragma mark - configure table cells

//entertainment price
- (UITableViewCell *)configureFirstCell:(HPUserProfileFirstRowTableViewCell *)cell {

    //UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 13, cell.contentView.frame.size.width - 26, cell.contentView.frame.size.height)];
    cell.cellTextLabel.backgroundColor = [UIColor clearColor];
    cell.cellTextLabel.numberOfLines = 0;
    cell.cellTextLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    cell.cellTextLabel.textColor = [UIColor colorWithRed:230.0f / 255.0f green:236.0f / 255.0f blue:242.0f / 255.0f alpha:1.0];
    cell.cellTextLabel.textAlignment = NSTextAlignmentLeft;
    cell.delegate = self;
    cell.user = self.user;
    [cell configureSlider:NO];

    NSMutableString *text;
    if ([self.user.gender intValue] == 2) {
        text = [NSMutableString stringWithString:@"Привыкла"];
    } else {
        text = [NSMutableString stringWithString:@"Привык"];
    }
    [text appendFormat:@" тратить на развлечения от $%d до $%d за вечер", [self.user.minentertainment.amount intValue], [self.user.maxentertainment.amount intValue]];//[Utils currencyConverter: self.user.minentertainment.currency]

    cell.cellTextLabel.text = text;
    return cell;
}

//user favorite places
- (UITableViewCell *)configureFavoritePlaceCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    for (UIView *v in  [cell.contentView subviews]) {
        [v removeFromSuperview];
    }

    if ([self isLastCellInSectionWithIndexPath:indexPath]) {
        //Last add row
        HPAddNewTownCellView *customView = [HPAddNewTownCellView createView];
        CGRect viewFrame = customView.frame;
        customView.label.text = @"Добавить город";
        viewFrame.origin.x = 0;
        viewFrame.origin.y = 0;
        customView.frame = viewFrame;
        customView.delegate = self;
        [cell.contentView addSubview:customView];
    }
    else {
        //City row
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0, 10, cell.contentView.frame.size.width - 26, 20.0)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
        textLabel.textColor = [UIColor colorWithRed:230.0f / 255.0f green:236.0f / 255.0f blue:242.0f / 255.0f alpha:1.0];
        textLabel.textAlignment = NSTextAlignmentLeft;

        RAC(textLabel, text) = [[[[RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
            NSString *sectionCityId = ((id <NSFetchedResultsSectionInfo>) [[self favoritePlaceFetchedResultController] sections][(NSUInteger) indexPath.row]).name;
            City *city = [[DataStorage sharedDataStorage] getCityById:@(sectionCityId.integerValue)];
            [subscriber sendNext:city.cityName ?: @"Неизвестный город"];
            [subscriber sendCompleted];
            return nil;
        }] takeUntil:cell.rac_prepareForReuseSignal] subscribeOn:[RACScheduler scheduler]] deliverOn:[RACScheduler mainThreadScheduler]];

        [cell.contentView addSubview:textLabel];

        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = CGRectMake(12, 10, 22.0, 22.0);
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"Remove"] forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"Remove Tap"] forState:UIControlStateHighlighted];
        [deleteButton addTarget:self
                         action:@selector(deletePlace:)
               forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];

        HEBubbleView *bubbleView = [self bubbleViewForFavoritePlaceAtIndexPath:indexPath];
        if (bubbleView.superview)
            [bubbleView removeFromSuperview];

        [cell.contentView addSubview:bubbleView];
    }

    return cell;
}

//user languages
- (UITableViewCell *)configureThirdCell:(UITableViewCell *)cell {
    for (UIView *v in [cell.contentView subviews]) {
        [v removeFromSuperview];
    }

    HEBubbleView *bubbleView = [self bubbleViewLanguages];
    if (bubbleView.superview)
        [bubbleView removeFromSuperview];

    [cell.contentView addSubview:bubbleView];
    return cell;
}

- (void)configureEducationOrCareerCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

    for (UIView *v in  [cell.contentView subviews]) {
        [v removeFromSuperview];
    }

    if ([self isLastCellInSectionWithIndexPath:indexPath]) {
        HPAddNewTownCellView *customView = [HPAddNewTownCellView createView];
        customView.frame = CGRectMake(0, 0, 320, 46);
        CGRect viewFrame = customView.frame;
        customView.label.text = ([self getCellTypeForIndexPath:indexPath] == UserProfileCellTypeEducation) ? @"Добавить учебное заведение" : @"Добавить достижение";
        viewFrame.origin.x = 0;
        viewFrame.origin.y = 0;
        customView.frame = viewFrame;
        customView.delegate = self;
        [cell.contentView addSubview:customView];
    }
    else {
        NSString *name;
        NSString *position;
        NSString *years;
        NSManagedObject *object;
        if ([self getCellTypeForIndexPath:indexPath] == UserProfileCellTypeEducation) {
            Education *education = [[self educationFetchedResultController] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]];
            name = education.school.name;
            position = education.speciality.name;
            years = [NSString stringWithFormat:@"(%@ - %@)", education.fromYear, education.toYear];
            object = education;
        }
        else {
            Career *career = [[self careerFetchedResultController] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]];
            name = career.company.name;
            position = career.careerpost.name;
            years = [NSString stringWithFormat:@"(%@ - %@)", career.fromYear, career.toYear];
            object = career;
        }

        UIButton *deleteButton = [self leftPreDeleteButton];
        [cell.contentView addSubview:deleteButton];

        UILabel *textLabel1 = [[UILabel alloc] initWithFrame:(CGRect) {0, 5, BUBBLE_VIEW_WIDTH_CONST - 40, 9999}];
        textLabel1.backgroundColor = [UIColor clearColor];
        textLabel1.numberOfLines = 0;
        textLabel1.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
        textLabel1.textColor = [UIColor colorWithRed:230.0f / 255.0f green:236.0f / 255.0f blue:242.0f / 255.0f alpha:1.0];
        textLabel1.textAlignment = NSTextAlignmentLeft;
        textLabel1.text = name;
        [textLabel1 sizeToFit];


        UILabel *textLabel2 = [[UILabel alloc] initWithFrame:(CGRect) {0, textLabel1.frame.size.height, BUBBLE_VIEW_WIDTH_CONST - 40.0f, 9999}];
        textLabel2.backgroundColor = [UIColor clearColor];
        textLabel2.numberOfLines = 0;
        textLabel2.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
        textLabel2.textColor = [UIColor colorWithRed:230.0f / 255.0f green:236.0f / 255.0f blue:242.0f / 255.0f alpha:1.0];
        textLabel2.textAlignment = NSTextAlignmentLeft;
        textLabel2.text = position;
        [textLabel2 sizeToFit];
        [cell.contentView addSubview:textLabel2];

        UILabel *textLabel3 = [[UILabel alloc] initWithFrame:(CGRect) {0, textLabel1.frame.size.height + textLabel2.frame.size.height, BUBBLE_VIEW_WIDTH_CONST - 40.0f, 9999}];
        textLabel3.backgroundColor = [UIColor clearColor];
        textLabel3.numberOfLines = 0;
        textLabel3.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
        textLabel3.textColor = [UIColor colorWithRed:230.0f / 255.0f green:236.0f / 255.0f blue:242.0f / 255.0f alpha:1.0];
        textLabel3.textAlignment = NSTextAlignmentLeft;
        textLabel3.text = years;
        [textLabel3 sizeToFit];
        [cell.contentView addSubview:textLabel3];

        //Need for correct work with animation
        UIView *animationLayer = [[UIView alloc] initWithFrame:(CGRect) {46.0, 0, BUBBLE_VIEW_WIDTH_CONST - 40.0f, textLabel1.frame.size.height + textLabel2.frame.size.height + textLabel3.frame.size.height}];
        animationLayer.clipsToBounds = YES;
        [animationLayer addSubview:textLabel1];
        [animationLayer addSubview:textLabel2];
        [animationLayer addSubview:textLabel3];
        [cell.contentView addSubview:animationLayer];
        //Resize textLabel to show performDeleteButton
        CGRect initialFrame = animationLayer.frame;
        [[RACObserve(deleteButton, selected) takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *selected) {
            [UIView animateWithDuration:0.3 animations:^{
                if (selected.boolValue) {
                    animationLayer.frame = (CGRect) {initialFrame.origin, BUBBLE_VIEW_WIDTH_CONST - 40 - 60, initialFrame.size.height};
                }
                else {
                    animationLayer.frame = initialFrame;
                }
            }];
        }];

        UIButton *realDelete = [self rightPerformDeleteButton];
        realDelete.hidden = YES;
        RAC(realDelete, hidden) = [[RACObserve(deleteButton, selected) not] flattenMap:^RACStream *(NSNumber *value) {
            if (!value.boolValue) {
                return [[RACSignal return:value] delay:0.3];
            }
            else return [RACSignal return:value];
        }];
        [[[realDelete rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(id x) {
            if ([self getCellTypeForIndexPath:indexPath] == UserProfileCellTypeEducation) {
                [[DataStorage sharedDataStorage] deleteAndSaveEducationEntityFromUser:@[((Education *) object).id_]];
            }
            else {
                [[DataStorage sharedDataStorage] deleteAndSaveCareerEntityFromUser:@[((Career *) object).id_]];
            }
        }];
        [cell.contentView addSubview:realDelete];
    }

}

- (UIButton *)rightPerformDeleteButton {
    UIButton *realDelete = [[UIButton alloc] initWithFrame:CGRectMake(240, -5, 70, 40)];
    [realDelete setContentMode:UIViewContentModeScaleAspectFit];
    realDelete.titleLabel.font = [UIFont fontWithName:@"FuturaPT-Book" size:16];
    [realDelete setTitle:@"Удалить" forState:UIControlStateNormal];
    [realDelete setTitle:@"Удалить" forState:UIControlStateHighlighted];
    [realDelete setTitleColor:[UIColor colorWithRed:255.0f / 255.0f green:102.0f / 255.0f blue:112.0f / 255.0f alpha:1] forState:UIControlStateNormal];
    [realDelete setTitleColor:[UIColor colorWithRed:255.0f / 255.0f green:102.0f / 255.0f blue:112.0f / 255.0f alpha:1] forState:UIControlStateHighlighted];
    return realDelete;
}

- (UIButton *)leftPreDeleteButton {
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake(0, 0, 44.0, 44.0);
    [deleteButton setImage:[UIImage imageNamed:@"Remove"] forState:UIControlStateNormal];
    [deleteButton setImage:[UIImage imageNamed:@"Remove Tap"] forState:UIControlStateHighlighted];
    [[deleteButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        button.selected = !button.selected;
        if (button.selected) {
            [button setImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"Cancel Tap"] forState:UIControlStateHighlighted];
        }
        else {
            [button setImage:[UIImage imageNamed:@"Remove"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"Remove Tap"] forState:UIControlStateHighlighted];
        }
    }];
    return deleteButton;
}


#pragma mark -
#pragma mark - calculate table row height

- (CGFloat)getFirstRowHeight {
    return 90;
}

- (CGFloat)getSecondRowHeightWithIndexPath:(NSIndexPath *)indexPath {
    if ([self isLastCellInSectionWithIndexPath:indexPath]) {
        return 40;
    }
    else {
        CGFloat totalHeight = 30.0;
        HEBubbleView *bubbleView = [self bubbleViewForFavoritePlaceAtIndexPath:indexPath];
        [bubbleView reloadData];
        CGRect rect = bubbleView.frame;
        rect.size.height = bubbleView.contentSize.height;
        bubbleView.frame = rect;
        totalHeight = bubbleView.frame.size.height + totalHeight;
        //return 99.0;
        return totalHeight;
    }

}

- (CGFloat)getThirdRowHeight {
    CGFloat totalHeight = 20.0;
    HEBubbleView *bubbleView = [self bubbleViewLanguages];
    [bubbleView reloadData];
    CGRect rect = bubbleView.frame;
    rect.size.height = bubbleView.contentSize.height;
    bubbleView.frame = rect;
    totalHeight = bubbleView.frame.size.height + totalHeight;
    return totalHeight;
}


- (CGFloat)getHeightForEducationOrCareerCellWithIndexPath:(NSIndexPath *)indexPath {
    if ([self isLastCellInSectionWithIndexPath:indexPath])
        return 48;

    NSString *name;
    NSString *position;
    NSString *years;
    if ([self getCellTypeForIndexPath:indexPath] == UserProfileCellTypeEducation) {
        Education *education = [[self educationFetchedResultController] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]];
        name = education.school.name;
        position = education.speciality.name;
        years = [NSString stringWithFormat:@"(%@ - %@)", education.fromYear, education.toYear];
    }
    else {
        Career *career = [[self careerFetchedResultController] objectAtIndexPath:[NSIndexPath indexPathForItem:indexPath.row inSection:0]];
        name = career.company.name;
        position = career.careerpost.name;
        years = [NSString stringWithFormat:@"(%@ - %@)", career.fromYear, career.toYear];
    }
    UILabel *textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (BUBBLE_VIEW_WIDTH_CONST - 40.0f), 9999.0)];
    textLabel1.numberOfLines = 0;
    textLabel1.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    textLabel1.textAlignment = NSTextAlignmentLeft;
    textLabel1.text = name;
    [textLabel1 sizeToFit];
    UILabel *textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (BUBBLE_VIEW_WIDTH_CONST - 40.0f), 9999.0)];
    textLabel2.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    textLabel2.numberOfLines = 0;
    textLabel2.textAlignment = NSTextAlignmentLeft;
    textLabel2.text = position;
    [textLabel2 sizeToFit];
    UILabel *textLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (BUBBLE_VIEW_WIDTH_CONST - 40.0f), 9999.0)];
    textLabel3.font = [UIFont fontWithName:@"FuturaPT-Book" size:16.0];
    textLabel3.textAlignment = NSTextAlignmentLeft;
    textLabel3.text = years;
    textLabel3.numberOfLines = 0;
    [textLabel3 sizeToFit];
    return textLabel1.frame.size.height + textLabel2.frame.size.height + textLabel3.frame.size.height + 5;
}

- (CGFloat)calculateSectionHeight:(NSArray *)content {
    CGFloat totalRowWidth = 0.0;
    CGFloat totalHeight = 0.0;
    for (NSString *val in content) {
        totalRowWidth = (CGFloat) (totalRowWidth + ceil([val sizeWithAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:16.0]}].width + 14));
        if (totalRowWidth > BUBBLE_VIEW_WIDTH_CONST) {
            totalHeight = totalHeight + 80;
            totalRowWidth = 0.0;
        }
    }
    return totalHeight;
}

- (CGSize)GetSizeOfLabelForGivenText:(UILabel *)label Font:(UIFont *)fontForLabel Size:(CGSize)constraintSize {
    label.numberOfLines = 0;
    CGRect labelRect = [label.text boundingRectWithSize:constraintSize options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName : fontForLabel} context:nil];
    return (labelRect.size);
}

- (void)sliderValueChange:(NMRangeSlider *)sender {

}


- (UserProfileCellType)getCellTypeForIndexPath:(NSIndexPath *)indexPath {
    return (UserProfileCellType) (indexPath.section);
}

- (NSString *)getCellIdentifierForIndexPath:(NSIndexPath *)path {
    switch ([self getCellTypeForIndexPath:path]) {
        case UserProfileCellTypeSpending:
            return @"UserProfileCellTypeSpending";
        default:
            return @"HPUserInfoSecondRowTableViewCell";
    }
};

- (HPHEBubbleView *)bubbleViewForFavoritePlaceAtIndexPath:(NSIndexPath *)indexPath {
    NSString *keyPath = [NSString stringWithFormat:@"city_%d", indexPath.row];
    if (!self.bubbleViewsCache)
        self.bubbleViewsCache = [NSMutableDictionary new];

    if (!self.bubbleViewsCache[keyPath]) {
        HPHEBubbleView *bubbleView = [[HPHEBubbleView alloc] initWithFrame:CGRectMake(41.0, 30.0, BUBBLE_VIEW_WIDTH_CONST, 50.0)];
        bubbleView.layer.cornerRadius = 1;
        bubbleView.backgroundColor = [UIColor clearColor];
        bubbleView.itemHeight = 20.0;
        bubbleView.itemPadding = 5.0;

        HPBubbleViewDelegate *delegate = [[HPBubbleViewDelegate alloc] initWithBubbleView:bubbleView];
        Place *place = [[self favoritePlaceFetchedResultController] objectAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row]];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Place"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@ && cityId = %@", self.user, place.cityId]];
        NSFetchedResultsController *placeByCityController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext threadContext] sectionNameKeyPath:nil cacheName:nil];
        if (![placeByCityController performFetch:nil]) {
            NSAssert(false, @"Error occurred");
        }

        delegate.dataSource = placeByCityController;
        placeByCityController.delegate = self;
        delegate.addTextString = @"Добавить место";
        delegate.getTextInfo = ^NSString *(Place *object) {
            return object.name;
        };
        @weakify(self);
        delegate.insertTextBlock = ^(NSString *string) {
            @strongify(self);
            [[DataStorage sharedDataStorage] addAndSavePlaceEntity:@{@"id" : @(999), @"cityId" : place.cityId, @"name" : string} forUser:self.user];
        };

        delegate.deleteBubbleBlock = ^(Place *object) {
            if (object.id_) {
                [[DataStorage sharedDataStorage] deleteAndSavePlaceEntityFromUser:@[object.id_]];
            }
        };

        bubbleView.retainDelegate = delegate;
        self.bubbleViewsCache[keyPath] = bubbleView;
    }

    [self.bubbleViewsCache[keyPath] reloadData];
    return self.bubbleViewsCache[keyPath];
}

- (HPHEBubbleView *)bubbleViewLanguages {
    NSString *keyPath = [NSString stringWithFormat:@"languages"];
    if (!self.bubbleViewsCache)
        self.bubbleViewsCache = [NSMutableDictionary new];

    if (!self.bubbleViewsCache[keyPath]) {
        HPHEBubbleView *bubbleView = [[HPHEBubbleView alloc] initWithFrame:CGRectMake(41.0, 0, BUBBLE_VIEW_WIDTH_CONST, 50.0)];
        bubbleView.layer.cornerRadius = 1;
        bubbleView.backgroundColor = [UIColor clearColor];
        bubbleView.itemHeight = 20.0;
        bubbleView.itemPadding = 5.0;

        HPBubbleViewDelegate *delegate = [[HPBubbleViewDelegate alloc] initWithBubbleView:bubbleView];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Language"];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"user == %@", self.user]];
        NSFetchedResultsController *languageController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[NSManagedObjectContext threadContext] sectionNameKeyPath:nil cacheName:nil];
        if (![languageController performFetch:nil]) {
            NSAssert(false, @"Error occurred");
        }

        delegate.dataSource = languageController;
        languageController.delegate = self;
        delegate.addTextString = @"Добавить язык";
        delegate.getTextInfo = ^NSString *(Language *object) {
            return object.name;
        };
        delegate.insertTextBlock = ^(NSString *string) {
            [[DataStorage sharedDataStorage] addAndSaveLanguageEntityForUser:@{@"_id" : @(0001), @"name" : string}];
        };
        delegate.deleteBubbleBlock = ^(Language *object) {
            if (object.id_) {
                [[DataStorage sharedDataStorage] deleteAndSaveLanguageEntityFromUser:@[object.id_]];
            }
        };

        bubbleView.retainDelegate = delegate;
        self.bubbleViewsCache[keyPath] = bubbleView;
    }

    [self.bubbleViewsCache[keyPath] reloadData];
    return self.bubbleViewsCache[keyPath];
}

- (BOOL)isLastCellInSectionWithIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:self.tableView numberOfRowsInSection:indexPath.section] - indexPath.row == 1;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}
@end
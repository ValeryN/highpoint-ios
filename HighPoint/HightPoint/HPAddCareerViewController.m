//
//  HPAddEducationViewController.m
//  HighPoint
//
//  Created by Andrey Anisimov on 04.08.14.
//  Copyright (c) 2014 SurfStudio. All rights reserved.
//

#import "HPAddCareerViewController.h"
#import "UITextField+HighPoint.h"

@interface HPAddCareerViewController ()
@property (nonatomic, strong) IBOutlet UITextField *firstRow;
@property (nonatomic, strong) IBOutlet UITextField *secondRow;
@end

@implementation HPAddCareerViewController

- (RACSubject*)returnSignal {
    if(!_returnSignal)
    {
        _returnSignal = [RACSubject subject];
    }
    return _returnSignal;
}

- (void)viewDidLoad
{
    @weakify(self);
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [self barItemBackButton];
    self.navigationItem.rightBarButtonItem  = [self barItemPublish];
    self.firstRow.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.firstRow.placeholder attributes:@{NSForegroundColorAttributeName: [self.firstRow.textColor colorWithAlphaComponent:0.4]}];
    [[self.firstRow rac_textReturnSignal] subscribeNext:^(UITextField * textField) {
        @strongify(self)
        [textField resignFirstResponder];
        [self.secondRow becomeFirstResponder];
    }];
    self.secondRow.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.secondRow.placeholder attributes:@{NSForegroundColorAttributeName: [self.secondRow.textColor colorWithAlphaComponent:0.4]}];
    [[self.secondRow rac_textReturnSignal] subscribeNext:^(UITextField * textField) {
        @strongify(self)
        [textField resignFirstResponder];
        [self createCareer];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (UIBarButtonItem *)barItemPublish {
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] init];
    rightBarItem.title = @"Готово";
    @weakify(self);
    [rightBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Book" size:18]} forState:UIControlStateNormal];
    [rightBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:80.f / 255.f green:227.f / 255.f blue:194.f / 255.f alpha:0.4]} forState:UIControlStateDisabled];
    rightBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[self canCreateEducation] signalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    return rightBarItem;
}

- (UIBarButtonItem *)barItemBackButton {
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] init];
    leftBarItem.title = @"Отменить";
    @weakify(self);
    [leftBarItem setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"FuturaPT-Light" size:18]} forState:UIControlStateNormal];
    leftBarItem.rac_command = [[RACCommand alloc] initWithEnabled:[RACSignal return:@YES] signalBlock:^RACSignal *(id input) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
    return leftBarItem;
}

- (void)createCareer
{
    [self.returnSignal sendNext:[RACTuple tupleWithObjects:self.firstRow.text,self.secondRow.text,nil]];
}

- (RACSignal *) canCreateEducation{
    return [[RACSignal combineLatest:@[self.firstRow.rac_textSignal,self.secondRow.rac_textSignal]] map:^id(RACTuple * value) {
        RACTupleUnpack(NSString* text1, NSString* text2) = value;
        return @(![text1 isEqualToString:@""]&&![text2 isEqualToString:@""]);
    }];
}

@end

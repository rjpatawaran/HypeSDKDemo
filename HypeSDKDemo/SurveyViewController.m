//
//  SurveyViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 10/12/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "SurveyViewController.h"

#import "XLForm.h"
#import "XLFormDescriptor.h"
#import "XLFormSectionDescriptor.h"
#import "XLFormRowDescriptor.h"

#import "UIBAlertView.h"
#import "MBProgressHUD.h"

@interface SurveyViewController ()

@end

@implementation SurveyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.title = _survey.name;
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:_survey.name];
    form.assignFirstResponderOnShow = YES;
    
    int qidx = 0;
    for (HypeSurveyQuestion *survey_question in _survey.questions) {
        section = [XLFormSectionDescriptor formSection];
        section.title = survey_question.question;
        row = [XLFormRowDescriptor formRowDescriptorWithTag:[NSString stringWithFormat:@"%d", qidx] rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:@""];
        
        
        NSMutableArray *questionOptions = [NSMutableArray new];
        int oidx = 0;
        for (NSString *option in survey_question.options) {
            XLFormOptionsObject *formObject = [XLFormOptionsObject formOptionsObjectWithValue:[NSNumber numberWithInt:oidx] displayText:option];
            [questionOptions addObject:formObject];
            oidx++;
        }
        row.selectorOptions = questionOptions;
        
        
        //row.selectorOptions = survey_question.options;
        row.required = YES;
        [section addFormRow:row];
        [form addFormSection:section];
        qidx++;
    }

    section = [XLFormSectionDescriptor formSection];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeButton title:@"Submit"];
    row.action.formSelector = @selector(submit:);
    [section addFormRow:row];
    [form addFormSection:section];
    
    self.form = form;
    [self.tableView reloadData];
}


-(void)animateCell:(UITableViewCell *)cell
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values =  @[ @0, @20, @-20, @10, @0];
    animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
    animation.duration = 0.3;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.additive = YES;
    
    [cell.layer addAnimation:animation forKey:@"shake"];
}


-(void)submit:(XLFormRowDescriptor *)sender
{
    NSArray *errors = [self formValidationErrors];
    if ([errors count] > 0) {
        [errors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];
            [self animateCell:cell];
        }];
    } else {
        NSArray *answerKeys = [[self.httpParameters allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            int int1 = [obj1 intValue];
            int int2 = [obj2 intValue];
            if (int1 == int2) return NSOrderedSame;
            return (int1 < int2 ? NSOrderedAscending : NSOrderedDescending);
        }];

        NSMutableArray *answers = [NSMutableArray new];
        for (NSString *key in answerKeys) {
            [answers addObject:[self.httpParameters objectForKey:key]];
        }
        [_survey submitAnswers:[answers copy]];
        UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Survey" message:@"Thanks for joining." cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
        [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end

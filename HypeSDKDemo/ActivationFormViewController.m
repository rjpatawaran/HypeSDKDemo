//
//  RegistrationFormViewController.m
//  Byahero
//
//  Created by RJ Patawaran on 7/2/15.
//  Copyright (c) 2015 Entropy Soluction. All rights reserved.
//

#import "ActivationFormViewController.h"

#import "XLForm.h"
#import "XLFormDescriptor.h"
#import "XLFormSectionDescriptor.h"
#import "XLFormRowDescriptor.h"

#import "AppDelegate.h"
#import "UIBAlertView.h"
#import "MBProgressHUD.h"
#import "NSString+Validation.h"
#import "NSDictionary+MutableDeepCopy.h"
#import "HypeSDK.h"


@interface ActivationFormViewController () <XLFormDescriptorCell>
@property (strong, nonatomic) NSDictionary *userData;
@property (strong, nonatomic) NSString *countryCode;
@end

@implementation ActivationFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_isEditMode) {
        self.title = @"User Profile";
        
        [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading" animated:YES];
        [[HypeSDK sharedInstance] getProfileWithCompletion:^(NSDictionary *userData) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _userData = userData;
            NSLog(@"UserData: %@", userData);
            
            [self loadRegionsAndInitializeForm];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Error" message:@"Unable to connect to server." cancelButtonTitle:nil otherButtonTitles:@"Ok",nil];
            [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }];
        
    } else {
        [self loadRegionsAndInitializeForm];
    }
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:_isEditMode ? @"Update" : @"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(validateForm:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
}
     
     
- (void)loadRegionsAndInitializeForm
{
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Loading" animated:YES];
    [[HypeSDK sharedInstance] getRegionsWithCompletion:^(NSArray *regions) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self initializeForm:regions];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Error" message:@"Unable to connect to server." cancelButtonTitle:nil otherButtonTitles:@"Try again",nil];
        [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
            [self loadRegionsAndInitializeForm];
        }];
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

#pragma mark - actions

-(void)validateForm:(UIBarButtonItem *)buttonItem
{
    NSArray *errors = [self formValidationErrors];
    NSLog(@"validate %@", errors);

    if ([errors count] > 0) {
        [errors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XLFormValidationStatus * validationStatus = [[obj userInfo] objectForKey:XLValidationStatusErrorKey];
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:[self.form indexPathOfFormRow:validationStatus.rowDescriptor]];

            if ([validationStatus.rowDescriptor.tag isEqualToString:@"activation_code"]) {
                cell.backgroundColor = [UIColor orangeColor];
                [UIView animateWithDuration:0.3 animations:^{
                    cell.backgroundColor = [UIColor whiteColor];
                }];
            } else {
                [self animateCell:cell];
            }
        }];
    } else {
        NSLog(@"vals ok %@", [self httpParameters]);
        [self activate];
    }
}


-(void)activate
{
    NSMutableDictionary *userData = [[self httpParameters] mutableDeepCopy];
    NSString *mobile_number = [[userData objectForKey:@"msisdn"] lowercaseString];
    
    [userData setObject:[[[userData objectForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] capitalizedString] forKey:@"name"];
    [userData setObject:[[userData objectForKey:@"email"] lowercaseString] forKey:@"email"];
    [userData setObject:[[userData objectForKey:@"gender"] lowercaseString] forKey:@"gender"];
    NSDate *birthdate = (NSDate*)[userData objectForKey:@"birthdate"];
    [userData setObject:[birthdate description] forKey:@"birthdate"];
    [userData removeObjectForKey:@"activation_code"];
    
    NSString *email_address = [[userData objectForKey:@"email"] lowercaseString];
    
    [MBProgressHUD showHUDAddedTo:self.view withLabel:_isEditMode ? @"Updating" : @"Activating" animated:YES];
    
    //NSLog(@"[NSTimeZone localTimeZone] %@", [[NSTimeZone localTimeZone] abbreviation]);
    //NSLog(@"sendings %@", userData);
    
    if (_isEditMode) {
        [[HypeSDK sharedInstance] updateProfile:userData completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"error %@", error);
        }];
        
    } else {
        [[HypeSDK sharedInstance] activateWithMobileNumber:mobile_number userData:userData completion:^{
//        [[HypeSDK sharedInstance] activateWithEmailAddress:email_address userData:userData completion:^{
            NSLog(@"ok");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [(AppDelegate *)[[UIApplication sharedApplication] delegate] showViewControllerWithIdentifier:@"Main"];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //NSLog(@"error %@", error);
        }];
        
    }
}

#pragma mark - Helper

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

-(void)initializeForm:(NSArray*)regions
{
    NSLog(@"initializeForm");
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"Activation"];
    form.assignFirstResponderOnShow = YES;
    
    // Name section
    section = [XLFormSectionDescriptor formSection];
    section.title = @"Personal Information";
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeName title:@"Name"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    if (_isEditMode) {
        row.value = [_userData valueForKey:@"name"];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"birthdate" rowType:XLFormRowDescriptorTypeDate title:@"Birthdate"];
    row.required = YES;
    if (_isEditMode) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        row.value = [dateFormatter dateFromString:[_userData objectForKey:@"birthdate"]];
    }
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"gender" rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"Gender"];
    row.selectorOptions = @[@"Male", @"Female"];
    row.required = YES;
    if (_isEditMode) {
        NSString *gender = [_userData valueForKey:@"gender"];
        row.value = [NSString stringWithFormat:@"%@%@",[[gender substringToIndex:1] uppercaseString],[gender substringFromIndex:1] ]; ;
    }
    [section addFormRow:row];

    
    NSMutableArray *locationOptions = [NSMutableArray new];
    NSDictionary *locationsDict = [NSMutableDictionary new];
    for (NSDictionary *region in regions) {
        XLFormOptionsObject *formObject = [XLFormOptionsObject formOptionsObjectWithValue:[region objectForKey:@"_id"] displayText:[region objectForKey:@"name"]];
        [locationOptions addObject:formObject];
        [locationsDict setValue:formObject forKey:[region objectForKey:@"_id"]];
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"location" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Location"];
    row.selectorOptions = locationOptions;
    row.required = YES;
    if (_isEditMode) {
        row.value = [locationsDict objectForKey:[_userData valueForKey:@"location"]];
    }
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"email" rowType:XLFormRowDescriptorTypeEmail title:@"Email"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    if (_isEditMode) {
        row.value = [_userData valueForKey:@"email"];
    }
    [section addFormRow:row];

    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"msisdn" rowType:XLFormRowDescriptorTypePhone title:@"Mobile Number"];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
    row.required = YES;
    if (_isEditMode) {
        row.value = [_userData valueForKey:@"msisdn"];
        row.disabled = @YES;
    }
    [section addFormRow:row];
    [form addFormSection:section];

    self.form = form;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

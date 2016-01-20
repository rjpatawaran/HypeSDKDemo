//
//  MenuTableViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/22/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "MenuTableViewController.h"
#import "AppDelegate.h"
#import "PromoTableViewController.h"
#import "SubscriptionTableViewController.h"
#import "DCQRCodeScanController.h"
#import "PrizesTableViewController.h"
#import "MBProgressHUD.h"
#import "ContentViewController.h"
#import "ActivationFormViewController.h"
#import "SurveyViewController.h"
#import "UIBAlertView.h"

@interface MenuTableViewController () <DCQRCodeScanControllerDelegate>
@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSArray *inRangeLocations;
@property (strong, nonatomic) NSArray *inRangePromos;
@property (strong, nonatomic) NSArray *subscriptions;
@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _inRangePromos = @[];
    _menuItems = @[@"Scan QR Code", @"User Profile", @"Unlink Account"];
    
    [[HypeSDK sharedInstance] setDelegate:self];

    _subscriptions = [[HypeSDK sharedInstance] subscriptions];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPromo:) name:@"HypeDemoOpenPromo" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"In-Range Promos";
    } else if (section == 1) {
        return @"Promo Inbox";
    } else if (section == 2) {
        return @"Actions";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        //return [_inRangeLocations count];
        return [_inRangePromos count];
    } else if (section == 1) {
        return [_subscriptions count];
    } else if (section == 2) {
        return [_menuItems count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell...
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        HypePromo *promo = [_inRangePromos objectAtIndex:indexPath.row];
        cell.textLabel.text = promo.name;
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellDetail" forIndexPath:indexPath];
        HypeSubscription *subscription = [_subscriptions objectAtIndex:indexPath.row];
        NSLog(@"subscription: %@", subscription);
        if (subscription.isRedeemed) {
            //NSLog(@"REDEEMED????");
            cell.textLabel.textColor = [UIColor colorWithRed:0.25 green:0.54 blue:0.75 alpha:1.0]; // blue
        } else if (!subscription.promo.inDateRange) {
            cell.textLabel.textColor = [UIColor colorWithRed:0.80 green:0.18 blue:0.45 alpha:1.0]; // red
            NSLog(@"subscription: %@", subscription);
            NSLog(@"promo: %@ %@ to %@", subscription.promo, subscription.promo.start, subscription.promo.end);
        }
        cell.textLabel.text = subscription.promo.name;
        cell.detailTextLabel.text = subscription.id;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        return cell;
        
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.text = [_menuItems objectAtIndex:indexPath.row];
        return cell;

    }
    
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self performSegueWithIdentifier:@"PromoSegue" sender:[_inRangePromos objectAtIndex:indexPath.row]];
        
    } else if (indexPath.section == 1) {
        HypeSubscription *subscription = [_subscriptions objectAtIndex:indexPath.row];
        if (subscription.promo != nil) {
            [self performSegueWithIdentifier:@"SubscriptionSegue" sender:subscription];
        }
    
    } else if (indexPath.section == 2) {
        // SCAN QR CODE
        if (indexPath.row == 0) {
            DCQRCodeScanController *qrcodeScanController = [[DCQRCodeScanController alloc] init];
            
            qrcodeScanController.delegate = self;
            qrcodeScanController.availableCodeTypes = @[AVMetadataObjectTypeQRCode];
            [self presentViewController:qrcodeScanController animated:YES completion:nil];
        
        // USER PROFILE
        } else if (indexPath.row == 1) {
            NSLog(@"USER PROFILE!");
            [self performSegueWithIdentifier:@"UserProfileSegue" sender:nil];
            
        // UNLINK ACCOUNT
        } else if (indexPath.row == 2) {
            [[HypeSDK sharedInstance] unlinkAccount];
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] showViewControllerWithIdentifier:@"Registration"];
        }
    }
}


- (void)dcQRCodeScanController:(DCQRCodeScanController *)dcQRCodeScanController didFinishScanningCodeWithInfo:(NSString *)info
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Verifying" animated:YES];

    [[HypeSDK sharedInstance] getPromoFromQRCode:info completion:^(NSArray *prizes, HypePromo *promo, HypeBranch *branch) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self performSegueWithIdentifier:@"PrizeSegue" sender:@{@"prizes": prizes, @"promo": promo, @"branch_id":branch.id}];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:(NSString*)error.userInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];

}

- (void)dcQRCodeScanControllerDidCancel:(DCQRCodeScanController *)dcQRCodeScanController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation


- (void)HypeSDK:(HypeSDK *)hypesdk inRangePromo:(HypePromo *)promo
{
    // Rules: Are we still going to show subscribed/redeemed promos?
    if ([[[self.navigationController viewControllers] lastObject] isKindOfClass:[self class]]) {
        //NSUInteger randomIndex = arc4random() % [promos count];
        //NSLog(@"RANDOM %lu Promos: %@", (unsigned long)randomIndex, promos);
        //[self performSegueWithIdentifier:@"ContentSegue" sender:[promos objectAtIndex:randomIndex]];
        if (promo.content != nil) {
            [self performSegueWithIdentifier:@"ContentSegue" sender:promo];
        }
    }
}

- (void)HypeSDK:(HypeSDK *)hypesdk inRangePromosUpdate:(NSArray *)promos
{
    if ([[NSSet setWithArray:_inRangePromos] isEqualToSet:[NSSet setWithArray:promos]]) {
        return;
    }
    _inRangePromos = promos;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)] withRowAnimation:YES];
}


- (void)HypeSDK:(HypeSDK *)hypesdk syncFinished:(BOOL)hasChanges
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:YES];
}


- (void)HypeSDK:(HypeSDK *)hypesdk subscriptionUpdate:(NSArray *)subscriptions
{
    if (_subscriptions != nil && [[NSSet setWithArray:_subscriptions] isEqualToSet:[NSSet setWithArray:subscriptions]]) {
        return;
    }
    
    _subscriptions = subscriptions;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:YES];
}


- (void)HypeSDK:(HypeSDK *)hypesdk redemptionForPromo:(HypePromo *)promo withItem:(HypeItem *)item
{
}

- (void)HypeSDK:(HypeSDK *)hypesdk accountError:(NSError *)error
{
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] showViewControllerWithIdentifier:@"Registration"];
}

- (void)HypeSDK:(HypeSDK *)hypesdk triggerSurveys:(NSArray *)surveys
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        HypeSurvey *survey = [surveys firstObject];
        UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Survey" message:@"Would you like to take a survey?" cancelButtonTitle:@"Later" otherButtonTitles:@"Yes",nil];
        [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
            if (!didCancel) {
                [self performSegueWithIdentifier:@"SurveySegue" sender:survey];
            }
        }];
    });
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"PromoSegue"]) {
        PromoTableViewController *promoTableViewController = (PromoTableViewController*)segue.destinationViewController;
        promoTableViewController.promo = (HypePromo*)sender;
        
    } else if ([segue.identifier isEqualToString:@"SubscriptionSegue"]) {
        SubscriptionTableViewController *subscriptionTableViewController = (SubscriptionTableViewController*)segue.destinationViewController;
        subscriptionTableViewController.subscription = (HypeSubscription*)sender;
        
    } else if ([segue.identifier isEqualToString:@"PrizeSegue"]) {
        PrizesTableViewController *prizesTableViewController = (PrizesTableViewController*)segue.destinationViewController;
        prizesTableViewController.prizes = [sender objectForKey:@"prizes"];
        prizesTableViewController.promo = [sender objectForKey:@"promo"];
        prizesTableViewController.branch_id = [sender objectForKey:@"branch_id"];

    } else if ([segue.identifier isEqualToString:@"ContentSegue"]) {
        ContentViewController *contentViewController = (ContentViewController*)segue.destinationViewController;
        contentViewController.promo = (HypePromo*)sender;

    } else if ([segue.identifier isEqualToString:@"UserProfileSegue"]) {
        ActivationFormViewController *activationViewController = (ActivationFormViewController*)segue.destinationViewController;
        activationViewController.isEditMode = YES;

    } else if ([segue.identifier isEqualToString:@"SurveySegue"]) {
        SurveyViewController *surveyViewController = (SurveyViewController*)segue.destinationViewController;
        surveyViewController.survey = (HypeSurvey*)sender;

    }
}


- (void)openPromo:(NSNotification*)notification
{
    HypePromo *promo = [[HypeSDK sharedInstance] getPromoFromId:[notification.userInfo objectForKey:@"promo_id"]];
    [self performSegueWithIdentifier:@"PromoSegue" sender:promo];
}

@end
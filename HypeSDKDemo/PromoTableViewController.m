//
//  PromoTableViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/23/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//
// Actions:
//    If merchant coupon: Scan
//    If customer coupon:
//      If availed: Redeem
//      else: Avail
//
// Name
// Branches
// Content
// Prizes
//

#import "PromoTableViewController.h"
#import "SubscriptionTableViewController.h"
#import "BranchMapViewController.h"
#import "NSDate+Utilities.h"
#import "ItemViewController.h"
#import "ContentViewController.h"

@interface PromoTableViewController ()
@property (nonatomic, strong) NSMutableArray *info;
@end

@implementation PromoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _promo.name;
    
    _info = [NSMutableArray new];
    [_info addObject:@{@"title": @"Name", @"value": _promo.name, @"cell": @"Cell", @"selection_style": @"none"}];
    [_info addObject:@{@"title": @"Content", @"value": _promo.name, @"cell": @"Basic", @"segue": @"ContentSegue"}];
    [_info addObject:@{@"title": @"Type", @"value": _promo.isCustomerType ? @"Customer" : @"Merchant", @"cell": @"Cell"}];

    [_info addObject:@{@"title": @"Start", @"value": [_promo.start mediumString], @"cell": @"Cell", @"selection_style": @"none"}];
    [_info addObject:@{@"title": @"End", @"value": [_promo.end mediumString], @"cell": @"Cell", @"selection_style": @"none"}];
    if ([_promo.hours count] > 0) {
        [_info addObject:@{@"title": @"Hours", @"value": [_promo.hours componentsJoinedByString:@", "], @"cell": @"Cell", @"selection_style": @"none"}];
    }
    if ([_promo.days count] > 0) {
        [_info addObject:@{@"title": @"Days", @"value": [_promo.days componentsJoinedByString:@", "], @"cell": @"Cell", @"selection_style": @"none"}];
    }
    if ([_promo.weekdays count] > 0) {
        NSArray *weekday_desc = @[@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat"];
        NSMutableArray *weekdays_withdesc = [NSMutableArray new];
        for (NSNumber *promo_weekday in _promo.weekdays) {
            int weekday = (int)[promo_weekday integerValue] - 1;
            [weekdays_withdesc addObject:[weekday_desc objectAtIndex:weekday]];
        }
        [_info addObject:@{@"title": @"Days of week", @"value": [weekdays_withdesc componentsJoinedByString:@", "], @"cell": @"Cell", @"selection_style": @"none"}];
    }
    
    
    [_info addObject:@{@"title": @"Concurrency Limit", @"value": [NSString stringWithFormat:@"%d", _promo.concurrency], @"cell": @"Cell", @"selection_style": @"none"}];

    [_info addObject:@{@"title": @"Allowed new subscription", @"value": _promo.isAllowedToSubscribe ? @"Yes" : @"No", @"cell": @"Cell", @"selection_style": @"none"}];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [[_info copy] count];
    } else if (section == 1) {
        return [_promo.subscriptions count];
    } else if (section == 2) {
        return [_promo.prizes count];
    } else if (section == 3) {
        return [_promo.branches count];
    }
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Information";
    } else if (section == 1) {
        return @"Subscriptions";
    } else if (section == 2) {
        return @"Prizes";
    } else if (section == 3) {
        return @"Branches";
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSDictionary *infoRow = [_info objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[infoRow objectForKey:@"cell"] forIndexPath:indexPath];
        cell.textLabel.text = [infoRow objectForKey:@"title"];
        cell.detailTextLabel.text = [infoRow objectForKey:@"value"];
        if ([infoRow objectForKey:@"segue"] != nil) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

        return cell;

    } else if (indexPath.section == 1) {
        HypeSubscription *subscription = [_promo.subscriptions objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = subscription.id;
        return cell;

    } else if (indexPath.section == 2) {
        HypeItem *item = [_promo.prizes objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = item.name;
        return cell;
        
    } else if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Basic" forIndexPath:indexPath];
        HypeBranch *branch = [_promo.branches objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = branch.name;
        return cell;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSDictionary *infoRow = [_info objectAtIndex:indexPath.row];
        if ([infoRow objectForKey:@"segue"] != nil) {
            [self performSegueWithIdentifier:[infoRow objectForKey:@"segue"] sender:infoRow];
        }
    } else if (indexPath.section == 1) {
        HypeSubscription *subscription = [_promo.subscriptions objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"SubscriptionSegue" sender:subscription];

    } else if (indexPath.section == 2) {
        HypeItem *item = [_promo.prizes objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ItemSegue" sender:item];
        
    } else if (indexPath.section == 3) {
        HypeBranch *branch = [_promo.branches objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"BranchMapSegue" sender:branch];

    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"SubscriptionSegue"]) {
        SubscriptionTableViewController *subscriptionTableViewController = (SubscriptionTableViewController*)segue.destinationViewController;
        subscriptionTableViewController.subscription = (HypeSubscription*)sender;
        
    } else if ([segue.identifier isEqualToString:@"BranchMapSegue"]) {
        BranchMapViewController *branchMapViewController = (BranchMapViewController*)segue.destinationViewController;
        branchMapViewController.branch = (HypeBranch*)sender;

    } else if ([segue.identifier isEqualToString:@"ItemSegue"]) {
        ItemViewController *itemViewController = (ItemViewController*)segue.destinationViewController;
        itemViewController.item = (HypeItem*)sender;

    } else if ([segue.identifier isEqualToString:@"ContentSegue"]) {
        ContentViewController *contentViewController = (ContentViewController*)segue.destinationViewController;
        contentViewController.promo = _promo;
    }
}


@end

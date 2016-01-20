//
//  SubscriptionTableViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/30/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "SubscriptionTableViewController.h"
#import "PromoTableViewController.h"
#import "QRCodeViewController.h"
#import "BranchMapViewController.h"
#import "ItemViewController.h"
#import "NSDate+Utilities.h"

@interface SubscriptionTableViewController ()
@property (nonatomic, strong) NSMutableArray *info;
@property (nonatomic, strong) NSMutableArray *prize_info;
@end

@implementation SubscriptionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _subscription.id;
    _info = [NSMutableArray new];
    [_info addObject:@{@"title": @"Promo", @"value": _subscription.promo.name, @"cell": @"RightDetailCell", @"segue": @"PromoSegue"}];
    [_info addObject:@{@"title": @"Expiry Date", @"value": [_subscription.promo.end mediumString], @"cell": @"RightDetailCell", @"fontSize": @13.0}];
    [_info addObject:@{@"title": @"Expired", @"value": [_subscription.promo.end isInPast] ? @"Yes" : @"No", @"cell": @"RightDetailCell"}];
    
    if (_subscription.promo.isCustomerType) {
        [_info addObject:@{@"title": @"Code", @"value": _subscription.code, @"cell": @"RightDetailCell", @"segue": @"QRCodeSegue"}];
        [_info addObject:@{@"title": @"Subscription Date", @"value": [_subscription.subscriptionDate mediumString], @"cell": @"RightDetailCell", @"fontSize": @13.0}];
    }

    _prize_info = [NSMutableArray new];
    BOOL redeemed = _subscription.isRedeemed;
    [_prize_info addObject:@{@"title": @"Redeemed", @"value": redeemed ? @"Yes" : @"No", @"cell": @"RightDetailCell"}];
    if (redeemed) {
        [_prize_info addObject:@{@"title": @"Redeemed Item", @"value":_subscription.item.name , @"cell": @"RightDetailCell", @"segue": @"ItemSegue"}];
        [_prize_info addObject:@{@"title": @"Redemption Date", @"value":[_subscription.redemptionDate mediumString], @"cell": @"RightDetailCell", @"fontSize": @13.0}];
        [_prize_info addObject:@{@"title": @"Branch", @"value":_subscription.redemptionBranch.name , @"cell": @"RightDetailCell", @"segue": @"BranchMapSegue"}];
    }

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Information";
    } else if (section == 1) {
        return @"Prize";
    }
    return @"";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [_info count];
    } else if (section == 1) {
        return [_prize_info count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *infoRow;
    if (indexPath.section == 0) {
        infoRow = [_info objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        infoRow = [_prize_info objectAtIndex:indexPath.row];
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[infoRow objectForKey:@"cell"] forIndexPath:indexPath];
    cell.textLabel.text = [infoRow objectForKey:@"title"];
    cell.detailTextLabel.text = [infoRow objectForKey:@"value"];
    if ([infoRow objectForKey:@"segue"] != nil) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([infoRow objectForKey:@"fontSize"] != nil) {
        NSNumber *fontSize = [infoRow valueForKey:@"fontSize"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:[fontSize floatValue]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *infoRow;
    if (indexPath.section == 0) {
        infoRow = [_info objectAtIndex:indexPath.row];
    } else if (indexPath.section == 1) {
        infoRow = [_prize_info objectAtIndex:indexPath.row];
    }

    if ([infoRow objectForKey:@"segue"] != nil) {
        [self performSegueWithIdentifier:[infoRow objectForKey:@"segue"] sender:nil];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"PromoSegue"]) {
        PromoTableViewController *promoTableViewController = (PromoTableViewController*)segue.destinationViewController;
        promoTableViewController.promo = _subscription.promo;
        
    } else if ([segue.identifier isEqualToString:@"QRCodeSegue"]) {
        QRCodeViewController *destinationView = (QRCodeViewController*)segue.destinationViewController;
        destinationView.code = _subscription.code;
    
    } else if ([segue.identifier isEqualToString:@"BranchMapSegue"]) {
        BranchMapViewController *branchMapViewController = (BranchMapViewController*)segue.destinationViewController;
        branchMapViewController.branch = _subscription.redemptionBranch;

    } else if ([segue.identifier isEqualToString:@"ItemSegue"]) {
        ItemViewController *itemViewController = (ItemViewController*)segue.destinationViewController;
        itemViewController.item = _subscription.item;

    }

}

@end

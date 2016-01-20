//
//  PrizesTableViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/29/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "PrizesTableViewController.h"
#import "UIBAlertView.h"
#import "MBProgressHUD.h"
#import "PrizesTableViewCell.h"
#import "PrizeCollectionViewCell.h"

@interface PrizesTableViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *infos;
@end

@implementation PrizesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Redemption";
    _infos = @[@{@"title": @"Name", @"value": _promo.name}];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return 230;
    }
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Promo";
    } else if (section == 1) {
        return @"Please select your prize";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [_infos count];
    }
//    return [_prizes count];
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        NSDictionary *info = [_infos objectAtIndex:indexPath.row];
        cell.textLabel.text = [info objectForKey:@"title"];
        cell.detailTextLabel.text = [info objectForKey:@"value"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    } else {
        PrizesTableViewCell *cell = (PrizesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PrizesCell" forIndexPath:indexPath];
        cell.prizes = _prizes;
        
        NSLog(@"RJ: %@", _prizes);
        cell.collectionView.dataSource = self;
        cell.collectionView.delegate = self;

        return cell;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_prizes count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PrizeCollectionViewCell *cell = (PrizeCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PrizeCell" forIndexPath:indexPath];
    
    HypeItem *item = [_prizes objectAtIndex:indexPath.row];
    cell.imageView.image = item.image;
    cell.title.text = item.name;
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    HypeItem *item = [_prizes objectAtIndex:indexPath.row];
    UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Confirmation" message:[NSString stringWithFormat:@"Redeem %@?", item.name] cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil,nil];
    [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
        if (!didCancel) {
            [MBProgressHUD showHUDAddedTo:self.view withLabel:@"Working" animated:YES];
            [[HypeSDK sharedInstance] redeemPromo:_promo withBranchId:_branch_id withItem:item completion:^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You have selected %@ as your prize.", item.name] cancelButtonTitle:nil otherButtonTitles:@"OK",nil,nil];
                [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Error - Try again" message:(NSString*)error.userInfo cancelButtonTitle:nil otherButtonTitles:@"OK",nil,nil];
                [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
                }];
            }];
        }
    }];

    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

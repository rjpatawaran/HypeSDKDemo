//
//  PrizesTableViewController.h
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/29/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HypeSDK.h"

@interface PrizesTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *prizes;
@property (nonatomic, strong) HypePromo *promo;
@property (nonatomic, strong) NSString *branch_id;
@end

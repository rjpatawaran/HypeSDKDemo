//
//  PrizesTableViewCell.h
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 10/1/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrizesTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *prizes;

@end

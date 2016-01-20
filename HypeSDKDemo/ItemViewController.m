//
//  ItemViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/30/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "ItemViewController.h"

@interface ItemViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _item.name;
    [_imageView setImage:_item.image];
}

@end

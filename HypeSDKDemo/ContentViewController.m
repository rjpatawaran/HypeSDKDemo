//
//  ContentViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 10/5/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _promo.name;
    [_imageView setImage:_promo.content];
}


@end

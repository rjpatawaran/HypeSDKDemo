//
//  QRCodeViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/28/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageView.image = [UIImage mdQRCodeForString:_code size:_imageView.bounds.size.width/5];
    self.title = _code;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

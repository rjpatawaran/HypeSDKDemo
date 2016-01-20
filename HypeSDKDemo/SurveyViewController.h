//
//  SurveyViewController.h
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 10/12/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "XLFormViewController.h"
//#import "HypeSDK.h"
#import "HypeSDK.h"

@interface SurveyViewController : XLFormViewController
@property (strong, nonatomic) HypeSurvey *survey;
@end

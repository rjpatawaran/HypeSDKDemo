//
//  HypeSDK.h
//  HypeSDK
//
//  Created by RJ Patawaran on 9/15/15.
//  Copyright (c) 2015 Entropy Soluction. All rights reserved.
//
/*************************************************************************
Quickstart Guide:

Step 1. Add libHypeSDK.a and HypeSDK.h to your project.

Step 2. Link these libraries:
	libz.tbd
	MobileCoreServices.framework
	AdSupport.framework
	SystemConfiguration.framework

Step 3. Build Settings
	Add "-ObjC" to Other Linker Flags

Step 4. Insert these lines to Info.plist
    <key>NSAppTransportSecurity</key>
    <dict>
            <key>NSAllowsArbitraryLoads</key>
            <true/>
            <key>NSExceptionDomains</key>
            <dict>
                    <key>intelle.biz:</key>
                    <dict>
                            <key>NSIncludesSubdomains</key>
                            <true/>
                            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                            <true/>
                    </dict>
            </dict>
            <key>NSExceptionDomains</key>
            <dict>
                    <key>ehype.s3.amazonaws.com</key>
                    <dict>
                            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                            <true/>
                    </dict>
            </dict>
            <key>NSExceptionDomains</key>
            <dict>
                    <key>testintelle.s3.amazonaws.com</key>
                    <dict>
                            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
                            <true/>
                    </dict>
            </dict>
    </dict>
    <key>NSLocationAlwaysUsageDescription</key>
    <string></string>
    <key>UIBackgroundModes</key>
    <array>
            <string>fetch</string>
            <string>remote-notification</string>
    </array>


Step 5. Setup API KEY
    In AppDelegate.m
	#import "HypeSDK.h"

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        [HypeSDK setupWithAPIKey:@"API_KEY"];

Step 6. Setup APNS
    In AppDelegate.m
     - (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
        [[HypeSDK sharedInstance] registerAPNSToken:deviceToken];
        [application registerForRemoteNotifications];

    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
        [[HypeSDK sharedInstance] didReceiveRemoteNotification:userInfo];

Step 7. Setup Background Fetch
    In AppDelegate.m
    - (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
        [application setMinimumBackgroundFetchInterval:60];
 
    - (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
        [[HypeSDK sharedInstance] fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
            completionHandler(result);
        }];
 
Step 8. Main Form - Set Delegate
    - (void)viewDidLoad {
        [super viewDidLoad];
        [[HypeSDK sharedInstance] setDelegate:self];


 
**************************************************************************
 SAMPLE CALLS
**************************************************************************
 Registration:
 
 NSDictionary *user_data = @{
    @"birthdate": @"1984-10-23 00:56:54 +0000",
    @"email": @"rjpatawaran@me.com",
    @"gender": @"Male",
    @"location": @"560e8c2021b409377db69edc",   // Get values from [[HypeSDK sharedInstance] getRegionsWithCompletion...
    @"msisdn": @"09998812144",
    @"name": @"RJ Patawaran"
 };
 
 [[HypeSDK sharedInstance] activateWithMobileNumber:@"639998812144" userData:user_data completion:^{
    NSLog(@"OK");
 } failure:^(NSError *error) {
    NSLog(@"Failed");
 }];

**************************************************************************
 Get all subscribed promos (Promo Inbox)
 
 NSArray *subscriptions = [[HypeSDK sharedInstance] subscriptions];
 
**************************************************************************
 Detect in-range promo and display content
 
 - (void)viewDidLoad {
    [[HypeSDK sharedInstance] setDelegate:self];
    ...
 
 - (void)HypeSDK:(HypeSDK *)hypesdk inRangePromosUpdate:(NSArray *)promos {
     _promos = promos;
     [self.tableView reloadData];
     ...

**************************************************************************
 Detect all in-range promos
 
 - (void)viewDidLoad {
     [[HypeSDK sharedInstance] setDelegate:self];
     ...
 
 - (void)HypeSDK:(HypeSDK *)hypesdk inRangePromo:(HypePromo *)promo {
     [self performSegueWithIdentifier:@"ContentSegue" sender:promo];
     ...
 
**************************************************************************
 Redemption

 [[HypeSDK sharedInstance] getPromoFromQRCode:qrcode completion:^(NSArray *prizes, HypePromo *promo, HypeBranch *branch) {
     HypeItem *item = [prizes firstObject]; // for demo purposes only
     [[HypeSDK sharedInstance] redeemPromo:promo withBranchId:branch.id withItem:item completion:^{
         UIBAlertView *alert = [[UIBAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You have selected %@ as your prize.", item.name] cancelButtonTitle:nil otherButtonTitles:@"OK",nil,nil];
         [alert showWithDismissHandler:^(NSInteger selectedIndex, BOOL didCancel) {
             [self.navigationController popToRootViewControllerAnimated:YES];
         }];
     
     } failure:^(NSError *error) {
        ...
     }];
 } failure:^(NSError *error) {
    ...
 }];

 
**************************************************************************/


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import CoreLocation;

@class HypeSDK;
@class HypePromo;

@interface HypeBranch : NSObject
@property (readonly) NSString *id;
@property (readonly) NSString *name;
@property (readonly) CLLocation *location;
@property (readonly) float radius;
@property (readonly) NSArray *polygon;
@end

@interface HypeItem : NSObject
@property (readonly) NSString *id;
@property (readonly) NSString *name;
@property (readonly) UIImage *image;
@end

@interface HypeSubscription : NSObject
@property (readonly) NSString *id;
@property (readonly) NSString *code;
@property (readonly) NSDate *subscriptionDate;
@property (readonly) BOOL isRedeemed;
@property (readonly) NSDate *redemptionDate;
- (HypeItem *)item;
- (HypePromo *)promo;
- (HypeBranch *)redemptionBranch;
- (BOOL)canBeRedeemed;
@end

@interface HypePromo : NSObject
@property (readonly) NSString *id;
@property (readonly) NSString *name;
@property (readonly) NSArray *branches;
@property (readonly) UIImage *content;
@property (readonly) NSDate *start;
@property (readonly) NSDate *end;
@property (readonly) NSArray *days;
@property (readonly) NSArray *weekdays;
@property (readonly) NSArray *hours;
@property (readonly) int concurrency;
- (NSArray*)subscriptions;
- (NSArray*)prizes;
- (BOOL)isCustomerType;
- (BOOL)isMerchantType;
- (BOOL)isAllowedToSubscribe;
- (BOOL)inDateRange;
- (BOOL)inLimit;
- (BOOL)isIncludedBranch:(HypeBranch*)branch;
- (HypeSubscription*)unredeemedSubscription;
- (NSArray*)redemeedSubscriptions;
@end

@interface HypeSurvey : NSObject
@property (readonly) NSString *id;
@property (readonly) NSString *name;
@property (readonly) NSArray *questions;
- (void)submitAnswers:(NSArray*)answers;
@end

@interface HypeSurveyQuestion: NSObject
@property (readonly) NSString *question;
@property (readonly) NSArray *options;
@end;

@protocol HypeSDKDelegate <NSObject>
@optional
- (void)HypeSDK:(HypeSDK *)hypesdk inRangePromo:(HypePromo*)promo;
- (void)HypeSDK:(HypeSDK *)hypesdk inRangePromosUpdate:(NSArray*)promos;
- (void)HypeSDK:(HypeSDK *)hypesdk outOfRange:(HypePromo*)promo;
- (void)HypeSDK:(HypeSDK *)hypesdk subscriptionUpdate:(NSArray*)subscriptions;
- (void)HypeSDK:(HypeSDK *)hypesdk syncFinished:(BOOL)hasChanges;
- (void)HypeSDK:(HypeSDK *)hypesdk redemptionForPromo:(HypePromo*)promo withItem:(HypeItem*)item;
- (void)HypeSDK:(HypeSDK *)hypesdk triggerSurveys:(NSArray*)surveys;
- (void)HypeSDK:(HypeSDK *)hypesdk accountError:(NSError*)error;
@end

@interface HypeSDK : NSObject
@property (nonatomic, weak) id<HypeSDKDelegate> delegate;
@property (nonatomic, readonly) NSArray *subscriptions;

+ (id)sharedInstance;
+ (id)setupWithAPIKey:(NSString*)APIKey;

- (void)getRegionsWithCompletion:(void (^)(NSArray *regions))completion
                         failure:(void (^)(NSError *error))failure;

- (void)activateWithMobileNumber:(NSString*)mobile_number
                    userData:(NSDictionary*)userData
                  completion:(void (^)(void))completion
                     failure:(void (^)(NSError *error))failure;

- (void)activateWithEmailAddress:(NSString*)email_address
                        userData:(NSDictionary*)userData
                      completion:(void (^)(void))completion
                         failure:(void (^)(NSError *error))failure;

- (void)getProfileWithCompletion:(void (^)(NSDictionary *userData))completion
                         failure:(void (^)(NSError *error))failure;

- (void)updateProfile:(NSDictionary*)userData
           completion:(void (^)(void))completion
              failure:(void (^)(NSError *error))failure;

- (BOOL)isActivated;

- (void)getPromoFromQRCode:(NSString*)qr_code
                completion:(void (^)(NSArray *prizes, HypePromo *promo, HypeBranch *branch))completion
                   failure:(void (^)(NSError *error))failure;

- (void)redeemPromo:(HypePromo*)promo
       withBranchId:(NSString*)branch_id
           withItem:(HypeItem*)item
         completion:(void (^)(void))completion
            failure:(void (^)(NSError *error))failure;

- (HypePromo*)getPromoFromId:(NSString*)promo_id;

- (void)unlinkAccount;

- (void)registerAPNSToken:(NSData*)deviceToken;

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

- (NSArray*)getSurveys;

- (void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

#import "Verification.h"
#import <UIKit/UIKit.h>

static NSString *const kVIPKey = @"MOSTASH_VIP";
static NSString *const kCodesKey = @"MOSTASH_CODES_DB";

@interface MostashVerification ()
@property (nonatomic, strong) UIWindow *overlayWindow;
@property (nonatomic, strong) UITextField *codeField;
@end

@implementation MostashVerification

#pragma mark - INIT DEFAULT CODES

- (NSArray *)loadDefaultCodes {

    return @[
        // 🔵 DAILY CODES (15)
        @{@"code": @"MOSTASH7A9K", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH2B6M", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH8C1V", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH5D7N", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH9E3X", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH1F8T", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH6G2R", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH3H9Q", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH4J5K", @"type": @"daily", @"used": @NO},
        @{@"code": @"MOSTASH7L1P", @"type": @"daily", @"used": @NO},

        // 🟡 PERMANENT CODES (20)
        @{@"code": @"MOSTASH7A9K1XQ3", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH2B6M9LZ8", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH8C1V4RT5", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH5D7N2PQ9", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH9E3X6KM1", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH1F8T7YV4", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH6G2R9LX7", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH3H9Q1BZ6", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH4J5K8NM2", @"type": @"permanent", @"used": @NO},
        @{@"code": @"MOSTASH7L1P3XT9", @"type": @"permanent", @"used": @NO}
    ];
}

#pragma mark - LOAD DB

- (NSMutableArray *)loadDB {

    NSMutableArray *db =
    [[[NSUserDefaults standardUserDefaults] objectForKey:kCodesKey] mutableCopy];

    if (!db) {
        db = [[self loadDefaultCodes] mutableCopy];
        [[NSUserDefaults standardUserDefaults] setObject:db forKey:kCodesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return db;
}

#pragma mark - SHOW UI

- (void)showVerificationIfNeeded {

    if ([[NSUserDefaults standardUserDefaults] boolForKey:kVIPKey]) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildUI];
    });
}

- (UIWindow *)getWindow {

    UIWindow *w = nil;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive &&
                [scene isKindOfClass:[UIWindowScene class]]) {

                for (UIWindow *win in ((UIWindowScene *)scene).windows) {
                    if (win.isKeyWindow) {
                        w = win;
                        break;
                    }
                }
            }
        }
    }

    if (!w) w = UIApplication.sharedApplication.windows.firstObject;

    return w;
}

- (void)buildUI {

    UIWindow *base = [self getWindow];

    self.overlayWindow = [[UIWindow alloc] initWithFrame:base.bounds];
    self.overlayWindow.windowLevel = UIWindowLevelAlert + 999;
    self.overlayWindow.hidden = NO;

    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
    card.center = vc.view.center;
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 14;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 320, 30)];
    title.text = @"MOSTASH VIP SYSTEM";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];

    self.codeField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, 280, 40)];
    self.codeField.placeholder = @"Enter Code";
    self.codeField.textAlignment = NSTextAlignmentCenter;
    self.codeField.borderStyle = UITextBorderStyleRoundedRect;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 140, 280, 45);
    [btn setTitle:@"VERIFY" forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemGreenColor;
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.layer.cornerRadius = 8;
    [btn addTarget:self action:@selector(checkCode) forControlEvents:UIControlEventTouchUpInside];

    [card addSubview:title];
    [card addSubview:self.codeField];
    [card addSubview:btn];
    [vc.view addSubview:card];

    self.overlayWindow.rootViewController = vc;
    [self.overlayWindow makeKeyAndVisible];
}

#pragma mark - CHECK ENGINE

- (void)checkCode {

    NSString *input = self.codeField.text;
    if (input.length == 0) return;

    NSMutableArray *db = [self loadDB];

    __block BOOL found = NO;

    for (NSMutableDictionary *item in db) {

        if ([item[@"code"] isEqualToString:input]) {

            if ([item[@"used"] boolValue] &&
                [item[@"type"] isEqualToString:@"daily"]) {
                return;
            }

            item[@"used"] = @YES;

            found = YES;
            break;
        }
    }

    if (found) {

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kVIPKey];
        [[NSUserDefaults standardUserDefaults] setObject:db forKey:kCodesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.overlayWindow removeFromSuperview];
        self.overlayWindow = nil;

        NSLog(@"✔ VIP VERIFIED");

    } else {
        [self showError];
    }
}

#pragma mark - ERROR

- (void)showError {

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"ERROR"
                                        message:@"Invalid or Used Code"
                                 preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];

    UIViewController *vc = self.overlayWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

@end

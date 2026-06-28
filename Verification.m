#import "Verification.h"
#import <UIKit/UIKit.h>

static NSString *const kIsMostashVerifiedKey = @"isMostashVerified";

@interface MostashVerification () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UITextField *codeTextField;
@property (nonatomic, assign) BOOL verified;

@end

@implementation MostashVerification

- (instancetype)init {
    self = [super init];
    if (self) {
        _verified = [[NSUserDefaults standardUserDefaults] boolForKey:kIsMostashVerifiedKey];
    }
    return self;
}

#pragma mark - Show

- (void)showVerificationIfNeeded {
    if (self.verified) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildOverlay];
    });
}

#pragma mark - UI

- (void)buildOverlay {

    UIWindow *baseWindow = UIApplication.sharedApplication.keyWindow;

    self.overlayView = [[UIView alloc] initWithFrame:baseWindow.bounds];
    self.overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 260)];
    container.center = self.overlayView.center;
    container.backgroundColor = UIColor.whiteColor;
    container.layer.cornerRadius = 12;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 300, 30)];
    title.text = @"MOSTASH VERIFICATION";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:title];

    self.codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, 280, 40)];
    self.codeTextField.placeholder = @"Enter Code";
    self.codeTextField.textAlignment = NSTextAlignmentCenter;
    self.codeTextField.borderStyle = UITextBorderStyleRoundedRect;
    [container addSubview:self.codeTextField];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 140, 280, 45);
    [btn setTitle:@"VERIFY" forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemGreenColor;
    btn.tintColor = UIColor.whiteColor;
    btn.layer.cornerRadius = 8;
    [btn addTarget:self action:@selector(checkCode) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:btn];

    [self.overlayView addSubview:container];
    [baseWindow addSubview:self.overlayView];
}

#pragma mark - CODES CHECK (35 CODES)

- (void)checkCode {

    NSString *entered = self.codeTextField.text;

    if (entered.length == 0) return;

    // ⏳ DAILY CODES (15)
    NSArray *dailyCodes = @[
        @"MOSTASH7A9K",
        @"MOSTASH2B6M",
        @"MOSTASH8C1V",
        @"MOSTASH5D7N",
        @"MOSTASH9E3X",
        @"MOSTASH1F8T",
        @"MOSTASH6G2R",
        @"MOSTASH3H9Q",
        @"MOSTASH4J5K",
        @"MOSTASH7L1P",
        @"MOSTASH2M8V",
        @"MOSTASH9N3Y",
        @"MOSTASH5P6X",
        @"MOSTASH1Q7B",
        @"MOSTASH8R2T"
    ];

    // 💎 PERMANENT CODES (20)
    NSArray *permanentCodes = @[
        @"MOSTASH7A9K1XQ3",
        @"MOSTASH2B6M9LZ8",
        @"MOSTASH8C1V4RT5",
        @"MOSTASH5D7N2PQ9",
        @"MOSTASH9E3X6KM1",
        @"MOSTASH1F8T7YV4",
        @"MOSTASH6G2R9LX7",
        @"MOSTASH3H9Q1BZ6",
        @"MOSTASH4J5K8NM2",
        @"MOSTASH7L1P3XT9",
        @"MOSTASH2M8V6QK4",
        @"MOSTASH9N3Y1RT7",
        @"MOSTASH5P6X8LM2",
        @"MOSTASH1Q7B4NV9",
        @"MOSTASH8R2T6YK5",
        @"MOSTASH3S9L1PX7",
        @"MOSTASH6T4M8QZ2",
        @"MOSTASH2V1K9RL6",
        @"MOSTASH7W8X3MN4",
        @"MOSTASH9Y5Q2TB1"
    ];

    BOOL isValid = NO;

    if ([dailyCodes containsObject:entered] || [permanentCodes containsObject:entered]) {
        isValid = YES;
    }

    if (isValid) {

        self.verified = YES;

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsMostashVerifiedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.overlayView removeFromSuperview];

        NSLog(@"✔ VIP VERIFIED SUCCESS");
    } else {
        [self showError];
    }
}

#pragma mark - ERROR

- (void)showError {

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"ERROR"
                                        message:@"Invalid Code"
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:nil];

    [alert addAction:ok];

    UIViewController *topVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    [topVC presentViewController:alert animated:YES completion:nil];
}

@end

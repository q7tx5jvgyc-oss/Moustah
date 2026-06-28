#import "VerificationViewController.h"
#import <UIKit/UIKit.h>

@interface VerificationViewController ()

@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UIView *card;
@property (nonatomic, assign) BOOL didShow;

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // ❌ منع التكرار (حل مشكلة الخانتين)
    if (self.didShow) return;
    self.didShow = YES;

    [self setupUI];
}

#pragma mark - UI

- (void)setupUI {

    self.view.backgroundColor = UIColor.clearColor;

    // 🌫 خلفية شفافة بدل الشاشة السوداء
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = self.view.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurView];

    // 💎 Card VIP واحد فقط
    self.card = [[UIView alloc] initWithFrame:CGRectMake(40, 180, 300, 320)];
    self.card.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    self.card.layer.cornerRadius = 18;
    self.card.layer.borderWidth = 1.5;
    self.card.layer.borderColor = UIColor.systemYellowColor.CGColor;

    self.card.layer.shadowColor = UIColor.blackColor.CGColor;
    self.card.layer.shadowOpacity = 0.5;
    self.card.layer.shadowRadius = 12;
    self.card.layer.shadowOffset = CGSizeMake(0, 6);

    [self.view addSubview:self.card];

    // 👑 Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 30)];
    title.text = @"MOSTASH VIP ACCESS";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:18];
    [self.card addSubview:title];

    // 🔑 Input (واحد فقط - حل مشكلة الخانتين)
    self.codeField = [[UITextField alloc] initWithFrame:CGRectMake(30, 90, 240, 45)];
    self.codeField.placeholder = @"Enter Activation Code";
    self.codeField.backgroundColor = UIColor.whiteColor;
    self.codeField.textAlignment = NSTextAlignmentCenter;
    self.codeField.layer.cornerRadius = 10;
    self.codeField.clipsToBounds = YES;
    [self.card addSubview:self.codeField];

    // 🚀 Button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(30, 160, 240, 45);
    [btn setTitle:@"ACTIVATE VIP" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemGreenColor;
    btn.layer.cornerRadius = 10;
    [btn addTarget:self action:@selector(checkCode) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:btn];

    // 📦 Info
    UILabel *info = [[UILabel alloc] initWithFrame:CGRectMake(0, 230, 300, 60)];
    info.text = @"20 Permanent Codes\n10 Daily Codes";
    info.numberOfLines = 2;
    info.textAlignment = NSTextAlignmentCenter;
    info.textColor = UIColor.lightGrayColor;
    info.font = [UIFont systemFontOfSize:13];
    [self.card addSubview:info];
}

#pragma mark - Logic

- (void)checkCode {

    NSString *code = self.codeField.text;

    if (code.length == 0) {
        [self showAlert:@"Error" message:@"Please enter code"];
        return;
    }

    NSArray *dailyCodes = @[
        @"MOSTASH1", @"MOSTASH2", @"MOSTASH3"
    ];

    NSArray *permanentCodes = @[
        @"MOSTASH7A9K",
        @"MOSTASH2B6M",
        @"MOSTASH8C1V"
        // تقدر تكمل 20 هنا
    ];

    if ([permanentCodes containsObject:code] || [dailyCodes containsObject:code]) {

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isActivated"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self showAlert:@"SUCCESS" message:@"Activated Successfully"];

    } else {
        [self showAlert:@"ERROR" message:@"Invalid Code"];
    }
}

#pragma mark - Alert

- (void)showAlert:(NSString *)title message:(NSString *)msg {

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:nil];

    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

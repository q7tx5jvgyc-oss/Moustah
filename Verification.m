#import "Verification.h"
#import <UIKit/UIKit.h>

static NSString *const kMostashAuthCode = @"MOSTAH77669";
static NSString *const kIsMostashVerifiedKey = @"isMostashVerified";

@interface MostashVerification () <UITextFieldDelegate>

@property (nonatomic, strong) UIWindow *verificationWindow;
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

- (BOOL)isVerified {
    return self.verified;
}

#pragma mark - Show

- (void)showVerificationIfNeeded {

    if (self.isVerified) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildOverlay];
    });
}

#pragma mark - Build UI (ULTRA FIX)

- (void)buildOverlay {

    // 💀 نجيب أعلى window حقيقي (مهم للألعاب)
    UIWindow *baseWindow = nil;

    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) {
            baseWindow = w;
            break;
        }
    }

    if (!baseWindow) {
        baseWindow = [UIApplication sharedApplication].windows.firstObject;
    }

    // 💀 Overlay يغطي اللعبة
    self.overlayView = [[UIView alloc] initWithFrame:baseWindow.bounds];
    self.overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    self.overlayView.tag = 99999;

    // Container
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
    container.center = self.overlayView.center;
    container.backgroundColor = UIColor.whiteColor;
    container.layer.cornerRadius = 12;

    // Title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 280, 30)];
    title.text = @"نظام حماية موستاش";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:18];
    [container addSubview:title];

    // Input
    self.codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 90, 240, 35)];
    self.codeTextField.placeholder = @"أدخل الكود";
    self.codeTextField.textAlignment = NSTextAlignmentCenter;
    self.codeTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.codeTextField.delegate = self;
    [container addSubview:self.codeTextField];

    // Button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(30, 140, 240, 40);
    [btn setTitle:@"تفعيل" forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemGreenColor;
    btn.tintColor = UIColor.whiteColor;
    btn.layer.cornerRadius = 8;
    [btn addTarget:self action:@selector(checkCode) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:btn];

    [self.overlayView addSubview:container];

    // 💀 نضيف فوق نافذة اللعبة مباشرة
    [baseWindow addSubview:self.overlayView];

    // 💀 نجبرها تظهر فوق كل شيء
    [baseWindow bringSubviewToFront:self.overlayView];
}

#pragma mark - Check Code

- (void)checkCode {

    NSString *entered = self.codeTextField.text;

    if ([entered isEqualToString:kMostashAuthCode]) {

        self.verified = YES;

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsMostashVerifiedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self.overlayView removeFromSuperview];

        NSLog(@"✔ VERIFIED SUCCESS");

    } else {

        [self showError];
    }
}

#pragma mark - Error

- (void)showError {

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"خطأ"
                                        message:@"الكود غير صحيح"
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:nil];

    [alert addAction:ok];

    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [topVC presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self checkCode];
    return YES;
}

@end

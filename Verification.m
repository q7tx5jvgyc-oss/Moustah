#import "Verification.h"
#import <UIKit/UIKit.h>

static NSString *const kMostashAuthCode = @"MOSTAH77669";
static NSString *const kIsMostashVerifiedKey = @"isMostashVerified";

@interface MostashVerification () <UITextFieldDelegate>
@property (nonatomic, strong) UIWindow *verificationWindow;
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
    return _verified;
}

- (void)showVerificationIfNeeded {
    if (!self.isVerified) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupVerificationUI];
        });
    }
}

- (void)setupVerificationUI {
    self.verificationWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.verificationWindow.windowLevel = UIWindowLevelStatusBar + 1; // Ensure it's on top
    self.verificationWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8]; // Semi-transparent black background
    
    UIViewController *rootVC = [[UIViewController alloc] init];
    self.verificationWindow.rootViewController = rootVC;
    
    // Verification Container View
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    containerView.center = rootVC.view.center;
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 10;
    [rootVC.view addSubview:containerView];
    
    // Title Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, containerView.frame.size.width - 20, 30)];
    titleLabel.text = @"ÙØ¸Ø§Ù Ø­ÙØ§ÙØ© ÙÙØ³ØªØ§Ø´";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [containerView addSubview:titleLabel];
    
    // Prompt Label
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, containerView.frame.size.width - 20, 20)];
    promptLabel.text = @"ÙÙ Ø¨ÙØ¶Ø¹ Ø§ÙÙÙØ¯ ÙØªÙØ¹ÙÙ Ø§ÙØ§Ø´ØªØ±Ø§Ù ÙÙ Ø§ÙØªÙ ÙÙØ³ØªØ§Ø´";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont systemFontOfSize:14];
    [containerView addSubview:promptLabel];
    
    // Code Text Field
    _codeTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 90, containerView.frame.size.width - 60, 35)];
    _codeTextField.placeholder = @"Ø£Ø¯Ø®Ù Ø§ÙÙÙØ¯ ÙÙØ§";
    _codeTextField.textAlignment = NSTextAlignmentCenter;
    _codeTextField.borderStyle = UITextBorderStyleRoundedRect;
    _codeTextField.delegate = self;
    _codeTextField.returnKeyType = UIReturnKeyDone;
    [containerView addSubview:_codeTextField];
    
    // Activate Button
    UIButton *activateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    activateButton.frame = CGRectMake(30, 140, containerView.frame.size.width - 60, 40);
    [activateButton setTitle:@"ØªÙØ¹ÙÙ" forState:UIControlStateNormal];
    activateButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:1.0];
    [activateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    activateButton.layer.cornerRadius = 8;
    [activateButton addTarget:self action:@selector(checkCode) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:activateButton];
    
    [self.verificationWindow makeKeyAndVisible];
    [_codeTextField becomeFirstResponder]; // Automatically show keyboard
}

- (void)checkCode {
    // Basic hash comparison (for demonstration, a real app would use a more robust method)
    NSString *enteredCode = _codeTextField.text;
    if ([self hashString:enteredCode] == [self hashString:kMostashAuthCode]) {
        _verified = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIsMostashVerifiedKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self showWelcomeMessage];
    } else {
        // Incorrect code, close the app
        [self showErrorMessageAndExit];
    }
}

- (NSUInteger)hashString:(NSString *)string {
    // Simple hash for demonstration purposes
    return [string hash];
}

- (void)showWelcomeMessage {
    [self.verificationWindow setHidden:YES];
    
    UIWindow *welcomeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    welcomeWindow.windowLevel = UIWindowLevelStatusBar + 2; // Above verification window
    welcomeWindow.backgroundColor = [UIColor clearColor];
    
    UIViewController *welcomeVC = [[UIViewController alloc] init];
    welcomeWindow.rootViewController = welcomeVC;
    
    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 100)];
    welcomeLabel.center = welcomeVC.view.center;
    welcomeLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    welcomeLabel.textColor = [UIColor whiteColor];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.numberOfLines = 0;
    welcomeLabel.layer.cornerRadius = 10;
    welcomeLabel.clipsToBounds = YES;
    welcomeLabel.text = @"Ø§ÙÙØ§ ØªÙ ØªÙØ¹ÙÙ Ø§ÙØ§ÙØªÙ Ø§ÙØ®Ø§Øµ ÙÙ Ø§ÙÙØ·ÙØ± ÙÙØ³ØªØ§Ø´ Ø§Ø³ØªÙØªØ¹ð¤!";
    welcomeLabel.alpha = 0.0; // Start invisible
    [welcomeVC.view addSubview:welcomeLabel];
    
    [welcomeWindow makeKeyAndVisible];
    
    [UIView animateWithDuration:0.5 animations:^{
        welcomeLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 5 seconds
            [UIView animateWithDuration:0.5 animations:^{
                welcomeLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                [welcomeWindow setHidden:YES];
                self.verificationWindow = nil; // Release verification window
            }];
        });
    }];
}

- (void)showErrorMessageAndExit {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Ø®Ø·Ø£ ÙÙ Ø§ÙØªØ­ÙÙ" message:@"Ø§ÙÙÙØ¯ Ø®Ø§Ø·Ø¦. Ø³ÙØªÙ Ø¥ØºÙØ§Ù Ø§ÙØªØ·Ø¨ÙÙ." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"ÙÙØ§ÙÙ" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        exit(0); // Terminate the app
    }];
    [alert addAction:okAction];
    
    // Present the alert on the top-most view controller
    UIViewController *topVC = [self topViewController];
    if (topVC) {
        [topVC presentViewController:alert animated:YES completion:nil];
    } else {
        // Fallback if no top view controller is found
        NSLog(@"Error: Could not find top view controller to present alert.");
        exit(0);
    }
}

- (UIViewController *)topViewController {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *topVC = keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self checkCode];
    return YES;
}

@end

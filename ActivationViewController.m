#import "ActivationViewController.h"
#import "ConfigManager.h"
#import <objc/runtime.h>

@interface ActivationViewController ()

@property (nonatomic, strong) UITextField *input;

@end

@implementation ActivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    // Input
    self.input = [[UITextField alloc] initWithFrame:CGRectMake(40, 200, 250, 50)];
    self.input.placeholder = @"Enter Code";
    self.input.backgroundColor = UIColor.whiteColor;
    self.input.textAlignment = NSTextAlignmentCenter;
    self.input.layer.cornerRadius = 8;
    self.input.clipsToBounds = YES;
    [self.view addSubview:self.input];

    // Button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 300, 120, 50);
    [btn setTitle:@"Activate" forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemBlueColor;
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.layer.cornerRadius = 10;
    [btn addTarget:self action:@selector(checkCode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark - Activation

- (void)checkCode:(UIButton *)sender {

    NSString *code = self.input.text;

    if (code.length == 0) {
        [self showAlert:@"Error" message:@"Please enter a code"];
        return;
    }

    NSArray *validCodes = @[
        @"MOSTAH1",
        @"MOSTAH2",
        @"MOSTAH3"
    ];

    if ([validCodes containsObject:code]) {

        [[ConfigManager shared] setIsActivated:YES];
        [[ConfigManager shared] saveConfig];

        [self showAlert:@"Success" message:@"Activated Successfully"];

    } else {

        [self showAlert:@"Error" message:@"Invalid Code"];
    }
}

#pragma mark - Alert Helper

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

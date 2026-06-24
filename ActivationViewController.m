#import "ActivationViewController.h"
#import "ConfigManager.h"

@implementation ActivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    UITextField *input = [[UITextField alloc] initWithFrame:CGRectMake(40, 200, 250, 50)];
    input.placeholder = @"Enter Code";
    input.backgroundColor = UIColor.whiteColor;
    input.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:input];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 300, 120, 50);
    [btn setTitle:@"Activate" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(checkCode:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 100;
    [self.view addSubview:btn];

    objc_setAssociatedObject(btn, @"input", input, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)checkCode:(UIButton *)sender {

    UITextField *input = objc_getAssociatedObject(sender, @"input");

    NSArray *validCodes = @[@"MOSTAH1", @"MOSTAH2", @"MOSTAH3"];

    if ([validCodes containsObject:input.text]) {

        [[ConfigManager shared] setIsActivated:YES];
        [[ConfigManager shared] saveConfig];

        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Success"
                                            message:@"Activated Successfully"
                                     preferredStyle:UIAlertControllerStyleAlert];

        [self presentViewController:alert animated:YES completion:nil];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [alert dismissViewControllerAnimated:YES completion:nil];
        });

    } else {
        exit(0);
    }
}

@end

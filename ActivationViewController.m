#import "ActivationViewController.h"
#import "LicenseManager.h"

@implementation ActivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.blackColor;

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(50, 200, 250, 40)];
    field.placeholder = @"Enter Code";
    field.backgroundColor = UIColor.whiteColor;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(50, 260, 250, 40);
    [btn setTitle:@"Activate" forState:UIControlStateNormal];

    [btn addTarget:self action:@selector(check:)
  forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:field];
    [self.view addSubview:btn];
}

- (void)check:(UIButton *)btn {

    [[NSUserDefaults standardUserDefaults] setObject:@"VALID_CODE"
                                              forKey:@"license"];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

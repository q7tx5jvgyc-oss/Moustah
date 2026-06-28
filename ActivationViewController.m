#import "VerificationViewController.h"

@interface VerificationViewController ()

@property (nonatomic, strong) UITextField *codeField;
@property (nonatomic, strong) UIView *card;

@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

#pragma mark - UI

- (void)setupUI {

    self.view.backgroundColor = [UIColor blackColor];

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.96];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:overlay];

    self.card = [[UIView alloc] initWithFrame:CGRectMake(40, 160, self.view.frame.size.width - 80, 380)];
    self.card.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.85];
    self.card.layer.cornerRadius = 18;

    [overlay addSubview:self.card];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.card.frame.size.width, 40)];
    title.text = @"MOSTASH VIP";
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont boldSystemFontOfSize:28];
    [self.card addSubview:title];

    self.codeField = [[UITextField alloc] initWithFrame:CGRectMake(20, 110, self.card.frame.size.width - 40, 50)];
    self.codeField.placeholder = @"Enter Code";
    self.codeField.textAlignment = NSTextAlignmentCenter;
    self.codeField.backgroundColor = UIColor.whiteColor;
    self.codeField.layer.cornerRadius = 10;
    [self.card addSubview:self.codeField];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 190, self.card.frame.size.width - 40, 55);
    [btn setTitle:@"VERIFY" forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemGreenColor;
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.layer.cornerRadius = 10;
    [btn addTarget:self action:@selector(checkCode) forControlEvents:UIControlEventTouchUpInside];
    [self.card addSubview:btn];
}

#pragma mark - SERVER REQUEST

- (void)checkCode {

    NSString *code = self.codeField.text;
    if (code.length == 0) return;

    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    NSURL *url = [NSURL URLWithString:@"https://YOUR-SERVER.com/api/verify"];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary *body = @{
        @"code": code,
        @"device": deviceID
    };

    NSData *data = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    request.HTTPBody = data;

    NSURLSessionDataTask *task =
    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error || !data) return;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        dispatch_async(dispatch_get_main_queue(), ^{

            if ([json[@"status"] isEqualToString:@"success"]) {

                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MOSTASH_VIP"];
                [[NSUserDefaults standardUserDefaults] synchronize];

                [self showAlert:@"WELCOME VIP 🔥" message:json[@"message"]];

            } else {
                [self showAlert:@"FAILED ❌" message:json[@"message"]];
            }
        });

    }];

    [task resume];
}

- (void)showAlert:(NSString *)title message:(NSString *)msg {

    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];

    [self presentViewController:alert animated:YES completion:nil];
}

@end

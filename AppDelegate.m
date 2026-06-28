#import "AppDelegate.h"
#import "ConfigManager.h"
#import "ActivationViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSLog(@"App Started");

    [[ConfigManager shared] loadConfig];

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;

    // 🔐 تحقق من التفعيل
    if ([[ConfigManager shared] isActivated]) {

        // التطبيق مفعل → يفتح مباشرة (هنا ضع الـ main VC)
        UIViewController *mainVC = [UIViewController new];
        mainVC.view.backgroundColor = UIColor.whiteColor;

        window.rootViewController = mainVC;

    } else {

        // غير مفعل → يروح لشاشة التفعيل
        ActivationViewController *vc = [ActivationViewController new];
        window.rootViewController = vc;
    }

    [window makeKeyAndVisible];

    return YES;
}

@end

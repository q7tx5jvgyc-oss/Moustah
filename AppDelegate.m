#import "AppDelegate.h"
#import "ConfigManager.h"
#import "ActivationViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[ConfigManager shared] loadConfig];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    UIViewController *root;

    if ([[ConfigManager shared] isActivated]) {
        root = [UIViewController new];
        root.view.backgroundColor = UIColor.systemBackgroundColor;
    } else {
        root = [ActivationViewController new];
    }

    self.window.rootViewController = root;
    [self.window makeKeyAndVisible];

    return YES;
}

@end

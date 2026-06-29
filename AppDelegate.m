#import "AppDelegate.h"
#import "ConfigManager.h"
#import "ActivationViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[ConfigManager shared] loadConfig];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    UIViewController *rootVC = [self initialController];

    self.window.rootViewController = rootVC;
    [self.window makeKeyAndVisible];

    return YES;
}

#pragma mark - Router

- (UIViewController *)initialController {

    BOOL activated = [[ConfigManager shared] isActivated];

    if (activated) {

        UIViewController *mainVC = [UIViewController new];
        mainVC.view.backgroundColor = UIColor.systemBackgroundColor;

        return mainVC;
    }

    return [self activationController];
}

- (UIViewController *)activationController {

    ActivationViewController *vc = [ActivationViewController new];
    vc.view.backgroundColor = UIColor.systemBackgroundColor;

    return vc;
}

#pragma mark - State Refresh (مهم)

- (void)refreshRoot {

    dispatch_async(dispatch_get_main_queue(), ^{

        UIViewController *newRoot = [self initialController];

        self.window.rootViewController = newRoot;

        [self.window makeKeyAndVisible];
    });
}

@end

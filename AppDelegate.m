#import "AppDelegate.h"
#import "ConfigManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSLog(@"App Started");

    [[ConfigManager shared] loadConfig];

    return YES;
}

@end

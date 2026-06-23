#import "AppDelegate.h"
#import "OverlayManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSLog(@"APP STARTED");

    [[OverlayManager shared] startOverlay];

    return YES;
}

@end

#import "AppDelegate.h"
#import "OverlayManager.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 🔥 تشغيل نظام الـ Overlay عند فتح التطبيق
    [[OverlayManager shared] startOverlay];

    return YES;
}

@end

#import "SceneDelegate.h"
#import "OverlayManager.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
options:(UISceneConnectionOptions *)connectionOptions {

    [[OverlayManager shared] startOverlay];
}

@end

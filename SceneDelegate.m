#import "SceneDelegate.h"
#import "OverlayManager.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
options:(UISceneConnectionOptions *)connectionOptions {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[OverlayManager shared] startOverlay];
    });
}

@end

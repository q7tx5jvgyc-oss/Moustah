#import "OverlayManager.h"

@interface OverlayManager ()
@property (strong, nonatomic) UIWindow *overlayWindow;
@end

@implementation OverlayManager

+ (instancetype)shared {
    static OverlayManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [OverlayManager new];
    });
    return obj;
}

#pragma mark - START

- (void)startOverlay {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildOverlay];
    });
}

#pragma mark - GET WINDOW (SAFE)

- (UIWindow *)activeWindow {

    UIWindow *found = nil;

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:UIWindowScene.class]) {

            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                if (w.isKeyWindow) {
                    found = w;
                    break;
                }
            }
        }
    }

    return found ?: UIApplication.sharedApplication.windows.firstObject;
}

#pragma mark - BUILD OVERLAY

- (void)buildOverlay {

    UIWindow *hostWindow = [self activeWindow];
    if (!hostWindow) return;

    // ❗ مهم: لا نعيد إنشاء window كل مرة
    if (self.overlayWindow) return;

    self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    self.overlayWindow.windowScene = hostWindow.windowScene;
    self.overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    self.overlayWindow.hidden = NO;

    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = UIColor.clearColor;

    // 🔴 Floating Button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(80, 200, 70, 70);
    btn.backgroundColor = UIColor.redColor;
    btn.layer.cornerRadius = 35;
    [btn setTitle:@"M" forState:UIControlStateNormal];

    // 📦 Panel
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(50, 300, 250, 220)];
    panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    panel.layer.cornerRadius = 12;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 220, 30)];
    label.text = @"Control Panel";
    label.textColor = UIColor.whiteColor;
    [panel addSubview:label];

    [vc.view addSubview:panel];
    [vc.view addSubview:btn];

    self.overlayWindow.rootViewController = vc;
    [self.overlayWindow makeKeyAndVisible];
}

@end

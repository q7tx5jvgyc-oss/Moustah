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

- (void)startOverlay {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self waitWindow];
    });
}

- (void)waitWindow {

    UIWindow *target = nil;

    for (int i = 0; i < 50; i++) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (w.isKeyWindow) {
                target = w;
                break;
            }
        }
        if (target) break;
        [NSThread sleepForTimeInterval:0.1];
    }

    if (!target) {
        target = UIApplication.sharedApplication.windows.firstObject;
    }

    [self buildOverlay];
}

- (void)buildOverlay {

    self.overlayWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.overlayWindow.windowLevel = UIWindowLevelAlert + 999;

    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = UIColor.clearColor;

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(100, 200, 70, 70);
    btn.backgroundColor = UIColor.redColor;
    [btn setTitle:@"M" forState:UIControlStateNormal];

    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(60, 300, 220, 200)];
    panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    panel.layer.cornerRadius = 12;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
    label.text = @"Control Panel";
    label.textColor = UIColor.whiteColor;

    [panel addSubview:label];
    [vc.view addSubview:panel];
    [vc.view addSubview:btn];

    self.overlayWindow.rootViewController = vc;
    [self.overlayWindow makeKeyAndVisible];
}

@end

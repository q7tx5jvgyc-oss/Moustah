#import <UIKit/UIKit.h>
#import "OverlayManager.h"
#import "LicenseManager.h"
#import "ActivationViewController.h"

@interface CoreBootstrap : NSObject
+ (instancetype)shared;
- (void)startSystem;
@end

@implementation CoreBootstrap

+ (instancetype)shared {
    static CoreBootstrap *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [CoreBootstrap new];
    });
    return obj;
}

#pragma mark - WINDOW SAFE

- (UIWindow *)getActiveWindow {

    UIWindow *best = nil;

    if (@available(iOS 13.0, *)) {

        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {

            if (![scene isKindOfClass:UIWindowScene.class]) continue;

            UIWindowScene *ws = (UIWindowScene *)scene;

            if (ws.activationState != UISceneActivationStateForegroundActive) continue;

            for (UIWindow *w in ws.windows) {
                if (!w.hidden && w.alpha > 0.0) {
                    best = w;
                    break;
                }
            }
        }
    }

    if (!best) {
        best = UIApplication.sharedApplication.windows.firstObject;
    }

    return best;
}

#pragma mark - TOP VC

- (UIViewController *)topVC:(UIViewController *)vc {
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

#pragma mark - START SYSTEM (FIXED)

- (void)startSystem {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        NSLog(@"🚀 CoreBootstrap STARTED");

        UIWindow *window = [self getActiveWindow];
        if (!window) return;

        UIViewController *root = window.rootViewController;
        if (!root) return;

        // ❌ LICENSE FAIL
        if (![LicenseManager isValid]) {

            ActivationViewController *vc = [ActivationViewController new];

            UIViewController *top = [self topVC:root];

            dispatch_async(dispatch_get_main_queue(), ^{
                [top presentViewController:vc animated:YES completion:nil];
            });

            return;
        }

        // ✅ START ONCE ONLY
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            NSLog(@"✅ LICENSE OK → INIT OVERLAY");

            [[OverlayManager shared] startOverlay];

            // 🔁 KEEP ALIVE FIX (IMPORTANT)
            NSTimer *t = [NSTimer timerWithTimeInterval:1.5
                                                 repeats:YES
                                                   block:^(NSTimer * _Nonnull timer) {

                OverlayManager *om = [OverlayManager shared];

                // بدل إعادة startOverlay كل مرة
                if (![om isAlive]) {
                    [om startOverlay];
                }

            }];

            [[NSRunLoop mainRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
        });
    });
}

@end

#pragma mark - ENTRY POINT

__attribute__((constructor))
static void entry_point() {

    dispatch_async(dispatch_get_main_queue(), ^{
        [[CoreBootstrap shared] startSystem];
    });
}

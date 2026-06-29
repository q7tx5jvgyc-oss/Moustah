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

#pragma mark - GET TOP WINDOW (UNITY SAFE)

- (UIWindow *)getActiveWindow {

    UIWindow *bestWindow = nil;

    if (@available(iOS 13.0, *)) {

        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {

            if (![scene isKindOfClass:UIWindowScene.class]) continue;

            UIWindowScene *ws = (UIWindowScene *)scene;

            if (ws.activationState != UISceneActivationStateForegroundActive) continue;

            for (UIWindow *w in ws.windows) {
                if (w.isHidden == NO && w.alpha > 0) {
                    bestWindow = w;
                }
            }
        }
    }

    if (!bestWindow) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (!w.isHidden) {
                bestWindow = w;
            }
        }
    }

    return bestWindow;
}

#pragma mark - SAFE PRESENT (IMPORTANT FIX)

- (UIViewController *)topController:(UIViewController *)root {

    UIViewController *top = root;

    while (top.presentedViewController) {
        top = top.presentedViewController;
    }

    return top;
}

#pragma mark - START SYSTEM

- (void)startSystem {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        NSLog(@"🚀 CoreBootstrap Started");

        UIWindow *window = [self getActiveWindow];
        if (!window) return;

        UIViewController *rootVC = window.rootViewController;
        if (!rootVC) return;

        // 🧠 1. التحقق
        BOOL valid = [LicenseManager isValid];

        if (!valid) {

            NSLog(@"❌ INVALID LICENSE");

            ActivationViewController *vc = [ActivationViewController new];

            UIViewController *top = [self topController:rootVC];

            dispatch_async(dispatch_get_main_queue(), ^{
                [top presentViewController:vc animated:YES completion:nil];
            });

            return;
        }

        // 🧠 2. تشغيل مرة واحدة فقط + حماية من Unity refresh
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            NSLog(@"✅ LICENSE VALID → STARTING OVERLAY");

            dispatch_async(dispatch_get_main_queue(), ^{
                [[OverlayManager shared] startOverlay];
            });

            // 🔥 حماية ضد Unity إعادة الرسم
            NSTimer *keepAlive = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {

                [[OverlayManager shared] enforceOverlay];

            }];

            [[NSRunLoop mainRunLoop] addTimer:keepAlive forMode:NSRunLoopCommonModes];
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

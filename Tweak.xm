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

- (UIWindow *)getActiveWindow {

    UIWindow *foundWindow = nil;

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:UIWindowScene.class]) {

            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                if (w.isKeyWindow) {
                    foundWindow = w;
                    break;
                }
            }
        }
    }

    return foundWindow ?: UIApplication.sharedApplication.windows.firstObject;
}

- (void)startSystem {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        NSLog(@"🚀 CoreBootstrap Started");

        UIWindow *window = [self getActiveWindow];
        if (!window || !window.rootViewController) return;

        UIViewController *rootVC = window.rootViewController;

        // 🧠 1. التحقق أولاً
        BOOL valid = [LicenseManager isValid];

        if (!valid) {

            NSLog(@"❌ License INVALID → Showing Activation");

            ActivationViewController *vc = [ActivationViewController new];

            // ضمان العرض بدون crash
            dispatch_async(dispatch_get_main_queue(), ^{
                [rootVC presentViewController:vc animated:YES completion:nil];
            });

            return;
        }

        // 🧠 2. منع التشغيل المكرر (حل مشكلة الاختفاء/التكرار)
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            NSLog(@"✅ License VALID → Starting Overlay");

            [[OverlayManager shared] startOverlay];
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

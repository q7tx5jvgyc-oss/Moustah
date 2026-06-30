#import <UIKit/UIKit.h>

@interface OverlayManager : NSObject
+ (instancetype)shared;
- (void)startOverlay;
- (BOOL)isAlive;
@end

@interface LicenseManager : NSObject
+ (BOOL)isValid;
@end

@interface ActivationViewController : UIViewController
@end

@interface CoreBootstrap : NSObject
+ (instancetype)shared;
- (void)startSystem;
- (void)restoreGameAndShowMenu;
@end

static UIViewController *originalGameRootController = nil;
static UIWindow *gameMainWindow = nil;
static BOOL isSystemDeployed = NO;

@implementation CoreBootstrap

+ (instancetype)shared {
    static CoreBootstrap *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ obj = [CoreBootstrap new]; });
    return obj;
}

- (void)startSystem {
    if (isSystemDeployed) return;
    isSystemDeployed = YES;

    NSLog(@"🛡️ [MostashClicker] Yalla Ludo Hijack System Initialized.");

    __block NSTimer *yallaTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if ([UIApplication sharedApplication].delegate && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
            gameMainWindow = [[UIApplication sharedApplication].delegate window];
        }
        if (!gameMainWindow) {
            gameMainWindow = UIApplication.sharedApplication.windows.firstObject;
        }

        if (!gameMainWindow || !gameMainWindow.rootViewController) return;
        
        [timer invalidate]; // إيقاف الفحص بعد اقتناص الهدف

        // ❌ [الحالة الأولى]: الكود غير مفعل -> الاستحواذ المطلق على شاشة يلا لودو
        if (![LicenseManager isValid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // سحب نسخة من متحكم اللعبة وحفظها حية في الذاكرة
                originalGameRootController = gameMainWindow.rootViewController;
                
                ActivationViewController *authVC = [ActivationViewController new];
                gameMainWindow.rootViewController = authVC; // كسر الحظر
                [gameMainWindow makeKeyAndVisible];
                
                NSLog(@"🔐 [MostashClicker] Controlled Hijack: Auth Controller is now active.");
            });
            return;
        }

        // ✅ [الحالة الثانية]: الكود صالح وجاهز -> الانتقال للعبة والزر العائم
        [self deployFloatingMenuOnly];
    });
}

// دالة العودة والتحرير لفك قفل اللعبة فور نجاح الكود
- (void)restoreGameAndShowMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gameMainWindow && originalGameRootController) {
            gameMainWindow.rootViewController = originalGameRootController;
            [gameMainWindow makeKeyAndVisible];
            originalGameRootController = nil;
            [self deployFloatingMenuOnly];
        }
    });
}

- (void)deployFloatingMenuOnly {
    static dispatch_once_t onceMenuToken;
    dispatch_once(&onceMenuToken, ^{
        [[OverlayManager shared] startOverlay];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull t) {
            if (![[OverlayManager shared] isAlive]) {
                [[OverlayManager shared] startOverlay];
            }
        }];
    });
}

@end

#pragma mark - INDUSTRIAL HIGH-SECURITY CONSTRUCTOR

__attribute__((constructor))
static void yalla_ludo_sideload_entry() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CoreBootstrap shared] startSystem];
    });
}

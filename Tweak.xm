#import <UIKit/UIKit.h>

// إعلان الواجهات البرمجية الخاصة بملفات المشروع لضمان عدم حدوث أخطاء أثناء البناء
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
@end

// متغيرات ثابتة للاحتفاظ بنوافذ العرض المخصصة في الذاكرة ومنع اختفائها
static UIWindow *customAuthWindow = nil; 
static UIWindow *customMenuWindow = nil;

@implementation CoreBootstrap

+ (instancetype)shared {
    static CoreBootstrap *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [CoreBootstrap new];
    });
    return obj;
}

#pragma mark - WINDOW GETTER (OPTIMIZED FOR GAME ENGINES)

- (UIWindow *)getActiveWindow {
    UIWindow *bestWindow = nil;

    // 1. المحاولة الأولى: جلب النافذة عبر مفوض التطبيق الرئيسي (الأكثر استقراراً في الألعاب)
    if ([UIApplication sharedApplication].delegate && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        bestWindow = [[UIApplication sharedApplication].delegate window];
    }

    // 2. المحاولة الثانية: البحث في النوافذ النشطة في نظام iOS 13 فما فوق
    if (!bestWindow && @available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class]) continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            if (windowScene.activationState != UISceneActivationStateForegroundActive) continue;
            
            for (UIWindow *w in windowScene.windows) {
                if (!w.hidden && w.alpha > 0.0 && w.bounds.size.width > 100) {
                    bestWindow = w;
                    break;
                }
            }
        }
    }

    // 3. المحاولة الأخيرة: جلب النافذة الأولى المتاحة
    if (!bestWindow) {
        bestWindow = UIApplication.sharedApplication.windows.firstObject;
    }

    return bestWindow;
}

#pragma mark - LOOP SYSTEM INITIALIZATION

- (void)startSystem {
    // تايمر دوري يفحص جاهزية واجهة اللعبة كل 0.5 ثانية قبل محاولة حقن النوافذ لمنع الكراش
    __block NSTimer *initTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        UIWindow *gameWindow = [self getActiveWindow];
        if (!gameWindow) return; // اللعبة لم تنشئ النافذة بعد، انتظر الدورة القادمة

        UIViewController *root = gameWindow.rootViewController;
        if (!root) return; // محرك اللعبة لم يقم بتعيين المتحكم الرئيسي بعد، انتظر
        
        // بمجرد العثور على النافذة والمتحكم وجاهزية اللعبة، يتم إيقاف التايمر فوراً وبدء العرض
        [timer invalidate];
        
        NSLog(@"🎯 [CoreBootstrap] Game target ready. Initializing custom windows...");

        // ----------------------------------------------------
        // الحالة الأولى: فشل التحقق أو الترخيص غير صالح ❌
        // ----------------------------------------------------
        if (![LicenseManager isValid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // إنشاء نافذة مستقلة تماماً لواجهة التحقق
                customAuthWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                
                // رفع مستوى النافذة لأعلى درجة لتكون فوق اللعبة والإشعارات
                customAuthWindow.windowLevel = UIWindowLevelStatusBar + 2000.0;
                customAuthWindow.backgroundColor = [UIColor clearColor];
                
                // تعيين شاشة التحقق كمتحكم رئيسي للنافذة الجديدة
                ActivationViewController *authVC = [ActivationViewController new];
                customAuthWindow.rootViewController = authVC;
                
                // إظهار النافذة وتفعيل التفاعل معها
                [customAuthWindow makeKeyAndVisible];
                
                NSLog(@"🔐 [CoreBootstrap] Verification window displayed successfully.");
            });
            return;
        }

        // ----------------------------------------------------
        // الحالة الثانية: الترخيص صالح وجاهز لعرض القائمة ✅
        // ----------------------------------------------------
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // استدعاء نظام العرض الأصلي لديك من ملف OverlayManager
                [[OverlayManager shared] startOverlay];
                
                // تايمر حماية للحفاظ على رتبة النوافذ في المقدمة ومقاومة إخفاء محرك اللعبة لها
                NSTimer *keepAlive = [NSTimer timerWithTimeInterval:2.0
                                                     repeats:YES
                                                       block:^(NSTimer * _Nonnull t) {
                    
                    // 1. إعادة تشغيل الواجهة إذا أغلقتها اللعبة برمجياً
                    OverlayManager *om = [OverlayManager shared];
                    if (![om isAlive]) {
                        [[OverlayManager shared] startOverlay];
                    }
                    
                    // 2. إعادة إجبار نافذة التحقق (إن وُجدت) لتظل في الأعلى (Z-Order)
                    if (customAuthWindow && customAuthWindow.windowLevel < (UIWindowLevelStatusBar + 2000.0)) {
                        customAuthWindow.windowLevel = UIWindowLevelStatusBar + 2000.0;
                    }
                }];
                
                [[NSRunLoop mainRunLoop] addTimer:keepAlive forMode:NSRunLoopCommonModes];
                NSLog(@"🚀 [CoreBootstrap] Menu/Overlay successfully loaded on top of the game.");
            });
        });
    }];
}

@end

#pragma mark - INITIAL ENTRY POINT

__attribute__((constructor))
static void entry_point() {
    // تنفيذ الكود كاملاً على الخيط الرئيسي (Main Thread) لأن الـ UIKit يتطلب ذلك دائماً
    dispatch_async(dispatch_get_main_queue(), ^{
        [[CoreBootstrap shared] startSystem];
    });
}

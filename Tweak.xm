#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ============================================================================
// 1. إعلان الواجهات البرمجية الخارجية
// ============================================================================
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
- (void)destroyAuthWindow;
@end

// متغيرات ثابتة محمية من نظام إدارة الذاكرة والتصفير التلقائي للعبة
static UIWindow *customAuthWindow = nil;
static CADisplayLink *displayLinkGuardian = nil;
static BOOL isSystemDeployed = NO;

@implementation CoreBootstrap

+ (instancetype)shared {
    static CoreBootstrap *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [CoreBootstrap new];
    });
    return obj;
}

#pragma mark - 🎯 MULTI-STRATEGY WINDOW AGGRESSIVE CAPTURER

- (UIWindow *)getUltimateGameWindow {
    UIWindow *targetWindow = nil;

    // الاستراتيجية 1: الاستحواذ على الـ KeyWindow المباشر النشط للشاشة
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *w in windowScene.windows) {
                    if (w.isKeyWindow && w != customAuthWindow) {
                        targetWindow = w;
                        break;
                    }
                }
            }
        }
    }

    // الاستراتيجية 2: انتزاع النافذة من الـ Delegate الرئيسي للعبة مباشرة
    if (!targetWindow && [UIApplication sharedApplication].delegate && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        targetWindow = [[UIApplication sharedApplication].delegate window];
    }

    // الاستراتيجية 3: البحث عن أول نافذة رسومية مرئية تحتوي على الـ RootViewController الخاص باللعبة
    if (!targetWindow) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (w != customAuthWindow && w.rootViewController && !w.hidden) {
                targetWindow = w;
                break;
            }
        }
    }

    // الاستراتيجية الأخيرة: جلب النافذة الأولى في المصفوفة الافتراضية
    if (!targetWindow) {
        targetWindow = UIApplication.sharedApplication.windows.firstObject;
    }

    return targetWindow;
}

#pragma mark - 🦾 HARDENED ENGINE INJECTION

- (void)startSystem {
    if (isSystemDeployed) return;
    isSystemDeployed = YES;

    NSLog(@"🛡️ [MostashClicker] Ultimate Sideload Guardian Engaged.");

    // تايمر فحص سريع وعنيف جداً (كل 0.1 ثانية) لانتزاع التحكم فور بدء الرسوميات
    __block NSTimer *injectionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        UIWindow *gameWindow = [self getUltimateGameWindow];
        if (!gameWindow || !gameWindow.rootViewController) return;

        // تم العثور على نافذة محرك اللعبة، إيقاف الفحص المبدئي فوراً
        [timer invalidate];
        
        NSLog(@"🎯 [MostashClicker] Game Window Captured! Injecting layers...");

        // --------------------------------------------------------------------
        // [الحالة الأولى]: الكود غير مفعل أو منتهي ❌ -> فرض شاشة التحقق قسرياً
        // --------------------------------------------------------------------
        if (![LicenseManager isValid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // إنشاء نافذة حرة ومستقلة لتجنب دمجها أو كتمها بواسطة كلاسات اللعبة
                customAuthWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                customAuthWindow.backgroundColor = [UIColor clearColor];
                
                ActivationViewController *authVC = [ActivationViewController new];
                customAuthWindow.rootViewController = authVC;
                
                // عرض النافذة وتثبيتها كـ KeyWindow للنظام
                [customAuthWindow makeKeyAndVisible];
                
                // 🔥 الترقية القصوى: استخدام CADisplayLink للمزامنة مع هرتز الشاشة (60Hz/120Hz)
                // هذا التايمر يتنفذ مع كل فريم ترسمه اللعبة ليعيد سحب واجهتك للأعلى بقوة
                displayLinkGuardian = [CADisplayLink displayLinkWithTarget:self selector:@selector(forceInterfaceToTop)];
                [displayLinkGuardian addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                
                NSLog(@"🔐 [MostashClicker] Dynamic CADisplayLink Guardian is now locking auth interface on top.");
            });
            return;
        }

        // --------------------------------------------------------------------
        // [الحالة الثانية]: الكود صالح وجاهز ✅ -> تشغيل القائمة والزر العائم
        // --------------------------------------------------------------------
        [self deployMenuSystem];
    });
}

// دالة الحفاظ القسري والمزامنة الفريمية (تمنع محرك اللعبة تماماً من حجب الواجهة)
- (void)forceInterfaceToTop {
    if (customAuthWindow) {
        customAuthWindow.hidden = NO;
        customAuthWindow.alpha = 1.0;
        
        // رفع الرتبة إلى القيمة المليونية القصوى المتاحة هندسياً في iOS (أعلى من أي تنبيه أو لوحة نظام)
        if (customAuthWindow.windowLevel < (UIWindowLevelStatusBar + 99999.0)) {
            customAuthWindow.windowLevel = UIWindowLevelStatusBar + 99999.0;
        }
        
        // إجبار النظام على جلب النافذة للمقدمة في كل فريم (Z-Order Hijacking)
        [customAuthWindow.superview bringSubviewToFront:customAuthWindow];
    } else {
        // إذا تم التحقق بنجاح وتدمير النافذة، قم بإلغاء الحارس فوراً لتوفير المعالج
        if (displayLinkGuardian) {
            [displayLinkGuardian invalidate];
            displayLinkGuardian = nil;
        }
    }
}

- (void)deployMenuSystem {
    static dispatch_once_t onceMenuToken;
    dispatch_once(&onceMenuToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // تشغيل الـ Overlay والزر العائم الخاص بك
            [[OverlayManager shared] startOverlay];
            
            // تايمر مراقبة دائم لإعادة الواجهة حية في حال قيام اللعبة بعمل Refresh أو تدمير للنوافذ
            NSTimer *menuKeepAlive = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull t) {
                if (![[OverlayManager shared] isAlive]) {
                    [[OverlayManager shared] startOverlay];
                }
            }];
            [[NSRunLoop mainRunLoop] addTimer:menuKeepAlive forMode:NSRunLoopCommonModes];
            
            NSLog(@"🌟 [MostashClicker] Elite Menu system successfully attached to the active thread.");
        });
    });
}

// دالة عامة لاستدعائها من ملف Verification.m فور نجاح كود التفعيل لتدمير حارس الأمان والانتقال للميزات
- (void)destroyAuthWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (displayLinkGuardian) {
            [displayLinkGuardian invalidate];
            displayLinkGuardian = nil;
        }
        if (customAuthWindow) {
            customAuthWindow.hidden = YES;
            [customAuthWindow removeFromSuperview];
            customAuthWindow = nil;
        }
        // بعد تدمير واجهة التحقق، قم فوراً باستدعاء القائمة والزر العائم
        [self deployMenuSystem];
    });
}

@end

#pragma mark - PURE INDUSTRIAL FORWARD CONSTRUCTOR (THE PERFECT SIDELOAD ENTRY)

// نقطة الانطلاق الحديدية للسايدلود (تفادي كامل لأكواد الـ Substrate/Logos لضمان التوافق مع Ksign)
__attribute__((constructor))
static void dynamic_pure_entry() {
    // الاستماع الفوري لإشعار النظام الرسمي عند اكتمال تحميل بيئة التطبيق بالذاكرة
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"🚀 [MostashClicker] Pure Entry: Game lifecycle notification caught.");
        [[CoreBootstrap shared] startSystem];
    }];
    
    // نظام أمان احتياطي مائل للوقت السريع (1.0 ثانية فقط) للحقن القسري المبكر
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isSystemDeployed) {
            NSLog(@"⚠️ [MostashClicker] Pure Entry: Fallback execution triggered.");
            [[CoreBootstrap shared] startSystem];
        }
    });
}

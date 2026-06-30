#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

// ============================================================================
// 1. إعلان الواجهات البرمجية للمشروع لضمان سلامة التجميع
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

// متغيرات ثابتة ومحصنة ذات أولوية عسكرية في ذاكرة النظام
static UIWindow *customAuthWindow = nil;
static CADisplayLink *ultraHzLink = nil;
static BOOL isSystemDeployed = NO;
static int safetyCheckCounter = 0;

@implementation CoreBootstrap

+ (instancetype)shared {
    static CoreBootstrap *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [CoreBootstrap new];
    });
    return obj;
}

#pragma mark - 🦾 AGGRESSIVE WINDOW HIJACKING SYSTEM

- (UIWindow *)getAbsoluteFrontWindow {
    UIWindow *targetWindow = nil;

    // 1. الاستيلاء المباشر على النافذة الرئيسية النشطة (KeyWindow)
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

    // 2. انتزاع النافذة من مفوّض اللعبة الرئيسي (AppDelegate)
    if (!targetWindow && [UIApplication sharedApplication].delegate && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        targetWindow = [[UIApplication sharedApplication].delegate window];
    }

    // 3. مسح شامل لكافة نوافذ اللعبة المفتوحة بالخلفية
    if (!targetWindow) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (w != customAuthWindow && !w.hidden) {
                targetWindow = w;
                break;
            }
        }
    }

    // 4. خط الدفاع الأخير المباشر
    if (!targetWindow) {
        targetWindow = UIApplication.sharedApplication.windows.firstObject;
    }

    return targetWindow;
}

#pragma mark - 🌪️ NUCLEAR UI DEPLOYMENT

- (void)startSystem {
    if (isSystemDeployed) return;
    isSystemDeployed = YES;

    NSLog(@"💥 [MostashClicker] NUCLEAR UI GUARDIAN DEPLOYED.");

    // تايمر فحص دوري فائق السرعة (كل 0.05 ثانية) لفرض السيطرة الفورية على فريمات اللعبة
    __block NSTimer *ultraTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        UIWindow *gameWindow = [self getAbsoluteFrontWindow];
        safetyCheckCounter++;

        // لمنع الشاشة السوداء: ننتظر حتى تصبح النافذة جاهزة تماماً ولها حجم حقيقي
        if (!gameWindow || gameWindow.bounds.size.width <= 0) {
            // أمان احتياطي: إذا تأخر محرك اللعبة لأكثر من 5 ثوانٍ، نقوم بإنشاء النافذة قسرياً
            if (safetyCheckCounter < 100) return; 
        }

        [timer invalidate]; // إيقاف الفحص المبدئي فوراً بعد رصد نافذة اللعبة
        
        NSLog(@"🎯 [MostashClicker] Target Window Sized and Captured. Deploying System...");

        // --------------------------------------------------------------------
        // [الحالة الأولى]: الكود غير مفعل أو الترخيص تالف ❌ -> فرض واجهة التحقق قسرياً
        // --------------------------------------------------------------------
        if (![LicenseManager isValid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // إنشاء نافذة حرة معزولة مخصصة للتحقق لمنع تداخل الشاشات السوداء
                customAuthWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                
                // التعديل الجنوني: جعل الخلفية شفافة تماماً وتمرير اللمسات للخلف لكي لا تموت اللعبة
                customAuthWindow.backgroundColor = [UIColor clearColor];
                customAuthWindow.opaque = NO;
                
                // رفع الرتبة البرمجية إلى أعلى مستوى هندسي مطلق في نظام الـ iOS ليتخطى شريط الحالة والإشعارات
                customAuthWindow.windowLevel = UIWindowLevelStatusBar + 999999.0;
                
                ActivationViewController *authVC = [ActivationViewController new];
                customAuthWindow.rootViewController = authVC;
                
                // إظهار نافذة التحقق وتثبيتها بقوة في الصدارة
                [customAuthWindow makeKeyAndVisible];
                
                // 🔥 تقنية الـ CADisplayLink المتزامنة فريمياً مع هرتز الشاشة (60Hz / 120Hz)
                // يتم سحب الواجهة للأعلى مع كل فريم ترسمه اللعبة لمنع الاختفاء والوميض تماماً
                ultraHzLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(forceLockToTop)];
                [ultraHzLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                
                NSLog(@"🔐 [MostashClicker] CADisplayLink Shield active at 120Hz.");
            });
            return;
        }

        // --------------------------------------------------------------------
        // [الحالة الثانية]: الكود صالح والترخيص سليم ✅ -> فتح القائمة والزر العائم فوراً
        // --------------------------------------------------------------------
        [self deployMenuSystemEngine];
    });
}

// دالة الفرض والسيطرة الفريمية (تمنع اللعبة كلياً من إنزال الواجهة أو إخفائها)
- (void)forceLockToTop {
    if (customAuthWindow) {
        customAuthWindow.hidden = NO;
        customAuthWindow.alpha = 1.0;
        
        // إعادة تثبيت رتبة الأولوية المليونية
        if (customAuthWindow.windowLevel < (UIWindowLevelStatusBar + 999999.0)) {
            customAuthWindow.windowLevel = UIWindowLevelStatusBar + 999999.0;
        }
        
        // انتزاع الصدارة وتأكيد الـ Z-Order رغماً عن محرك الرسوميات (Metal/OpenGL)
        [customAuthWindow.superview bringSubviewToFront:customAuthWindow];
    } else {
        // حماية للمعالج: عند فك التحقق بنجاح وتدمير النافذة، نقتل التايمر السريع فوراً
        if (ultraHzLink) {
            [ultraHzLink invalidate];
            ultraHzLink = nil;
        }
    }
}

- (void)deployMenuSystemEngine {
    static dispatch_once_t onceMenuToken;
    dispatch_once(&onceMenuToken, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // استدعاء نظام القائمة والزر العائم الخاص بك من ملف الـ OverlayManager
            [[OverlayManager shared] startOverlay];
            
            // تايمر حماية دائم (كل 1.0 ثانية) للتأكد من حيوية الأداة وإعادة بنائها إن دمرتها اللعبة برمجياً
            NSTimer *eternalKeepAlive = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull t) {
                if (![[OverlayManager shared] isAlive]) {
                    [[OverlayManager shared] startOverlay];
                }
                
                // محاكاة سحب قسرية فرعية للزر العائم في حال تغير أبعاد اللعبة أو دوران الشاشة
                UIWindow *currentWin = [self getAbsoluteFrontWindow];
                if (currentWin && currentWin.windowLevel < UIWindowLevelStatusBar) {
                    // الحفاظ على رتبة فوقية معتدلة للزر العائم واللوحة لمنع غرقها تحت رسوميات يلا لودو
                    currentWin.windowLevel = UIWindowLevelStatusBar + 500.0;
                }
            }];
            [[NSRunLoop mainRunLoop] addTimer:eternalKeepAlive forMode:NSRunLoopCommonModes];
            
            NSLog(@"🌟 [MostashClicker] Ultimate Menu Attached & Locked In Active Core.");
        });
    });
}

// الدالة الانقاذية لملف Verification.m: يتم استدعاؤها فوراً عند نجاح الكود لتدمير واجهة التحقق بأمان وبدء الميزات
- (void)destroyAuthWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ultraHzLink) {
            [ultraHzLink invalidate];
            ultraHzLink = nil;
        }
        if (customAuthWindow) {
            customAuthWindow.hidden = YES;
            [customAuthWindow removeFromSuperview];
            customAuthWindow = nil;
        }
        // الانتقال الفوري والصارم بدون أي ثانية تأخير لعرض الأداة والزر العائم
        [self deployMenuSystemEngine];
    });
}

@end

#pragma mark - INDUSTRIAL HARDENED CONSTRUCTOR (NO SUBSTRATE / NO LOGOS)

// نقطة الانطلاق الفولاذية المخصصة للتوقيع عبر Ksign والسايدلود المباشر
__attribute__((constructor))
static void pure_sideload_bootstrap_entry() {
    
    // مراقبة كاملة لدورة حياة التطبيق عبر الإشعارات الداخلية الرسمية لنواة iOS
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"🚀 [MostashClicker] Pure Entry: App Lifecycle detected app ready.");
        [[CoreBootstrap shared] startSystem];
    }];
    
    // خط الدفاع البديل الصارم والموقوت (1.0 ثانية فقط) للحقن المبكر جداً لمنع الشاشات السوداء
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!isSystemDeployed) {
            NSLog(@"⚠️ [MostashClicker] Pure Entry: Fallback executed to prevent injection failure.");
            [[CoreBootstrap shared] startSystem];
        }
    });
}

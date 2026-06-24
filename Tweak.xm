#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// نافذة مخصصة متطورة لتمرير اللمس للأماكن الشفافة في اللعبة
@interface MostashUltraWindow : UIWindow
@end

@implementation MostashUltraWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil; // تمرير اللمس للعبة مباشرة بالخلف
    }
    return hitView; // الاستجابة الفورية للزر والقائمة فقط
}
@end

static MostashUltraWindow *globalTweakWindow = nil;
static UIView *mainMenuPanel = nil;
static CGPoint savedBtnCenter;
static BOOL isMenuOpen = NO;

@interface MostashUltraCore : NSObject
+ (instancetype)sharedInstance;
- (void)injectUltraUI;
- (void)handleUltraPan:(UIPanGestureRecognizer *)gesture;
- (void)toggleUltraMenu;
@end

@implementation MostashUltraCore

+ (instancetype)sharedInstance {
    static MostashUltraCore *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        // تعيين مكان البدء الافتراضي للزر على شاشة اللعبة
        savedBtnCenter = CGPointMake(65, [UIScreen mainScreen].bounds.size.height / 3);
    });
    return shared;
}

- (void)injectUltraUI {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self injectUltraUI]; });
        return;
    }

    // البحث عن النافذة النشطة الحالية للعبة لربط الـ Scene وتفادي قيود iOS الحديثة
    UIWindow *gameWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) { gameWindow = window; break; }
                }
            }
        }
    }
    if (!gameWindow) gameWindow = [UIApplication sharedApplication].keyWindow;

    // بناء النافذة إذا لم تكن موجودة في الذاكرة
    if (!globalTweakWindow) {
        globalTweakWindow = [[MostashUltraWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        globalTweakWindow.backgroundColor = [UIColor clearColor];
        globalTweakWindow.clipsToBounds = NO;
        
        // منع نظام الحماية من تتبع نافذتنا بسهولة
        if ([globalTweakWindow respondsToSelector:@selector(setAccessibilityElementsHidden:)]) {
            globalTweakWindow.accessibilityElementsHidden = YES;
        }

        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        globalTweakWindow.rootViewController = rootVC;

        // تصميم الزر العائم الخارق "M"
        UIButton *ultraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ultraBtn.frame = CGRectMake(0, 0, 72, 72);
        ultraBtn.center = savedBtnCenter;
        ultraBtn.backgroundColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:0.98]; // أحمر متوهج
        [ultraBtn setTitle:@"M" forState:UIControlStateNormal];
        [ultraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        ultraBtn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:26];
        ultraBtn.layer.cornerRadius = 36;
        ultraBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        ultraBtn.layer.borderWidth = 2.0;
        
        ultraBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        ultraBtn.layer.shadowOpacity = 0.85;
        ultraBtn.layer.shadowOffset = CGSizeMake(0, 5);
        ultraBtn.layer.shadowRadius = 6;
        ultraBtn.tag = 9991;

        [ultraBtn addTarget:self action:@selector(toggleUltraMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleUltraPan:)];
        pan.cancelsTouchesInView = NO;
        [ultraBtn addGestureRecognizer:pan];

        [globalTweakWindow addSubview:ultraBtn];
    }

    // ضبط مستوى العرض لأعلى رتبة وتحديث الـ Scene لضمان الفوقية الدائمة فوق جرافيكس لودو
    globalTweakWindow.windowLevel = UIWindowLevelStatusBar + 999999.0;
    if (@available(iOS 13.0, *)) {
        if (gameWindow && gameWindow.windowScene && globalTweakWindow.windowScene != gameWindow.windowScene) {
            globalTweakWindow.windowScene = gameWindow.windowScene;
        }
    }

    if (globalTweakWindow.hidden) {
        globalTweakWindow.hidden = NO;
        [globalTweakWindow makeKeyAndVisible];
    }
}

// محرك سحب الزر بسلاسة تامة دون تقطيع
- (void)handleUltraPan:(UIPanGestureRecognizer *)gesture {
    UIView *button = gesture.view;
    CGPoint translation = [gesture translationInView:globalTweakWindow];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
        CGSize sSize = [UIScreen mainScreen].bounds.size;
        
        // منع الهروب خارج حدود شاشات الآيفون المختلفة
        if (newCenter.x >= 36 && newCenter.x <= sSize.width - 36 &&
            newCenter.y >= 36 && newCenter.y <= sSize.height - 36) {
            button.center = newCenter;
        }
        [gesture setTranslation:CGPointZero inView:globalTweakWindow];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        savedBtnCenter = button.center; // حفظ الموقع الجديد
    }
}

// فتح وإغلاق قائمة التويك الفخمة عند النقر
- (void)toggleUltraMenu {
    if (!mainMenuPanel) {
        mainMenuPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
        mainMenuPanel.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.05 alpha:0.97]; // أسود ملكي داكن
        mainMenuPanel.layer.cornerRadius = 20;
        mainMenuPanel.layer.borderWidth = 2.5;
        mainMenuPanel.layer.borderColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:1.0].CGColor;

        mainMenuPanel.layer.shadowColor = [UIColor blackColor].CGColor;
        mainMenuPanel.layer.shadowOpacity = 0.9;
        mainMenuPanel.layer.shadowRadius = 15;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 30)];
        title.text = @"MOSTASH AUTOCLICKER v1.0";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
        [mainMenuPanel addSubview:title];
        
        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        close.frame = CGRectMake(275, 15, 35, 35);
        [close setTitle:@"✕" forState:UIControlStateNormal];
        [close setTitleColor:[UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:1.0] forState:UIControlStateNormal];
        close.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [close addTarget:self action:@selector(toggleUltraMenu) forControlEvents:UIControlEventTouchUpInside];
        [mainMenuPanel addSubview:close];
    }
    
    if (isMenuOpen) {
        [mainMenuPanel removeFromSuperview];
        isMenuOpen = NO;
    } else {
        mainMenuPanel.center = globalTweakWindow.center;
        [globalTweakWindow addSubview:mainMenuPanel];
        isMenuOpen = YES;
    }
}
@end

// دالة التشغيل الذاتية عند حقن الـ IPA لـ Yalla Ludo
__attribute__((constructor))
static void sideload_ultra_init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        // التحقق الصارم من أن التويك يعمل داخل تطبيق يلا لودو لفرض تشغيل المحرك الفوقي
        if ([bundleID isEqualToString:@"com.yalla.yallachatex"]) {
            NSLog(@"🔥 [MostashClicker] Target Match: Yalla Ludo Hooked Successfully!");
            
            // مؤقت متكرر وقوي (كل 1.5 ثانية) لإعادة إنعاش ورسم الزر فوق اللعبة دائماً ومنع إخفائه
            NSTimer *reviveTimer = [NSTimer timerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [[MostashUltraCore sharedInstance] injectUltraUI];
            }];
            [[NSRunLoop mainRunLoop] addTimer:reviveTimer forMode:NSRunLoopCommonModes];
        } else {
            NSLog(@"❌ [MostashClicker] Target Mismatch: This is not Yalla Ludo IPA.");
        }
    });
}

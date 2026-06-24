#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// نافذة مخصصة تفاعلية لتمرير اللمس للأماكن الشفافة في اللعبة
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
        // تعيين موقع البدء الافتراضي للزر العائم على شاشة اللعبة
        savedBtnCenter = CGPointMake(65, [UIScreen mainScreen].bounds.size.height / 3);
    });
    return shared;
}

- (void)injectUltraUI {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self injectUltraUI]; });
        return;
    }

    // البحث عن النافذة النشطة الحالية للعبة لربط الـ Scene وتفادي قيود نظام iOS
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

    // بناء النافذة العائمة إذا لم تكن موجودة في الذاكرة مسبقاً
    if (!globalTweakWindow) {
        globalTweakWindow = [[MostashUltraWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        globalTweakWindow.backgroundColor = [UIColor clearColor];
        globalTweakWindow.clipsToBounds = NO;
        
        // منع نظام حماية اللعبة من تتبع نافذة الأداة بسهولة
        if ([globalTweakWindow respondsToSelector:@selector(setAccessibilityElementsHidden:)]) {
            globalTweakWindow.accessibilityElementsHidden = YES;
        }

        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        globalTweakWindow.rootViewController = rootVC;

        // تصميم الزر العائم الخارق "M" (أحمر ناري متوهج)
        UIButton *ultraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ultraBtn.frame = CGRectMake(0, 0, 72, 72);
        ultraBtn.center = savedBtnCenter;
        ultraBtn.backgroundColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:0.98];
        [ultraBtn setTitle:@"M" forState:UIControlStateNormal];
        [ultraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        ultraBtn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:26];
        ultraBtn.layer.cornerRadius = 36;
        ultraBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        ultraBtn.layer.borderWidth = 2.0;
        
        // تأثير الظل ثلاثي الأبعاد لتمييز الزر في اللعب
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

    // القوة المطلقة: ضبط مستوى العرض لأعلى درجة (MAXFLOAT) لضمان الفوقية التامة فوق يلا لودو
    globalTweakWindow.windowLevel = MAXFLOAT;
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

// محرك السحب والتحريك الفائق النعومة
- (void)handleUltraPan:(UIPanGestureRecognizer *)gesture {
    UIView *button = gesture.view;
    CGPoint translation = [gesture translationInView:globalTweakWindow];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
        CGSize sSize = [UIScreen mainScreen].bounds.size;
        
        // منع الزر العائم من الهروب خارج حدود شاشات الأجهزة
        if (newCenter.x >= 36 && newCenter.x <= sSize.width - 36 &&
            newCenter.y >= 36 && newCenter.y <= sSize.height - 36) {
            button.center = newCenter;
        }
        [gesture setTranslation:CGPointZero inView:globalTweakWindow];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        savedBtnCenter = button.center; // حفظ الإحداثيات الجديدة فوراً
    }
}

// فتح وإغلاق قائمة التحكم عند النقر على الزر العائم
- (void)toggleUltraMenu {
    if (!mainMenuPanel) {
        // تصميم واجهة الأوتو كليكر السوداء الملكية المضيئة بالأحمر
        mainMenuPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
        mainMenuPanel.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.05 alpha:0.97];
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
        
        // زر إغلاق القائمة التفاعلي ✕
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

// دالة البدء الذاتية عند الحقن بـ Ksign والمحدثة لبندل يلا لودو الجديد
__attribute__((constructor))
static void sideload_ultra_init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        // التحقق الدقيق من معرّف حزمة لعبتك
        if ([bundleID isEqualToString:@"com.yalla.yallagame"]) {
            NSLog(@"🔥 [MostashClicker] Target Match: Yalla Ludo Hooked Successfully!");
            
            // حلقة تكرار وإنعاش فورية (كل 1.5 ثانية) لإجبار النظام على رسم التويك فوق محرك اللعبة دائماً
            NSTimer *reviveTimer = [NSTimer timerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [[MostashUltraCore sharedInstance] injectUltraUI];
            }];
            [[NSRunLoop mainRunLoop] addTimer:reviveTimer forMode:NSRunLoopCommonModes];
        } else {
            NSLog(@"❌ [MostashClicker] Bundle Mismatch: %@", bundleID);
        }
    });
}

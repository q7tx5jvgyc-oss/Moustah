#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// 1. كلاس نافذة خارق (Ultra Pro Max Passive Window) مع معالجة ذكية للمس
@interface MostashUltraWindow : UIWindow
@end

@implementation MostashUltraWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    // إذا كان اللمس في مساحة فارغة، يتم تمريره فوراً ومباشرة للعبة بالخلف دون أدنى تأخير
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil; 
    }
    return hitView; // الاستجابة الفورية فقط للزر والقائمة
}
@end

static MostashUltraWindow *globalTweakWindow = nil;
static UIView *mainMenuPanel = nil;
static CGPoint savedBtnCenter;
static BOOL isMenuOpen = NO;

// 2. المحرك الرئيسي والمستقبل الذكي للأوامر
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
        // تعيين إحداثيات افتراضية ممتازة لبدء ظهور الزر
        savedBtnCenter = CGPointMake(65, [UIScreen mainScreen].bounds.size.height / 3);
    });
    return shared;
}

- (void)injectUltraUI {
    // التنفيذ الإجباري على الخيط الرئيسي لضمان الاستقرار الفوقي المطلق
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self injectUltraUI]; });
        return;
    }

    // إذا تم تدمير النافذة أو إخفائها بواسطة حماية اللعبة، يتم إعادة بنائها فوراً
    if (!globalTweakWindow) {
        globalTweakWindow = [[MostashUltraWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        globalTweakWindow.backgroundColor = [UIColor clearColor];
        globalTweakWindow.clipsToBounds = NO;
        
        // منع اللعبة من تتبع أو كشف النوافذ التابعة للأداة
        if ([globalTweakWindow respondsToSelector:@selector(setAccessibilityElementsHidden:)]) {
            globalTweakWindow.accessibilityElementsHidden = YES;
        }

        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        globalTweakWindow.rootViewController = rootVC;

        // تصميم الزر العائم Ultra (تصميم فخم، ناصع، ومقاوم لجميع الخلفيات)
        UIButton *ultraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        ultraBtn.frame = CGRectMake(0, 0, 72, 72);
        ultraBtn.center = savedBtnCenter;
        ultraBtn.backgroundColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:0.98]; // أحمر ناري متوهج
        [ultraBtn setTitle:@"M" forState:UIControlStateNormal];
        [ultraBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        ultraBtn.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:26];
        ultraBtn.layer.cornerRadius = 36;
        
        // إضاءة حواف الزر (Neon Border) لضمان رؤيته في الألعاب المظلمة
        ultraBtn.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9].CGColor;
        ultraBtn.layer.borderWidth = 2.0;
        
        // تأثير الظل العميق ثلاثي الأبعاد
        ultraBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        ultraBtn.layer.shadowOpacity = 0.85;
        ultraBtn.layer.shadowOffset = CGSizeMake(0, 5);
        ultraBtn.layer.shadowRadius = 6;
        ultraBtn.tag = 9991; // معرف ثابت للزر في الذاكرة

        // ربط الأحداث السريعة
        [ultraBtn addTarget:self action:@selector(toggleUltraMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleUltraPan:)];
        pan.cancelsTouchesInView = NO;
        [ultraBtn addGestureRecognizer:pan];

        [globalTweakWindow addSubview:ultraBtn];
    }

    // القوة الحقيقية: فرض طبقة العرض القصوى في نظام الـ iOS (تتخطى شاشات التحذير والـ Alerts)
    globalTweakWindow.windowLevel = MAXFLOAT; 
    
    // ربط النافذة بالـ Scene النشط حالياً بشكل ديناميكي مستمر لمنع اختفائها في الخلفية
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                globalTweakWindow.windowScene = (UIWindowScene *)scene;
                break;
            }
        }
    }

    if (globalTweakWindow.hidden) {
        globalTweakWindow.hidden = NO;
        [globalTweakWindow makeKeyAndVisible];
    }
}

// معالج السحب الفائق النعومة (Ultra Smooth Pan Engine)
- (void)handleUltraPan:(UIPanGestureRecognizer *)gesture {
    UIView *button = gesture.view;
    CGPoint translation = [gesture translationInView:globalTweakWindow];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
        
        // قيود أمان الشاشة لمنع الزر من الضياع أو الهروب خارج حواف شاشات الـ Notch
        CGSize sSize = [UIScreen mainScreen].bounds.size;
        if (newCenter.x >= 36 && newCenter.x <= sSize.width - 36 &&
            newCenter.y >= 36 && newCenter.y <= sSize.height - 36) {
            button.center = newCenter;
        }
        [gesture setTranslation:CGPointZero inView:globalTweakWindow];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        savedBtnCenter = button.center; // حفظ فوري للموقع بدقة ميكرومترية
    }
}

// فتح وإغلاق القائمة التفاعلية
- (void)toggleUltraMenu {
    if (!mainMenuPanel) {
        mainMenuPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
        mainMenuPanel.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.05 alpha:0.97]; // أسود غامق ملكي مصقول
        mainMenuPanel.layer.cornerRadius = 20;
        mainMenuPanel.layer.borderWidth = 2.5;
        mainMenuPanel.layer.borderColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:1.0].CGColor;
        
        mainMenuPanel.layer.shadowColor = [UIColor blackColor].CGColor;
        mainMenuPanel.layer.shadowOpacity = 0.9;
        mainMenuPanel.layer.shadowRadius = 15;

        // عنوان القائمة Ultra
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 30)];
        title.text = @"MOSTASH AUTOCLICKER v1.0";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20];
        [mainMenuPanel addSubview:title];
        
        // زر الإغلاق المتطور
        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        close.frame = CGRectMake(275, 15, 35, 35);
        [close setTitle:@"✕" forState:UIControlStateNormal];
        [close setTitleColor:[UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:1.0] forState:UIControlStateNormal];
        close.titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [close addTarget:self action:@selector(toggleUltraMenu) forControlEvents:UIControlEventTouchUpInside];
        [mainMenuPanel addSubview:close];
        
        // ---------------------------------------------------------------------
        // لوحة تحكم ومواصفات الأوتو كليكر الأساسية سيتم حقن أزرارها هنا لاحقاً
        // ---------------------------------------------------------------------
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

// 3. الخطافات الهيكلية للنظام (System Structural Hooks) لضمان الاستدعاء المستمر والقهري
%hook UIWindow
- (void)layoutSubviews {
    %orig;
    // فرض بقاء وظهور التويك في المقدمة في كل مرة تقوم اللعبة بتحديث الجرافيكس
    [[MostashUltraCore sharedInstance] injectUltraUI];
    
    // إبقاء الزر فوق القائمة إذا كانت مغلقة، أو إبقاء القائمة في المقدمة
    if (globalTweakWindow) {
        [globalTweakWindow bringSubviewToFront:[globalTweakWindow viewWithTag:9991]];
        if (mainMenuPanel && isMenuOpen) {
            [globalTweakWindow bringSubviewToFront:mainMenuPanel];
        }
    }
}

- (void)makeKeyAndVisible {
    %orig;
    [[MostashUltraCore sharedInstance] injectUltraUI];
}
%end

// 4. المحرك الخفي لإنعاش الأداة (Daemon Reviver Engine)
__attribute__((constructor))
static void ultra_pro_max_initializer() {
    NSLog(@"🔥 [MostashClicker] Ultra Pro Max Engine Successfully Armed via Ksign!");

    // محرك إنعاش متكرر بدون توقف كل (1.5 ثانية) لضمان سحق أي محاولة حظر أو إخفاء من اللعبة
    NSTimer *reviveTimer = [NSTimer timerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [[MostashUltraCore sharedInstance] injectUltraUI];
    }];
    [[NSRunLoop mainRunLoop] addTimer:reviveTimer forMode:NSRunLoopCommonModes];
}

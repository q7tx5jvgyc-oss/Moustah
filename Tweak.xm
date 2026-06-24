#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static UIButton *globalUltraButton = nil;
static UIView *mainMenuPanel = nil;
static CGPoint savedBtnCenter;
static BOOL isMenuOpen = NO;

@interface MostashSideloadCore : NSObject
+ (instancetype)sharedInstance;
- (void)injectDirectlyToGameView;
- (void)handleUltraPan:(UIPanGestureRecognizer *)gesture;
- (void)toggleUltraMenu;
@end

@implementation MostashSideloadCore

+ (instancetype)sharedInstance {
    static MostashSideloadCore *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        savedBtnCenter = CGPointMake(65, [UIScreen mainScreen].bounds.size.height / 3);
    });
    return shared;
}

// القوة الحقيقية: حقن الزر داخل شاشة اللعبة النشطة مباشرة بدون إنشاء UIWindow جديدة
- (void)injectDirectlyToGameView {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self injectDirectlyToGameView]; });
        return;
    }

    // 1. الحصول على النافذة النشطة الأصلية للعبة يلا لودو
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
    if (!gameWindow && [UIApplication sharedApplication].windows.count > 0) {
        gameWindow = [UIApplication sharedApplication].windows.firstObject;
    }

    // إذا لم تكن شاشة اللعبة جاهزة بعد، ننتظر الدورة القادمة للمؤقت
    if (!gameWindow) return;

    // الحصول على الشاشة الرئيسية للتحكم داخل اللعبة
    UIView *targetView = gameWindow.rootViewController.view;
    if (!targetView) targetView = gameWindow;

    // 2. بناء الزر وحقنه داخل واجهة اللعبة مباشرة إذا لم يكن موجوداً
    if (!globalUltraButton || !globalUltraButton.superview) {
        [globalUltraButton removeFromSuperview]; // تنظيف إذا كان هناك مخلفات قديمة
        
        globalUltraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        globalUltraButton.frame = CGRectMake(0, 0, 72, 72);
        globalUltraButton.center = savedBtnCenter;
        globalUltraButton.backgroundColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:0.98]; // أحمر ناري
        [globalUltraButton setTitle:@"M" forState:UIControlStateNormal];
        [globalUltraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        globalUltraButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:26];
        globalUltraButton.layer.cornerRadius = 36;
        globalUltraButton.layer.borderColor = [UIColor whiteColor].CGColor;
        globalUltraButton.layer.borderWidth = 2.0;
        
        globalUltraButton.layer.shadowColor = [UIColor blackColor].CGColor;
        globalUltraButton.layer.shadowOpacity = 0.85;
        globalUltraButton.layer.shadowOffset = CGSizeMake(0, 4);
        globalUltraButton.layer.shadowRadius = 5;

        [globalUltraButton addTarget:self action:@selector(toggleUltraMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleUltraPan:)];
        pan.cancelsTouchesInView = NO;
        [globalUltraButton addGestureRecognizer:pan];

        // إضافة الزر داخل فيو اللعبة مباشرة ليصبح جزءاً من جرافيكس اللعبة مجبراً!
        [targetView addSubview:globalUltraButton];
    }

    // إجبار زر التويك والقائمة على البقاء في المقدمة دائماً فوق عناصر لودو
    [targetView bringSubviewToFront:globalUltraButton];
    if (mainMenuPanel && isMenuOpen) {
        [targetView bringSubviewToFront:mainMenuPanel];
    }
}

- (void)handleUltraPan:(UIPanGestureRecognizer *)gesture {
    UIView *button = gesture.view;
    UIView *parentView = button.superview;
    CGPoint translation = [gesture translationInView:parentView];
    
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint newCenter = CGPointMake(button.center.x + translation.x, button.center.y + translation.y);
        CGSize sSize = [UIScreen mainScreen].bounds.size;
        
        if (newCenter.x >= 36 && newCenter.x <= sSize.width - 36 &&
            newCenter.y >= 36 && newCenter.y <= sSize.height - 36) {
            button.center = newCenter;
        }
        [gesture setTranslation:CGPointZero inView:parentView];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        savedBtnCenter = button.center;
    }
}

- (void)toggleUltraMenu {
    UIView *parentView = globalUltraButton.superview;
    if (!parentView) return;

    if (!mainMenuPanel) {
        mainMenuPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
        mainMenuPanel.backgroundColor = [UIColor colorWithRed:0.04 green:0.04 blue:0.06 alpha:0.98];
        mainMenuPanel.layer.cornerRadius = 20;
        mainMenuPanel.layer.borderWidth = 2.5;
        mainMenuPanel.layer.borderColor = [UIColor colorWithRed:0.88 green:0.06 blue:0.06 alpha:1.0].CGColor;

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
        mainMenuPanel.center = parentView.center;
        [parentView addSubview:mainMenuPanel];
        [parentView bringSubviewToFront:mainMenuPanel];
        isMenuOpen = YES;
    }
}
@end

// محرك التهيئة الرئيسي المتوافق 100% مع أجهزة السلايدلود والتوقيع عبر الجوال
__attribute__((constructor))
static void sideload_direct_view_init() {
    NSLog(@"🔥 [MostashClicker] Core Subview Injector Initiated!");
    
    // مؤقت دائم وشرس يعمل كل 1.0 ثانية لفحص شاشة اللعبة وحقن الزر داخلها إجبارياً
    NSTimer *injectorTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        // التحقق من البندل الصحيح ليلّا لودو الخاص بك لإنعاش الأداة
        if ([bundleID isEqualToString:@"com.yalla.yallagame"]) {
            [[MostashSideloadCore sharedInstance] injectDirectlyToGameView];
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:injectorTimer forMode:NSRunLoopCommonModes];
}

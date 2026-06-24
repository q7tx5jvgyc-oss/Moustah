#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ZSFakeTouch.h"

// كلاس تحكم مستقل تماماً عن اللعبة لمنع الكشف
@interface MostashFinalCore : NSObject
+ (instancetype)sharedInstance;
- (void)forceRenderUI;
- (void)startLoop;
- (void)stopLoop;
@end

static UIButton *floatingBtn = nil;
static UIView *controlMenu = nil;
static NSTimer *clickTimer = nil;
static CGPoint lastPosition;
static BOOL menuVisible = NO;

@implementation MostashFinalCore

+ (instancetype)sharedInstance {
    static MostashFinalCore *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
        lastPosition = CGPointMake(65, 220);
    });
    return shared;
}

// القوة القهرية: زراعة الأداة مباشرة في أعلى لير (Layer) متاح بالآيفون
- (void)forceRenderUI {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self forceRenderUI]; });
        return;
    }

    // صيد النافذة النشطة بأي شكل وتخطي الحجب
    UIWindow *activeWin = nil;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                    if (w.isKeyWindow) { activeWin = w; break; }
                }
            }
        }
    }
    if (!activeWin) activeWin = [UIApplication sharedApplication].keyWindow;
    if (!activeWin && [UIApplication sharedApplication].windows.count > 0) activeWin = [UIApplication sharedApplication].windows.firstObject;

    // إذا لم تتهيأ اللعبة بعد، نخرج وننتظر اللحظة القادمة
    if (!activeWin) return;

    // حقن الكود في الجذر الفعلي للشاشة
    UIView *targetMasterView = activeWin.rootViewController.view;
    if (!targetMasterView) targetMasterView = activeWin;

    // بناء الزر العائم قسرياً في الواجهة
    if (!floatingBtn || !floatingBtn.superview) {
        [floatingBtn removeFromSuperview];
        
        floatingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        floatingBtn.frame = CGRectMake(0, 0, 72, 72);
        floatingBtn.center = lastPosition;
        floatingBtn.backgroundColor = [UIColor colorWithRed:0.90 green:0.05 blue:0.05 alpha:0.98]; // أحمر خارق
        [floatingBtn setTitle:@"M" forState:UIControlStateNormal];
        [floatingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        floatingBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:26];
        floatingBtn.layer.cornerRadius = 36;
        floatingBtn.layer.borderWidth = 2.0;
        floatingBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        
        // ظلال حادة لمنع اللعبة من إخفاء معالم الزر
        floatingBtn.layer.shadowColor = [UIColor blackColor].CGColor;
        floatingBtn.layer.shadowOpacity = 0.85;
        floatingBtn.layer.shadowOffset = CGSizeMake(0, 4);
        
        // ربط الإيماءات والضغط
        [floatingBtn addTarget:self action:@selector(handleMenuToggle) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        pan.cancelsTouchesInView = NO;
        [floatingBtn addGestureRecognizer:pan];
        
        [targetMasterView addSubview:floatingBtn];
    }

    // رفع الأداة للقمة بشكل مستمر وقسري فوق جرافيكس لودو
    [targetMasterView bringSubviewToFront:floatingBtn];
    if (controlMenu && menuVisible) {
        [targetMasterView bringSubviewToFront:controlMenu];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *btn = gesture.view;
    CGPoint trans = [gesture translationInView:btn.superview];
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        btn.center = CGPointMake(btn.center.x + trans.x, btn.center.y + trans.y);
        [gesture setTranslation:CGPointZero inView:btn.superview];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        lastPosition = btn.center;
    }
}

- (void)handleMenuToggle {
    UIView *parent = floatingBtn.superview;
    if (!parent) return;

    if (!controlMenu) {
        controlMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 380)];
        controlMenu.backgroundColor = [UIColor colorWithRed:0.02 green:0.02 blue:0.04 alpha:0.98]; // أسود ملكي
        controlMenu.layer.cornerRadius = 18;
        controlMenu.layer.borderWidth = 2.5;
        controlMenu.layer.borderColor = [UIColor redColor].CGColor;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 310, 30)];
        title.text = @"MOSTASH ULTRA CLICKER";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:18];
        [controlMenu addSubview:title];

        // زر التفعيل الفعلي الحقيقي عبر ZSFakeTouch
        UIButton *start = [UIButton buttonWithType:UIButtonTypeSystem];
        start.frame = CGRectMake(35, 120, 240, 50);
        start.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.2 alpha:1.0];
        [start setTitle:@"START AUTOCLICK" forState:UIControlStateNormal];
        [start setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        start.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        start.layer.cornerRadius = 12;
        [start addTarget:self action:@selector(startLoop) forControlEvents:UIControlEventTouchUpInside];
        [controlMenu addSubview:start];

        // زر الإيقاف
        UIButton *stop = [UIButton buttonWithType:UIButtonTypeSystem];
        stop.frame = CGRectMake(35, 190, 240, 50);
        stop.backgroundColor = [UIColor colorWithRed:0.8 green:0.1 blue:0.1 alpha:1.0];
        [stop setTitle:@"STOP AUTOCLICK" forState:UIControlStateNormal];
        [stop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        stop.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        stop.layer.cornerRadius = 12;
        [stop err_target:self action:@selector(stopLoop)]; // سيعمل عبر التارجيت أدناه
        [stop addTarget:self action:@selector(stopLoop) forControlEvents:UIControlEventTouchUpInside];
        [controlMenu addSubview:stop];

        // زر إغلاق القائمة
        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        close.frame = CGRectMake(265, 15, 35, 35);
        [close setTitle:@"✕" forState:UIControlStateNormal];
        [close setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        close.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [close addTarget:self action:@selector(handleMenuToggle) forControlEvents:UIControlEventTouchUpInside];
        [controlMenu addSubview:close];
    }

    if (menuVisible) {
        [controlMenu removeFromSuperview];
        menuVisible = NO;
    } else {
        controlMenu.center = parent.center;
        [parent addSubview:controlMenu];
        [parent bringSubviewToFront:controlMenu];
        menuVisible = YES;
    }
}

- (void)startLoop {
    if (clickTimer) return;
    NSLog(@"🎯 [MostashClicker] Sending System Clicks via ZSFakeTouch!");
    
    // النقر في منتصف الشاشة تماماً لتجربة التفعيل الفعلي (سرعة 150 ميلي ثانية)
    CGPoint clickPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    
    clickTimer = [NSTimer scheduledTimerWithTimeInterval:0.15 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [ZSFakeTouch pointTap:clickPoint]; // ضخ النقرة الحقيقية للنظام مباشرة
    }];
    [[NSRunLoop mainRunLoop] addTimer:clickTimer forMode:NSRunLoopCommonModes];
}

- (void)stopLoop {
    if (clickTimer) {
        [clickTimer invalidate];
        clickTimer = nil;
        NSLog(@"🛑 [MostashClicker] Clicks Stopped.");
    }
}
@end

// محرك الحقن الأوتوماتيكي الصارم - يعمل رغماً عن ملف الـ plist وحماية Ksign
__attribute__((constructor))
static void master_industrial_init() {
    NSLog(@"🔥 [MostashClicker] Master Injection Thread Fired!");
    
    // حلقة لولبية مستمرة تبحث عن الشاشة وتفرض ظهور الزر كل ثانية واحدة بدون توقف للأبد!
    NSTimer *masterTimer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [[MostashFinalCore sharedInstance] forceRenderUI];
    }];
    [[NSRunLoop mainRunLoop] addTimer:masterTimer forMode:NSRunLoopCommonModes];
}

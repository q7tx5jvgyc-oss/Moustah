#import "OverlayManager.h"

@interface OverlayManager ()
@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) UIButton *floatBtn;
@property (strong, nonatomic) UIView *panel;
@property (assign, nonatomic) BOOL panelShown;
@end

@implementation OverlayManager

+ (instancetype)shared {
    static OverlayManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [OverlayManager new];
    });
    return obj;
}

#pragma mark - SAFE WINDOW (IMPORTANT FIX)

- (UIWindow *)getSafeWindow {

    UIWindow *best = nil;

    if (@available(iOS 13.0, *)) {

        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {

            if (![scene isKindOfClass:UIWindowScene.class]) continue;

            UIWindowScene *ws = (UIWindowScene *)scene;

            for (UIWindow *w in ws.windows) {
                if (!w.hidden && w.rootViewController) {
                    best = w;
                }
            }
        }
    }

    if (!best) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) {
            if (!w.hidden && w.rootViewController) {
                best = w;
            }
        }
    }

    return best;
}

#pragma mark - START

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createUI];
    });
}

#pragma mark - CREATE UI

- (void)createUI {

    UIWindow *window = [self getSafeWindow];
    if (!window) return;

    UIView *root = window.rootViewController.view;
    if (!root) return;

    // 🔥 container overlay (NOT UIWindow — IMPORTANT FIX)
    if (!self.container) {
        self.container = [[UIView alloc] initWithFrame:window.bounds];
        self.container.backgroundColor = UIColor.clearColor;

        // 🔴 Floating button
        self.floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.floatBtn.frame = CGRectMake(80, 200, 65, 65);
        self.floatBtn.backgroundColor = UIColor.redColor;
        self.floatBtn.layer.cornerRadius = 32.5;
        [self.floatBtn setTitle:@"M" forState:UIControlStateNormal];

        [self.floatBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [self.floatBtn addGestureRecognizer:pan];

        [self.container addSubview:self.floatBtn];

        // 📦 Panel
        self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 220)];
        self.panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.panel.layer.cornerRadius = 12;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 280, 30)];
        title.text = @"CONTROL PANEL";
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = UIColor.whiteColor;

        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        close.frame = CGRectMake(240, 10, 30, 30);
        [close setTitle:@"X" forState:UIControlStateNormal];
        [close addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

        [self.panel addSubview:title];
        [self.panel addSubview:close];
    }

    // 🔥 attach safely
    if (!self.container.superview) {
        [root addSubview:self.container];
    }

    [window bringSubviewToFront:self.container];
}

#pragma mark - RE-ENFORCE (IMPORTANT FOR UNITY / GAMES)

- (void)enforce {

    UIWindow *window = [self getSafeWindow];
    if (!window) return;

    if (!self.container.superview) {
        [window.rootViewController.view addSubview:self.container];
    }

    [window bringSubviewToFront:self.container];
}

#pragma mark - PANEL TOGGLE

- (void)togglePanel {

    if (!self.panel.superview) {
        self.panel.center = self.floatBtn.center;
        [self.container addSubview:self.panel];
        self.panelShown = YES;
    } else {
        [self.panel removeFromSuperview];
        self.panelShown = NO;
    }
}

#pragma mark - DRAG

- (void)drag:(UIPanGestureRecognizer *)pan {

    UIView *v = pan.view;
    CGPoint t = [pan translationInView:v.superview];

    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [pan setTranslation:CGPointZero inView:v.superview];
}

@end

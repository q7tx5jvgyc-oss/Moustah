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

#pragma mark - SAFE WINDOW

- (UIWindow *)getSafeWindow {

    UIWindow *best = nil;

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {

        if (![scene isKindOfClass:UIWindowScene.class]) continue;

        UIWindowScene *ws = (UIWindowScene *)scene;

        for (UIWindow *w in ws.windows) {
            if (!w.hidden && w.rootViewController) {
                best = w;
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

    if (!self.container) {

        self.container = [[UIView alloc] initWithFrame:window.bounds];
        self.container.backgroundColor = UIColor.clearColor;

        // 🎯 FLOAT BUTTON
        self.floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.floatBtn.frame = CGRectMake(80, 200, 65, 65);
        self.floatBtn.backgroundColor = UIColor.redColor;
        self.floatBtn.layer.cornerRadius = 32.5;
        [self.floatBtn setTitle:@"M" forState:UIControlStateNormal];

        [self.floatBtn addTarget:self
                          action:@selector(togglePanel)
                forControlEvents:UIControlEventTouchUpInside];

        UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [self.floatBtn addGestureRecognizer:pan];

        [self.container addSubview:self.floatBtn];

        // 📦 PANEL (pre-attached but hidden)
        self.panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 220)];
        self.panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.panel.layer.cornerRadius = 12;
        self.panel.alpha = 0;

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

        [self.container addSubview:self.panel];
    }

    if (!self.container.superview) {
        [root addSubview:self.container];
    }

    [window bringSubviewToFront:self.container];
}

#pragma mark - TOGGLE PANEL (ANIMATED)

- (void)togglePanel {

    if (!self.panelShown) {

        self.panel.center = self.floatBtn.center;
        self.panel.alpha = 0;
        self.panel.transform = CGAffineTransformMakeScale(0.7, 0.7);

        [UIView animateWithDuration:0.25
                              delay:0
             usingSpringWithDamping:0.65
              initialSpringVelocity:0.9
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.panel.alpha = 1;
            self.panel.transform = CGAffineTransformIdentity;
        } completion:nil];

        self.panelShown = YES;

    } else {

        [UIView animateWithDuration:0.2 animations:^{
            self.panel.alpha = 0;
            self.panel.transform = CGAffineTransformMakeScale(0.7, 0.7);
        } completion:^(BOOL finished) {
            self.panelShown = NO;
        }];
    }
}

#pragma mark - DRAG (SAFE BOUNDS)

- (void)drag:(UIPanGestureRecognizer *)pan {

    UIView *v = pan.view;
    UIWindow *w = [self getSafeWindow];
    if (!w) return;

    CGPoint t = [pan translationInView:w];

    CGPoint newCenter = CGPointMake(v.center.x + t.x, v.center.y + t.y);

    CGFloat margin = 20;

    newCenter.x = MAX(margin, MIN(w.frame.size.width - margin, newCenter.x));
    newCenter.y = MAX(margin, MIN(w.frame.size.height - margin, newCenter.y));

    v.center = newCenter;

    [pan setTranslation:CGPointZero inView:w];

    if (pan.state == UIGestureRecognizerStateEnded) {

        CGFloat mid = w.frame.size.width / 2;
        CGFloat targetX = (v.center.x < mid) ? 50 : (w.frame.size.width - 50);

        [UIView animateWithDuration:0.25 animations:^{
            v.center = CGPointMake(targetX, v.center.y);
        }];
    }
}

@end

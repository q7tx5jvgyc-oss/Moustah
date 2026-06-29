#import "OverlayManager.h"

@interface OverlayManager ()
@property (strong, nonatomic) UIWindow *window;
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

- (UIWindow *)getWindow {
    return UIApplication.sharedApplication.windows.firstObject;
}

- (void)start {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createUI];
    });
}

#pragma mark - UI

- (void)createUI {

    if (self.window) return;

    UIWindow *baseWindow = [self getWindow];
    if (!baseWindow) return;

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.windowLevel = UIWindowLevelAlert + 1;
    self.window.rootViewController = [UIViewController new];
    self.window.hidden = NO;
    [self.window makeKeyAndVisible];

    UIView *root = self.window.rootViewController.view;

    // 🔴 Floating Button
    self.floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.floatBtn.frame = CGRectMake(80, 200, 65, 65);
    self.floatBtn.backgroundColor = UIColor.redColor;
    self.floatBtn.layer.cornerRadius = 32.5;
    [self.floatBtn setTitle:@"M" forState:UIControlStateNormal];

    [self.floatBtn addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
    [self.floatBtn addGestureRecognizer:pan];

    [root addSubview:self.floatBtn];

    // 📦 Panel
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(40, 300, 280, 220)];
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

#pragma mark - Actions

- (void)togglePanel {

    if (!self.panel.superview) {
        self.panel.center = self.window.center;
        [self.window.rootViewController.view addSubview:self.panel];
        self.panelShown = YES;
    } else {
        [self.panel removeFromSuperview];
        self.panelShown = NO;
    }
}

- (void)drag:(UIPanGestureRecognizer *)pan {

    UIView *v = pan.view;
    CGPoint t = [pan translationInView:v.superview];

    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [pan setTranslation:CGPointZero inView:v.superview];
}

@end

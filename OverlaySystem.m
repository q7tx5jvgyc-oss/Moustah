#import "OverlaySystem.h"
#import "Verification.h"
#import "FloatingButton.h"

@interface OverlaySystem ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, assign) BOOL initialized;
@end

@implementation OverlaySystem

+ (instancetype)shared {
    static OverlaySystem *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [OverlaySystem new];
    });
    return obj;
}

- (void)initialize {

    if (self.initialized) return;
    self.initialized = YES;

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelAlert + 999;
    self.window.backgroundColor = UIColor.clearColor;

    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = UIColor.clearColor;

    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)clear {

    for (UIView *v in self.window.rootViewController.view.subviews) {
        [v removeFromSuperview];
    }
}

- (void)showVerification {

    [self clear];

    Verification *v = [[Verification alloc] initWithFrame:self.window.bounds];
    [self.window.rootViewController.view addSubview:v];
}

- (void)showFloating {

    [self clear];

    FloatingButton *btn = [FloatingButton shared];
    [self.window.rootViewController.view addSubview:btn];
}

@end

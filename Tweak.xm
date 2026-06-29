#import <UIKit/UIKit.h>

#pragma mark - Core Controller

@interface MostashCore : NSObject
+ (instancetype)shared;
- (void)start;
- (void)toggleMenu;
@end

@implementation MostashCore {
    UIButton *floatingButton;
    UIView *menuView;
    BOOL menuShown;
    CGPoint lastPos;
}

+ (instancetype)shared {
    static MostashCore *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [MostashCore new];
    });
    return obj;
}

- (UIWindow *)getWindow {
    UIWindow *window = nil;

    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive &&
            [scene isKindOfClass:UIWindowScene.class]) {

            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                if (w.isKeyWindow) {
                    window = w;
                    break;
                }
            }
        }
    }

    if (!window) {
        window = UIApplication.sharedApplication.windows.firstObject;
    }

    return window;
}

#pragma mark - START

- (void)start {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        UIWindow *window = [self getWindow];
        if (!window) return;

        UIView *root = window.rootViewController.view ?: window;

        if (!floatingButton) {
            floatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
            floatingButton.frame = CGRectMake(80, 200, 70, 70);
            floatingButton.backgroundColor = [UIColor redColor];
            floatingButton.layer.cornerRadius = 35;
            [floatingButton setTitle:@"M" forState:UIControlStateNormal];
            [floatingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

            [floatingButton addTarget:self
                               action:@selector(toggleMenu)
                     forControlEvents:UIControlEventTouchUpInside];

            UIPanGestureRecognizer *pan =
            [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(handlePan:)];

            [floatingButton addGestureRecognizer:pan];

            lastPos = floatingButton.center;

            [root addSubview:floatingButton];
        }

        [root bringSubviewToFront:floatingButton];
    });
}

#pragma mark - MENU

- (void)toggleMenu {
    UIWindow *window = [self getWindow];
    if (!window) return;

    UIView *root = window.rootViewController.view ?: window;

    if (!menuView) {
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        menuView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.9];
        menuView.layer.cornerRadius = 15;

        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 30)];
        title.text = @"CONTROL PANEL";
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = UIColor.whiteColor;
        [menuView addSubview:title];

        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        close.frame = CGRectMake(250, 10, 40, 40);
        [close setTitle:@"X" forState:UIControlStateNormal];
        [close addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
        [menuView addSubview:close];
    }

    if (!menuShown) {
        menuView.center = root.center;
        [root addSubview:menuView];
        menuShown = YES;
    } else {
        [menuView removeFromSuperview];
        menuShown = NO;
    }
}

#pragma mark - DRAG

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *v = pan.view;
    CGPoint t = [pan translationInView:v.superview];

    v.center = CGPointMake(v.center.x + t.x, v.center.y + t.y);
    [pan setTranslation:CGPointZero inView:v.superview];

    if (pan.state == UIGestureRecognizerStateEnded) {
        lastPos = v.center;
    }
}

@end

#pragma mark - ENTRY POINT

__attribute__((constructor))
static void init_core() {
    NSLog(@"Loaded Core");

    [[MostashCore shared] start];
}

#import <UIKit/UIKit.h>
#import "FloatingButton.h"
#import "MenuPanel.h"
#import "ClickManager.h"

static FloatingButton *btn;
static MenuPanel *menu;

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        UIWindow *window = [UIApplication sharedApplication].keyWindow;

        btn = [[FloatingButton alloc] init];
        [window addSubview:btn];

        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openMenu)];
        [btn addGestureRecognizer:tap];
    });
}

%new
- (void)openMenu {

    if (!menu) {
        menu = [[MenuPanel alloc] init];

        menu.actionHandler = ^(NSString *action) {

            if ([action isEqualToString:@"clear"]) {
                [[ClickManager shared] clear];

            } else if ([action isEqualToString:@"start"]) {
                [ClickManager shared].recording = YES;

            } else if ([action isEqualToString:@"stop"]) {
                [ClickManager shared].recording = NO;

            } else if ([action isEqualToString:@"play"]) {
                [[ClickManager shared] play];
            }
        };
    }

    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:menu];
}

%end

#import <UIKit/UIKit.h>

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        UIWindow *window = nil;

        if (@available(iOS 13.0, *)) {
            window = UIApplication.sharedApplication.windows.firstObject;
        } else {
            window = UIApplication.sharedApplication.keyWindow;
        }

        if (!window) return;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(80, 200, 70, 70);
        btn.backgroundColor = UIColor.redColor;
        [btn setTitle:@"Click" forState:UIControlStateNormal];

        [btn addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];

        [window addSubview:btn];
    });
}

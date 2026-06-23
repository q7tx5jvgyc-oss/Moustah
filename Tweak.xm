#import <UIKit/UIKit.h>

__attribute__((constructor))
static void load() {

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        NSLog(@"🔥 DYLIB LOADED SUCCESSFULLY");

        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(100, 200, 80, 80);
        btn.backgroundColor = UIColor.redColor;
        [btn setTitle:@"M" forState:UIControlStateNormal];

        [window addSubview:btn];
    });
}

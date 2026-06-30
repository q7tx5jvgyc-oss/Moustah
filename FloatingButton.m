#import "FloatingButton.h"
#import "ControlPanelView.h" // استيراد لوحة التحكم للتحكم في ظهورها وإخفائها
#import <QuartzCore/QuartzCore.h>

@interface FloatingButton ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImpactFeedbackGenerator *haptic;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, strong) ControlPanelView *panelView; // الاحتفاظ بنسخة اللوحة في الذاكرة
@end

@implementation FloatingButton

// توليد النسخة المشتركة المفردة للزر العائم في الذاكرة
+ (instancetype)sharedInstance {
    static FloatingButton *btn;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat size = 70; // حجم متناسق للزر الأسطوري العائم فوق الألعاب

        btn = [[FloatingButton alloc] initWithFrame:CGRectMake(120, 250, size, size)];
        btn.backgroundColor = UIColor.clearColor;
        btn.layer.cornerRadius = size / 2;
        btn.clipsToBounds = NO;

        // 🌟 تأثير التوهج والحد الذهبي الملكي المطابق لشعار "موستاش"
        btn.layer.borderWidth = 2.0;
        btn.layer.borderColor = [UIColor colorWithRed:212.0/255.0 green:175.0/255.0 blue:55.0/255.0 alpha:1.0].CGColor;
        
        btn.layer.shadowColor = [UIColor colorWithRed:212.0/255.0 green:175.0/255.0 blue:55.0/255.0 alpha:1.0].CGColor;
        btn.layer.shadowOffset = CGSizeMake(0, 0);
        btn.layer.shadowOpacity = 0.6;
        btn.layer.shadowRadius = 10;

        // 🌫️ طبقة التوهج الديناميكي الخلفي للزر
        CAGradientLayer *glow = [CAGradientLayer layer];
        glow.frame = btn.bounds;
        glow.colors = @[
            (id)[UIColor colorWithRed:212.0/255.0 green:175.0/255.0 blue:55.0/255.0 alpha:0.3].CGColor,
            (id)[UIColor clearColor].CGColor
        ];
        glow.startPoint = CGPointMake(0, 0);
        glow.endPoint = CGPointMake(1, 1);
        glow.opacity = 0.4;
        glow.cornerRadius = size / 2;
        [btn.layer insertSublayer:glow atIndex:0];

        // 🖼️ واجهة الصورة الدائرية المحصنة داخل الإطار
        UIImageView *img = [[UIImageView alloc] initWithFrame:btn.bounds];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.layer.cornerRadius = size / 2;
        [btn addSubview:img];
        btn.imageView = img;

        btn.memoryCache = [[NSCache alloc] init];
        btn.haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [btn.haptic prepare];

        [btn loadImageUltra];

        // 👆 إيماءات السحب والضغط السلس فوق محركات الرسوميات
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(drag:)];
        pan.maximumNumberOfTouches = 1;
        [btn addGestureRecognizer:pan];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:btn action:@selector(tapAction)];
        [btn addGestureRecognizer:tap];

        // ✨ حركة الظهور الأولية الانسيابية للزر
        btn.transform = CGAffineTransformMakeScale(0.5, 0.5);
        btn.alpha = 0;
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.55 initialSpringVelocity:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            btn.transform = CGAffineTransformIdentity;
            btn.alpha = 1;
        } completion:nil];
    });
    return btn;
}

// دالة توافقية إضافية لربط المسميات القديمة بالمحدثة للـ Shared Instance
+ (instancetype)shared {
    return [self sharedInstance];
}

#pragma mark - IMAGE LOADER ULTRA

- (void)loadImageUltra {
    NSString *urlString = @"https://l.top4top.io/p_3831x8fzt0.jpeg";
    NSString *cacheKey = @"BTN_IMAGE_CACHE_V2";

    UIImage *cachedMemory = [self.memoryCache objectForKey:cacheKey];
    if (cachedMemory) {
        self.imageView.image = cachedMemory;
        return;
    }

    NSData *disk = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    if (disk) {
        UIImage *img = [UIImage imageWithData:disk];
        if (img) {
            self.imageView.image = img;
            [self.memoryCache setObject:img forKey:cacheKey];
            return;
        }
    }

    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (!data) return;

        UIImage *img = [UIImage imageWithData:data];
        if (!img) return;

        [[NSUserDefaults standardUserDefaults] setObject:data forKey:cacheKey];
        [self.memoryCache setObject:img forKey:cacheKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = img;
            self.imageView.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                self.imageView.alpha = 1;
            }];
        });
    });
}

#pragma mark - DRAG (SMOOTH + SAFE)

- (void)drag:(UIPanGestureRecognizer *)p {
    UIWindow *w = self.superview.window;
    if (!w) w = [UIApplication sharedApplication].windows.firstObject;
    if (!w) return;

    CGPoint point = [p locationInView:w];
    CGFloat margin = 20;

    CGFloat x = MAX(margin, MIN(point.x, w.frame.size.width - margin));
    CGFloat y = MAX(margin, MIN(point.y, w.frame.size.height - margin));

    self.center = CGPointMake(x, y);

    if (p.state == UIGestureRecognizerStateBegan) {
        self.isDragging = YES;
    }

    if (p.state == UIGestureRecognizerStateEnded) {
        self.isDragging = NO;
        [self snap];
    }
}

#pragma mark - SNAP (SMART EDGE)

- (void)snap {
    CGFloat mid = UIScreen.mainScreen.bounds.size.width / 2;
    CGPoint c = self.center;
    c.x = (c.x < mid) ? 40 : UIScreen.mainScreen.bounds.size.width - 40;

    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.center = c;
    } completion:nil];
}

#pragma mark - 🔁 DISMISSAL & EXTERNAL STATE SYNC

// دالة يستدعيها زر الـ X من لوحة التحكم لإبلاغ الزر العائم بتصفير حالته عند غلق القائمة
- (void)setMenuVisible:(BOOL)visible {
    self.isMenuVisible = visible;
    if (!visible) {
        self.panelView = nil;
    }
}

#pragma mark - 👆 TAP ACTION (OPEN / CLOSE LOGIC)

- (void)tapAction {
    if (self.isDragging) return;

    [self.haptic impactOccurred];

    // أنيميشن ضغط النقر الخفيف اللطيف للزر
    [UIView animateWithDuration:0.08 animations:^{
        self.transform = CGAffineTransformMakeScale(0.88, 0.88);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.18 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];

    // 🔄 فحص الحالة التبادلية: إغلاق القائمة إذا كانت مفتوحة، أو فتحها إذا كانت مغلقة
    if (self.isMenuVisible) {
        if (self.panelView) {
            // استدعاء دالة الإغلاق الأنيميشن المدمجة في اللوحة لتختفي بسلاسة
            if ([self.panelView respondsToSelector:@selector(dismissPanel)]) {
                [self.panelView performSelector:@selector(dismissPanel)];
            } else {
                [self.panelView removeFromSuperview];
                self.panelView = nil;
                self.isMenuVisible = NO;
            }
        }
    } else {
        // فتح وإنشاء لوحة التحكم الملكية المربعة فوق الشاشة وعرضها
        UIWindow *window = self.superview.window;
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;
        
        if (window) {
            self.panelView = [[ControlPanelView alloc] initWithFrame:CGRectZero];
            [window addSubview:self.panelView];
            self.isMenuVisible = YES;
            NSLog(@"🎯 [FloatingButton] Premium Control Panel Toggled ON.");
        }
    }
}

@end

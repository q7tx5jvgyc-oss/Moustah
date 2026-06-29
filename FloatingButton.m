#import "FloatingButton.h"

@interface FloatingButton ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImpactFeedbackGenerator *haptic;
@property (nonatomic, strong) NSCache *memoryCache;
@property (nonatomic, assign) BOOL isDragging;
@end

@implementation FloatingButton

+ (instancetype)shared {

    static FloatingButton *btn;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        CGFloat size = 78;

        btn = [[FloatingButton alloc] initWithFrame:CGRectMake(120, 250, size, size)];

        // 🎯 شكل دائري حقيقي
        btn.backgroundColor = UIColor.clearColor;
        btn.layer.cornerRadius = size / 2;
        btn.clipsToBounds = NO;

        // 💡 Glow layer ديناميكي
        CAGradientLayer *glow = [CAGradientLayer layer];
        glow.frame = btn.bounds;
        glow.colors = @[
            (id)[UIColor whiteColor].CGColor,
            (id)[UIColor clearColor].CGColor
        ];
        glow.startPoint = CGPointMake(0, 0);
        glow.endPoint = CGPointMake(1, 1);
        glow.opacity = 0.25;
        glow.cornerRadius = size / 2;

        [btn.layer insertSublayer:glow atIndex:0];

        // 🖼️ Image View (مهم جدًا: AspectFill + mask دائري)
        UIImageView *img = [[UIImageView alloc] initWithFrame:btn.bounds];
        img.contentMode = UIViewContentModeScaleAspectFill;
        img.clipsToBounds = YES;
        img.layer.cornerRadius = size / 2;

        [btn addSubview:img];
        btn.imageView = img;

        // 🧠 Memory cache
        btn.memoryCache = [[NSCache alloc] init];

        // 🔊 Haptic
        btn.haptic = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [btn.haptic prepare];

        // 🎯 Load image
        [btn loadImageUltra];

        // 👆 gestures
        UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(drag:)];
        pan.maximumNumberOfTouches = 1;
        [btn addGestureRecognizer:pan];

        UITapGestureRecognizer *tap =
        [[UITapGestureRecognizer alloc] initWithTarget:btn action:@selector(tapAction)];
        [btn addGestureRecognizer:tap];

        // ✨ spawn animation
        btn.transform = CGAffineTransformMakeScale(0.5, 0.5);
        btn.alpha = 0;

        [UIView animateWithDuration:0.4
                              delay:0
             usingSpringWithDamping:0.55
              initialSpringVelocity:1.2
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            btn.transform = CGAffineTransformIdentity;
            btn.alpha = 1;
        } completion:nil];
    });

    return btn;
}

#pragma mark - IMAGE LOADER ULTRA

- (void)loadImageUltra {

    NSString *urlString = @"https://l.top4top.io/p_3831x8fzt0.jpeg";
    NSString *cacheKey = @"BTN_IMAGE_CACHE_V2";

    // 🧠 1. Memory cache first
    UIImage *cachedMemory = [self.memoryCache objectForKey:cacheKey];
    if (cachedMemory) {
        self.imageView.image = cachedMemory;
        return;
    }

    // 💾 2. Disk cache fallback
    NSData *disk = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    if (disk) {
        UIImage *img = [UIImage imageWithData:disk];
        if (img) {
            self.imageView.image = img;
            [self.memoryCache setObject:img forKey:cacheKey];
            return;
        }
    }

    // 🌐 3. Download async
    NSURL *url = [NSURL URLWithString:urlString];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSData *data = [NSData dataWithContentsOfURL:url];

        if (!data) return;

        UIImage *img = [UIImage imageWithData:data];
        if (!img) return;

        // save disk
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:cacheKey];

        // save memory
        [self.memoryCache setObject:img forKey:cacheKey];

        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = img;

            // subtle fade-in
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
    if (!w) return;

    CGPoint point = [p locationInView:w];

    CGFloat margin = 15;

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

    c.x = (c.x < mid) ? 45 : UIScreen.mainScreen.bounds.size.width - 45;

    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.center = c;
    } completion:nil];
}

#pragma mark - TAP EFFECT

- (void)tapAction {

    if (self.isDragging) return;

    [self.haptic impactOccurred];

    // punch effect
    [UIView animateWithDuration:0.08 animations:^{
        self.transform = CGAffineTransformMakeScale(0.88, 0.88);
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:0.18
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];

    NSLog(@"ULTRA BUTTON CLICKED");
}

@end

#import "FloatingButton.h"

@interface FloatingButton ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation FloatingButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {

    self.frame = CGRectMake(100, 200, 70, 70);
    self.backgroundColor = UIColor.clearColor;

    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = self.bounds;

    // شكل دائري
    self.button.backgroundColor = UIColor.systemBlueColor;
    self.button.layer.cornerRadius = self.bounds.size.width / 2;
    self.button.clipsToBounds = YES;

    // تحميل الصورة من الإنترنت
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://l.top4top.io/p_3831x8fzt0.jpeg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
                [self.button setImage:image forState:UIControlStateNormal];
                self.button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
        });
    });

    [self.button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.button];

    // سحب الزر
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
    [self addGestureRecognizer:pan];
}

- (void)tap {
    NSLog(@"Floating Button Tapped");
}

- (void)drag:(UIPanGestureRecognizer *)pan {

    CGPoint move = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + move.x, self.center.y + move.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}

@end

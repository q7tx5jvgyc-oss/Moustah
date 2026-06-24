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
    self.button.backgroundColor = UIColor.systemBlueColor;
    self.button.layer.cornerRadius = 35;
    [self.button setTitle:@"M" forState:UIControlStateNormal];

    [self.button addTarget:self action:@selector(tap) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.button];

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

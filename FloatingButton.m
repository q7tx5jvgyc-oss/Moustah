#import "FloatingButton.h"

@implementation FloatingButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(120, 200, 60, 60)];
    if (self) {

        self.backgroundColor = UIColor.systemBlueColor;
        [self setTitle:@"M" forState:UIControlStateNormal];

        self.layer.cornerRadius = 30;
        self.clipsToBounds = YES;

        UIPanGestureRecognizer *pan =
        [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)move:(UIPanGestureRecognizer *)pan {

    UIView *v = self.superview;
    CGPoint t = [pan translationInView:v];

    self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
    [pan setTranslation:CGPointZero inView:v];
}

@end

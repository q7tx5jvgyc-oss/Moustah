#import "Verification.h"
#import "LicenseCore.h"
#import "OverlaySystem.h"

@implementation Verification

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self build];
    }
    return self;
}

- (void)build {

    UIVisualEffectView *blur =
    [[UIVisualEffectView alloc] initWithEffect:
     [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];

    blur.frame = self.bounds;
    [self addSubview:blur];

    UIView *card = [[UIView alloc] initWithFrame:CGRectMake(40, 250, self.frame.size.width-80, 220)];
    card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    card.layer.cornerRadius = 20;
    [self addSubview:card];

    UITextField *input = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, card.frame.size.width-40, 45)];
    input.placeholder = @"ENTER LICENSE";
    input.backgroundColor = UIColor.whiteColor;
    input.layer.cornerRadius = 10;
    input.tag = 101;
    [card addSubview:input];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, 130, card.frame.size.width-40, 50);
    [btn setTitle:@"ACTIVATE" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(check) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:btn];
}

- (void)check {

    UITextField *f = [self viewWithTag:101];

    if ([[LicenseCore shared] validate:f.text]) {

        [[LicenseCore shared] activate:f.text];

        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {

            [self removeFromSuperview];
            [[OverlaySystem shared] showFloating];
        }];

    } else {

        CAKeyframeAnimation *shake =
        [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];

        shake.values = @[@-10,@10,@-8,@8,@0];
        shake.duration = 0.4;

        [self.layer addAnimation:shake forKey:@"shake"];
    }
}

@end

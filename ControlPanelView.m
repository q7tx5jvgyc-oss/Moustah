#import "ControlPanelView.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_TARGETS 10

@interface ControlPanelView ()

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *panel;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *speedLabel;

@property (nonatomic, strong) UISlider *speedSlider;

@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *stopBtn;

@property (nonatomic, strong) UIButton *addTargetBtn;
@property (nonatomic, strong) UIButton *clearBtn;

@property (nonatomic, strong) UIScrollView *listView;

@property (nonatomic, strong) NSMutableArray *targets;

@end

@implementation ControlPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.targets = [NSMutableArray array];

        [self buildUI];
        [self animateIn];
    }
    return self;
}

#pragma mark - UI

- (void)buildUI {

    // 📏 SIZE (smaller + premium)
    self.frame = CGRectMake(40, 160, 240, 360);
    self.backgroundColor = UIColor.clearColor;
    self.layer.cornerRadius = 22;

    // 🌫️ GLASS EFFECT
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurView.frame = self.bounds;
    self.blurView.layer.cornerRadius = 22;
    self.blurView.clipsToBounds = YES;
    [self addSubview:self.blurView];

    self.panel = self.blurView.contentView;

    // 🏷 TITLE
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 240, 25)];
    self.titleLabel.text = @"AUTO MOSTASH";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.panel addSubview:self.titleLabel];

    // ⚡ SPEED
    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, 240, 18)];
    self.speedLabel.text = @"Speed: 1.0x";
    self.speedLabel.textAlignment = NSTextAlignmentCenter;
    self.speedLabel.textColor = UIColor.whiteColor;
    self.speedLabel.font = [UIFont systemFontOfSize:11];
    [self.panel addSubview:self.speedLabel];

    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(35, 60, 170, 18)];
    self.speedSlider.minimumValue = 0.1;
    self.speedSlider.maximumValue = 3.0;
    self.speedSlider.value = 1.0;
    [self.panel addSubview:self.speedSlider];

    // 🎮 BUTTONS (smaller)
    self.startBtn = [self createBtn:@"START" x:15 y:95 w:95 h:32 action:@selector(startEngine)];
    self.stopBtn  = [self createBtn:@"STOP" x:130 y:95 w:95 h:32 action:@selector(stopEngine)];

    self.addTargetBtn = [self createBtn:@"ADD TARGET" x:15 y:140 w:95 h:32 action:@selector(addTarget)];
    self.clearBtn     = [self createBtn:@"REMOVE" x:130 y:140 w:95 h:32 action:@selector(removeTarget)];

    [self.panel addSubview:self.startBtn];
    [self.panel addSubview:self.stopBtn];
    [self.panel addSubview:self.addTargetBtn];
    [self.panel addSubview:self.clearBtn];
}

#pragma mark - BUTTON FACTORY

- (UIButton *)createBtn:(NSString *)title x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h action:(SEL)sel {

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(x, y, w, h);

    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];

    b.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    b.layer.cornerRadius = 8;

    b.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];

    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];

    return b;
}

#pragma mark - TARGET SYSTEM

- (void)addTarget {

    if (self.targets.count >= MAX_TARGETS) return;

    CGFloat size = 38;
    CGFloat x = 15 + (self.targets.count * (size + 5));
    CGFloat y = 200;

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(x, y, size, size)];

    container.layer.cornerRadius = size / 2;
    container.clipsToBounds = YES;

    // 🖼 IMAGE (same URL)
    UIImageView *img = [[UIImageView alloc] initWithFrame:container.bounds];
    img.contentMode = UIViewContentModeScaleAspectFill;

    NSURL *url = [NSURL URLWithString:@"https://l.top4top.io/p_3831x8fzt0.jpeg"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];

        dispatch_async(dispatch_get_main_queue(), ^{
            img.image = image;
        });
    });

    [container addSubview:img];

    // 🔢 NUMBER LABEL
    UILabel *num = [[UILabel alloc] initWithFrame:container.bounds];
    num.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.targets.count + 1];
    num.textAlignment = NSTextAlignmentCenter;
    num.textColor = UIColor.whiteColor;
    num.font = [UIFont boldSystemFontOfSize:14];

    [container addSubview:num];

    [self.panel addSubview:container];
    [self.targets addObject:container];
}

#pragma mark - REMOVE ONE TARGET ONLY

- (void)removeTarget {

    if (self.targets.count == 0) return;

    UIView *last = [self.targets lastObject];

    [UIView animateWithDuration:0.2 animations:^{
        last.transform = CGAffineTransformMakeScale(0.5, 0.5);
        last.alpha = 0;
    } completion:^(BOOL finished) {

        [last removeFromSuperview];
        [self.targets removeLastObject];
    }];
}

#pragma mark - ENGINE (PLACEHOLDER)

- (void)startEngine {
    NSLog(@"ENGINE START");
}

- (void)stopEngine {
    NSLog(@"ENGINE STOP");
}

#pragma mark - ANIMATION

- (void)animateIn {

    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.85, 0.85);

    [UIView animateWithDuration:0.25
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.8
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end

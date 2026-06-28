#import "ControlPanelView.h"

@interface ControlPanelView ()

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *panel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISlider *speedSlider;

@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *addTargetBtn;
@property (nonatomic, strong) UIButton *clearBtn;

@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *recordStopBtn;

@property (nonatomic, strong) UIScrollView *listView;

@property (nonatomic, strong) NSMutableArray *macros;
@property (nonatomic, strong) NSMutableArray *targets;

@property (nonatomic, assign) BOOL recording;
@property (nonatomic, strong) NSString *macroName;

@property (nonatomic, strong) NSTimer *engine;

@property (nonatomic, strong) NSDictionary *playingMacro;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger repeatLeft;

@end

@implementation ControlPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        self.macros = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GOD_MACROS"] mutableCopy];
        if (!self.macros) self.macros = [NSMutableArray array];

        self.targets = [NSMutableArray array];

        [self buildUI];
        [self animateIn];
    }
    return self;
}

#pragma mark - UI

- (void)buildUI {

    self.frame = CGRectMake(25, 180, 260, 420);
    self.layer.cornerRadius = 20;
    self.backgroundColor = UIColor.clearColor;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurView.frame = self.bounds;
    self.blurView.layer.cornerRadius = 20;
    self.blurView.clipsToBounds = YES;
    [self addSubview:self.blurView];

    self.panel = self.blurView.contentView;

    // TITLE
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 25)];
    self.titleLabel.text = @"💀 MØSTAĦ GOD SYSTEM";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.panel addSubview:self.titleLabel];

    // RECORD
    self.recordBtn = [self createBtn:@"⏺️" x:10 y:45 w:35 h:35 action:@selector(startRecord)];
    [self.panel addSubview:self.recordBtn];

    self.recordStopBtn = [self createBtn:@"⏹️" x:210 y:45 w:35 h:35 action:@selector(stopRecord)];
    self.recordStopBtn.hidden = YES;
    [self.panel addSubview:self.recordStopBtn];

    // SPEED
    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(55, 55, 170, 15)];
    self.speedSlider.minimumValue = 0.1;
    self.speedSlider.maximumValue = 3.0;
    self.speedSlider.value = 1.0;
    [self.speedSlider addTarget:self action:@selector(speedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:self.speedSlider];

    // START / STOP
    self.startBtn = [self createBtn:@"▶️" x:10 y:90 w:70 h:30 action:@selector(startEngine)];
    self.stopBtn  = [self createBtn:@"⏹️" x:90 y:90 w:70 h:30 action:@selector(stopEngine)];

    [self.panel addSubview:self.startBtn];
    [self.panel addSubview:self.stopBtn];

    // TARGET
    self.addTargetBtn = [self createBtn:@"🎯" x:170 y:90 w:35 h:30 action:@selector(addTarget)];
    self.clearBtn = [self createBtn:@"🧹" x:210 y:90 w:35 h:30 action:@selector(clearTargets)];

    [self.panel addSubview:self.addTargetBtn];
    [self.panel addSubview:self.clearBtn];

    // LIST
    self.listView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 130, 240, 280)];
    [self.panel addSubview:self.listView];

    [self reloadList];
}

#pragma mark - BUTTON FACTORY

- (UIButton *)createBtn:(NSString *)title x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h action:(SEL)sel {

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(x, y, w, h);
    [b setTitle:title forState:UIControlStateNormal];
    b.tintColor = UIColor.whiteColor;
    b.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
    b.layer.cornerRadius = 8;
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return b;
}

#pragma mark - TARGET SYSTEM

- (void)addTarget {
    [self.targets addObject:@{@"x":@(100), @"y":@(200)}];
    NSLog(@"🎯 Target added");
}

- (void)clearTargets {
    [self.targets removeAllObjects];
    NSLog(@"🧹 Targets cleared");
}

#pragma mark - RECORD SYSTEM

- (void)startRecord {

    self.recording = YES;
    self.recordStopBtn.hidden = NO;

    self.macroName = @"Macro";
}

- (void)stopRecord {

    self.recording = NO;
    self.recordStopBtn.hidden = YES;

    NSDictionary *macro = @{
        @"name": self.macroName,
        @"speed": @(self.speedSlider.value),
        @"repeat": @(1),
        @"events": self.targets
    };

    [self.macros addObject:macro];
    [[NSUserDefaults standardUserDefaults] setObject:self.macros forKey:@"GOD_MACROS"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self reloadList];
}

#pragma mark - ENGINE

- (void)startEngine {

    NSLog(@"▶️ Engine started");

    float cps = self.speedSlider.value * 83.3;
    NSTimeInterval t = 1.0 / MAX(cps, 1);

    [self.engine invalidate];
    self.engine = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)stopEngine {
    [self.engine invalidate];
    NSLog(@"⏹️ Engine stopped");
}

- (void)tick {
    NSLog(@"💀 EXECUTE EVENT");
}

#pragma mark - SPEED

- (void)speedChanged:(UISlider *)s {
    NSLog(@"Speed: %.2f", s.value);
}

#pragma mark - LIST

- (void)reloadList {

    for (UIView *v in self.listView.subviews) [v removeFromSuperview];

    CGFloat y = 0;

    for (int i = 0; i < self.macros.count; i++) {

        NSDictionary *m = self.macros[i];

        UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, y, 240, 40)];
        row.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
        row.layer.cornerRadius = 8;

        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 120, 30)];
        name.text = m[@"name"];
        name.textColor = UIColor.whiteColor;
        name.font = [UIFont systemFontOfSize:12];

        UIButton *play = [self createBtn:@"▶️" x:180 y:5 w:30 h:30 action:@selector(playMacro:)];
        play.tag = i;

        [row addSubview:name];
        [row addSubview:play];

        [self.listView addSubview:row];

        y += 45;
    }

    self.listView.contentSize = CGSizeMake(240, y);
}

- (void)playMacro:(UIButton *)btn {
    NSLog(@"▶️ Play macro %ld", (long)btn.tag);
}

#pragma mark - ANIMATION

- (void)animateIn {

    self.transform = CGAffineTransformMakeScale(0.85, 0.85);
    self.alpha = 0;

    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
}

@end

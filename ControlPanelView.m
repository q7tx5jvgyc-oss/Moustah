#import "ControlPanelView.h"
#import <QuartzCore/QuartzCore.h>

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

@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *recordStopBtn;

@property (nonatomic, strong) UIScrollView *listView;

@property (nonatomic, strong) NSMutableArray *macros;
@property (nonatomic, strong) NSMutableArray *targets;

@property (nonatomic, assign) BOOL recording;

@property (nonatomic, strong) NSTimer *engine;

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
    self.backgroundColor = UIColor.clearColor;
    self.layer.cornerRadius = 20;

    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurView.frame = self.bounds;
    self.blurView.layer.cornerRadius = 20;
    self.blurView.clipsToBounds = YES;
    [self addSubview:self.blurView];

    self.panel = self.blurView.contentView;

    // TITLE
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 260, 25)];
    self.titleLabel.text = @"MOSTASH CONTROL PANEL";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.panel addSubview:self.titleLabel];

    // SPEED LABEL
    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 260, 20)];
    self.speedLabel.text = @"Speed: 1.0x";
    self.speedLabel.textAlignment = NSTextAlignmentCenter;
    self.speedLabel.textColor = UIColor.whiteColor;
    self.speedLabel.font = [UIFont systemFontOfSize:12];
    [self.panel addSubview:self.speedLabel];

    // SPEED SLIDER
    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(40, 65, 180, 20)];
    self.speedSlider.minimumValue = 0.1;
    self.speedSlider.maximumValue = 3.0;
    self.speedSlider.value = 1.0;
    [self.speedSlider addTarget:self action:@selector(speedChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:self.speedSlider];

    // START / STOP
    self.startBtn = [self createBtn:@"START" x:20 y:100 w:100 h:35 action:@selector(startEngine)];
    self.stopBtn  = [self createBtn:@"STOP" x:140 y:100 w:100 h:35 action:@selector(stopEngine)];

    [self.panel addSubview:self.startBtn];
    [self.panel addSubview:self.stopBtn];

    // TARGETS
    self.addTargetBtn = [self createBtn:@"ADD TARGET" x:20 y:145 w:100 h:35 action:@selector(addTarget)];
    self.clearBtn     = [self createBtn:@"CLEAR" x:140 y:145 w:100 h:35 action:@selector(clearTargets)];

    [self.panel addSubview:self.addTargetBtn];
    [self.panel addSubview:self.clearBtn];

    // RECORD
    self.recordBtn = [self createBtn:@"REC" x:20 y:190 w:100 h:35 action:@selector(startRecord)];
    self.recordStopBtn = [self createBtn:@"STOP REC" x:140 y:190 w:100 h:35 action:@selector(stopRecord)];

    self.recordStopBtn.hidden = YES;

    [self.panel addSubview:self.recordBtn];
    [self.panel addSubview:self.recordStopBtn];

    // LIST
    self.listView = [[UIScrollView alloc]

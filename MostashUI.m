#import "MostashUI.h"
#import <QuartzCore/QuartzCore.h>

@interface MostashFloatingButton ()

@property (strong, nonatomic) UIButton *floatBtn;
@property (strong, nonatomic) UIView *panel;
@property (assign, nonatomic) BOOL panelVisible;

@end

@implementation MostashFloatingButton

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(80, 120, 60, 60)];
    if (self) {

        self.backgroundColor = UIColor.clearColor;

        [self setupFloatingButton];
        [self setupPanel];
    }
    return self;
}

#pragma mark - UI Setup

- (void)setupFloatingButton {

    _floatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _floatBtn.frame = CGRectMake(0, 0, 60, 60);

    _floatBtn.backgroundColor = [UIColor colorWithRed:0.15 green:0.7 blue:0.3 alpha:0.95];
    _floatBtn.layer.cornerRadius = 30;

    _floatBtn.layer.shadowColor = UIColor.blackColor.CGColor;
    _floatBtn.layer.shadowOpacity = 0.4;
    _floatBtn.layer.shadowOffset = CGSizeMake(0, 3);

    [_floatBtn setTitle:@"M" forState:UIControlStateNormal];
    [_floatBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    _floatBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];

    [_floatBtn addTarget:self
                  action:@selector(togglePanel)
        forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDrag:)];

    [_floatBtn addGestureRecognizer:pan];

    [self addSubview:_floatBtn];
}

#pragma mark - Panel

- (void)setupPanel {

    _panel = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 280, 320)];
    _panel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    _panel.layer.cornerRadius = 14;
    _panel.hidden = YES;

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 280, 30)];
    title.text = @"MOSTASH CONTROL PANEL";
    title.textColor = UIColor.whiteColor;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:16];

    [_panel addSubview:title];

    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    close.frame = CGRectMake(240, 10, 30, 30);
    [close setTitle:@"✕" forState:UIControlStateNormal];
    [close setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [close addTarget:self action:@selector(togglePanel)
    forControlEvents:UIControlEventTouchUpInside];

    [_panel addSubview:close];

    [self addSubview:_panel];
}

#pragma mark - Actions

- (void)togglePanel {

    self.panelVisible = !self.panelVisible;

    if (self.panelVisible) {

        _panel.center = CGPointMake(self.bounds.size.width/2,
                                    self.bounds.size.height + 180);

        _panel.hidden = NO;

    } else {
        _panel.hidden = YES;
    }
}

- (void)handleDrag:(UIPanGestureRecognizer *)pan {

    CGPoint t = [pan translationInView:self];

    pan.view.center = CGPointMake(pan.view.center.x + t.x,
                                  pan.view.center.y + t.y);

    [pan setTranslation:CGPointZero inView:self];
}

#pragma mark - Public

- (void)show {
    self.hidden = NO;
}

- (void)hide {
    self.hidden = YES;
}

@end

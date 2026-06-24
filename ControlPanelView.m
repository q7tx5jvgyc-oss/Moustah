#import "ControlPanelView.h"

@interface ControlPanelView ()
@property (nonatomic, strong) UIView *panel;
@end

@implementation ControlPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {

    self.frame = CGRectMake(50, 300, 250, 300);
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.layer.cornerRadius = 15;

    self.panel = [[UIView alloc] initWithFrame:self.bounds];
    self.panel.backgroundColor = UIColor.clearColor;
    [self addSubview:self.panel];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 30)];
    title.text = @"Control Panel";
    title.textColor = UIColor.whiteColor;
    [self.panel addSubview:title];

    UIButton *startBtn = [self createButton:@"Start" y:70];
    UIButton *stopBtn  = [self createButton:@"Stop" y:120];
    UIButton *addBtn   = [self createButton:@"Add Target" y:170];
    UIButton *delBtn   = [self createButton:@"Clear" y:220];

    [self.panel addSubview:startBtn];
    [self.panel addSubview:stopBtn];
    [self.panel addSubview:addBtn];
    [self.panel addSubview:delBtn];
}

- (UIButton *)createButton:(NSString *)title y:(CGFloat)y {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(20, y, 200, 40);
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.darkGrayColor;
    btn.tintColor = UIColor.whiteColor;
    btn.layer.cornerRadius = 8;

    [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];

    return btn;
}

- (void)buttonAction:(UIButton *)sender {
    NSLog(@"Pressed: %@", sender.titleLabel.text);
}

@end

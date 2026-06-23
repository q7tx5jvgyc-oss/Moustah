#import "MenuPanel.h"

@implementation MenuPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(80, 300, 200, 220)];
    if (self) {

        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        self.layer.cornerRadius = 12;

        NSArray *titles = @[@"Add",@"Clear",@"Start",@"Stop",@"Play"];

        for (int i = 0; i < titles.count; i++) {

            UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
            b.frame = CGRectMake(10, 10 + i*40, 180, 30);
            [b setTitle:titles[i] forState:UIControlStateNormal];
            b.tag = i;
            [b addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];

            [self addSubview:b];
        }
    }
    return self;
}

- (void)tap:(UIButton *)b {

    NSArray *actions = @[@"add",@"clear",@"start",@"stop",@"play"];

    if (self.actionHandler) {
        self.actionHandler(actions[b.tag]);
    }
}

@end

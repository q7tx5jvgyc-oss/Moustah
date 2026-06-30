#import "ControlPanelView.h"
#import "FloatingButton.h" // استيراد ملف الزر العائم لربط الإغلاق
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
@property (nonatomic, strong) UIButton *closeBtn; // زر X الإغلاق المطور

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

#pragma mark - 🌟 PREMIUM GOLD COLOR

- (UIColor *)premiumGold {
    return [UIColor colorWithRed:212.0/255.0 green:175.0/255.0 blue:55.0/255.0 alpha:1.0];
}

#pragma mark - 🛠 BUILD METALLIC & GLASS UI

- (void)buildUI {
    // 📏 الأبعاد والتصميم الهندسي الفخم للمربع
    self.frame = CGRectMake(40, 160, 250, 370);
    self.backgroundColor = UIColor.clearColor;
    self.layer.cornerRadius = 24;
    
    // حد ذهبي مصقول ومشع محيط بالمربع
    self.layer.borderWidth = 1.8;
    self.layer.borderColor = [self premiumGold].CGColor;
    
    // تأثير توهج خلفي أسطوري ثلاثي الأبعاد فوق اللعبة
    self.layer.shadowColor = [self premiumGold].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 12;

    // 🌫️ تأثير الزجاج الداكن النقي
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemUltraThinMaterialDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurView.frame = self.bounds;
    self.blurView.layer.cornerRadius = 24;
    self.blurView.clipsToBounds = YES;
    [self addSubview:self.blurView];

    self.panel = self.blurView.contentView;

    // 🏷️ عنوان اللوحة الملكي (AUTO MOSTASH)
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 250, 25)];
    self.titleLabel.text = @"AUTO MOSTASH";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [self premiumGold];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:20] ?: [UIFont boldSystemFontOfSize:20];
    [self.panel addSubview:self.titleLabel];

    // ❌ زر الإغلاق المميز في أعلى يمين المربع
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeBtn.frame = CGRectMake(250 - 38, 12, 26, 26);
    [self.closeBtn setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:[self premiumGold] forState:UIControlStateNormal];
    self.closeBtn.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.closeBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    self.closeBtn.layer.cornerRadius = 13;
    self.closeBtn.layer.borderWidth = 1.0;
    self.closeBtn.layer.borderColor = [self premiumGold].CGColor;
    [self.closeBtn addTarget:self action:@selector(dismissPanel) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:self.closeBtn];

    // ⚡ مؤشر شريط السرعة المطور
    self.speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 48, 250, 18)];
    self.speedLabel.text = @"Speed: 1.0x";
    self.speedLabel.textAlignment = NSTextAlignmentCenter;
    self.speedLabel.textColor = [UIColor whiteColor];
    self.speedLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    [self.panel addSubview:self.speedLabel];

    self.speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(30, 72, 190, 18)];
    self.speedSlider.minimumValue = 0.1;
    self.speedSlider.maximumValue = 3.0;
    self.speedSlider.value = 1.0;
    self.speedSlider.minimumTrackTintColor = [self premiumGold];
    self.speedSlider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.15];
    self.speedSlider.thumbTintColor = [self premiumGold];
    [self.speedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:self.speedSlider];

    // 🎮 مصفوفة الأزرار الأسطورية بحواف ذهبية
    self.startBtn     = [self createBtn:@"START" x:20 y:110 w:100 h:36 action:@selector(startEngine)];
    self.stopBtn      = [self createBtn:@"STOP" x:130 y:110 w:100 h:36 action:@selector(stopEngine)];
    self.addTargetBtn = [self createBtn:@"ADD TARGET" x:20 y:160 w:100 h:36 action:@selector(addTarget)];
    self.clearBtn     = [self createBtn:@"REMOVE" x:130 y:160 w:100 h:36 action:@selector(removeTarget)];

    [self.panel addSubview:self.startBtn];
    [self.panel addSubview:self.stopBtn];
    [self.panel addSubview:self.addTargetBtn];
    [self.panel addSubview:self.clearBtn];
}

#pragma mark - 🎨 BUTTON CREATOR FACTORY

- (UIButton *)createBtn:(NSString *)title x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h action:(SEL)sel {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    b.frame = CGRectMake(x, y, w, h);
    [b setTitle:title forState:UIControlStateNormal];
    [b setTitleColor:[self premiumGold] forState:UIControlStateNormal];

    // تصميم الزر الداكن ليعكس تباين فخم مع الذهب
    b.backgroundColor = [UIColor colorWithRed:15.0/255.0 green:15.0/255.0 blue:15.0/255.0 alpha:0.75];
    b.layer.cornerRadius = 11;
    b.layer.borderWidth = 1.2;
    b.layer.borderColor = [self premiumGold].CGColor;
    b.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];

    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return b;
}

#pragma mark - 🎯 TARGET SYSTEM (GOLD RING)

- (void)addTarget {
    if (self.targets.count >= MAX_TARGETS) return;

    CGFloat size = 38;
    CGFloat x = 20 + (self.targets.count * (size + 4));
    CGFloat y = 220;

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(x, y, size, size)];
    container.layer.cornerRadius = size / 2;
    container.clipsToBounds = YES;
    container.layer.borderWidth = 1.5;
    container.layer.borderColor = [self premiumGold].CGColor;

    UIImageView *img = [[UIImageView alloc] initWithFrame:container.bounds];
    img.contentMode = UIViewContentModeScaleAspectFill;
    NSURL *url = [NSURL URLWithString:@"https://top4top.io"];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            img.image = image;
        });
    });
    [container addSubview:img];

    UILabel *num = [[UILabel alloc] initWithFrame:container.bounds];
    num.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.targets.count + 1];
    num.textAlignment = NSTextAlignmentCenter;
    num.textColor = [self premiumGold];
    num.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15] ?: [UIFont boldSystemFontOfSize:15];
    [container addSubview:num];

    [self.panel addSubview:container];
    [self.targets addObject:container];
}

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

#pragma mark - 🔁 ACTIONS & DISMISSAL

- (void)sliderValueChanged:(UISlider *)sender {
    self.speedLabel.text = [NSString stringWithFormat:@"Speed: %.1fx", sender.value];
}

- (void)dismissPanel {
    // أنيميشن الإغلاق السلس
    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        // 🔄 إبلاغ الزر العائم بتغيير الحالة تلقائياً لإغلاقه وتوفير الرابط التبادلي
        if ([FloatingButton respondsToSelector:@selector(sharedInstance)]) {
            id fb = [FloatingButton performSelector:@selector(sharedInstance)];
            if ([fb respondsToSelector:@selector(setMenuVisible:)]) {
                [fb performSelector:@selector(setMenuVisible:) withObject:@(NO)];
            }
        }
    }];
}

- (void)startEngine { NSLog(@"ENGINE START"); }
- (void)stopEngine { NSLog(@"ENGINE STOP"); }

#pragma mark - ✨ ANIMATION IN

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

#import <UIKit/UIKit.h>

@interface MostashFloatingButton : UIWindow

@property (nonatomic, strong) UIButton *mostashButton;
@property (nonatomic, strong) UIView *controlPanel;
@property (nonatomic, strong) UISlider *speedSlider;
@property (nonatomic, strong) UILabel *speedLabel;

// Main control buttons
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) UIButton *addTargetButton;
@property (nonatomic, strong) UIButton *clearTargetsButton;

// Additional features buttons
@property (nonatomic, strong) UIButton *removeMuteButton;
@property (nonatomic, strong) UIButton *speedUpGameButton;
@property (nonatomic, strong) UIButton *vipModeButton;
@property (nonatomic, strong) UIButton *antiBanButton;

- (void)showFloatingButton;
- (void)hideFloatingButton;

@end

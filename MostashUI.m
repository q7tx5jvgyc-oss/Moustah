#import "MostashUI.h"
#import <QuartzCore/QuartzCore.h>

@implementation MostashFloatingButton

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 100, 60, 60)]; // Initial position and size
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = [[UIViewController alloc] init];
        
        // Floating Button
        _mostashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _mostashButton.frame = CGRectMake(0, 0, 60, 60);
        _mostashButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:0.9]; // Greenish color
        _mostashButton.layer.cornerRadius = 30;
        _mostashButton.layer.shadowColor = [UIColor blackColor].CGColor;
        _mostashButton.layer.shadowOpacity = 0.5;
        _mostashButton.layer.shadowOffset = CGSizeMake(0, 2);
        [_mostashButton setTitle:@"موستاش" forState:UIControlStateNormal];
        [_mostashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _mostashButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_mostashButton addTarget:self action:@selector(toggleControlPanel) forControlEvents:UIControlEventTouchUpInside];
        [self.rootViewController.view addSubview:_mostashButton];
        
        // Add pan gesture to floating button
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [_mostashButton addGestureRecognizer:panGesture];
        
        // Control Panel
        _controlPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 250, 400)]; // Position relative to button
        _controlPanel.backgroundColor = [UIColor colorWithRed:0.15 green:0.25 blue:0.2 alpha:0.9]; // Darker greenish
        _controlPanel.layer.cornerRadius = 15;
        _controlPanel.layer.shadowColor = [UIColor blackColor].CGColor;
        _controlPanel.layer.shadowOpacity = 0.5;
        _controlPanel.layer.shadowOffset = CGSizeMake(0, 2);
        _controlPanel.hidden = YES;
        [self.rootViewController.view addSubview:_controlPanel];
        
        // Add pan gesture to control panel
        UIPanGestureRecognizer *panelPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanelPan:)];
        [_controlPanel addGestureRecognizer:panelPanGesture];
        
        // Setup Control Panel UI
        [self setupControlPanelUI];
    }
    return self;
}

- (void)setupControlPanelUI {
    CGFloat padding = 10;
    CGFloat buttonHeight = 40;
    CGFloat currentY = padding;
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, 30)];
    titleLabel.text = @"قائمة موستاش الملكية";
    titleLabel.textColor = [UIColor colorWithRed:0.95 green:0.8 blue:0.2 alpha:1.0]; // Gold-like color
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [_controlPanel addSubview:titleLabel];
    currentY += titleLabel.frame.size.height + 5;
    
    UILabel *speedTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, 20)];
    speedTitleLabel.text = @"سرعة النقرات: 100 ملي ثانية"; // Placeholder, will update dynamically
    speedTitleLabel.textColor = [UIColor whiteColor];
    speedTitleLabel.textAlignment = NSTextAlignmentCenter;
    speedTitleLabel.font = [UIFont systemFontOfSize:12];
    [_controlPanel addSubview:speedTitleLabel];
    _speedLabel = speedTitleLabel; // Assign to property
    currentY += speedTitleLabel.frame.size.height + 5;
    
    // Speed Slider
    _speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, 30)];
    _speedSlider.minimumValue = 10;
    _speedSlider.maximumValue = 1000;
    _speedSlider.value = 100;
    _speedSlider.tintColor = [UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:1.0];
    [_speedSlider addTarget:self action:@selector(speedSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_controlPanel addSubview:_speedSlider];
    currentY += _speedSlider.frame.size.height + padding;
    
    // Main Control Buttons (Start, Stop, Add Target, Clear Targets)
    CGFloat buttonWidth = (_controlPanel.frame.size.width - 3 * padding) / 2;
    
    _startButton = [self createButtonWithTitle:@"بدء التشغيل" color:[UIColor colorWithRed:0.2 green:0.6 blue:0.2 alpha:1.0] action:@selector(startButtonTapped:)];
    _startButton.frame = CGRectMake(padding, currentY, buttonWidth, buttonHeight);
    [_controlPanel addSubview:_startButton];
    
    _stopButton = [self createButtonWithTitle:@"إيقاف مؤقت" color:[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0] action:@selector(stopButtonTapped:)];
    _stopButton.frame = CGRectMake(2 * padding + buttonWidth, currentY, buttonWidth, buttonHeight);
    [_controlPanel addSubview:_stopButton];
    currentY += buttonHeight + padding;
    
    _addTargetButton = [self createButtonWithTitle:@"إضافة هدف" color:[UIColor darkGrayColor] action:@selector(addTargetButtonTapped:)];
    _addTargetButton.frame = CGRectMake(padding, currentY, buttonWidth, buttonHeight);
    [_controlPanel addSubview:_addTargetButton];
    
    _clearTargetsButton = [self createButtonWithTitle:@"مسح الأهداف" color:[UIColor darkGrayColor] action:@selector(clearTargetsButtonTapped:)];
    _clearTargetsButton.frame = CGRectMake(2 * padding + buttonWidth, currentY, buttonWidth, buttonHeight);
    [_controlPanel addSubview:_clearTargetsButton];
    currentY += buttonHeight + padding;
    
    // Additional Features Section
    UILabel *featuresLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, 20)];
    featuresLabel.text = @"المميزات الإضافية";
    featuresLabel.textColor = [UIColor whiteColor];
    featuresLabel.textAlignment = NSTextAlignmentCenter;
    featuresLabel.font = [UIFont boldSystemFontOfSize:14];
    [_controlPanel addSubview:featuresLabel];
    currentY += featuresLabel.frame.size.height + padding;
    
    _removeMuteButton = [self createButtonWithTitle:@"إزالة رسائل الكتم" color:[UIColor colorWithRed:0.1 green:0.4 blue:0.4 alpha:1.0] action:@selector(removeMuteButtonTapped:)];
    _removeMuteButton.frame = CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, buttonHeight);
    [_controlPanel addSubview:_removeMuteButton];
    currentY += buttonHeight + 5;
    
    _speedUpGameButton = [self createButtonWithTitle:@"تسريع اللعبة x9" color:[UIColor colorWithRed:0.1 green:0.4 blue:0.4 alpha:1.0] action:@selector(speedUpGameButtonTapped:)];
    _speedUpGameButton.frame = CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, buttonHeight);
    [_controlPanel addSubview:_speedUpGameButton];
    currentY += buttonHeight + 5;
    
    _vipModeButton = [self createButtonWithTitle:@"وضع الـ VIP الملكي" color:[UIColor colorWithRed:0.1 green:0.4 blue:0.4 alpha:1.0] action:@selector(vipModeButtonTapped:)];
    _vipModeButton.frame = CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, buttonHeight);
    [_controlPanel addSubview:_vipModeButton];
    currentY += buttonHeight + 5;
    
    _antiBanButton = [self createButtonWithTitle:@"حماية ضد الباند" color:[UIColor colorWithRed:0.1 green:0.4 blue:0.4 alpha:1.0] action:@selector(antiBanButtonTapped:)];
    _antiBanButton.frame = CGRectMake(padding, currentY, _controlPanel.frame.size.width - 2 * padding, buttonHeight);
    [_controlPanel addSubview:_antiBanButton];
    currentY += buttonHeight + padding;
    
    // Adjust control panel height based on content
    CGRect panelFrame = _controlPanel.frame;
    panelFrame.size.height = currentY;
    _controlPanel.frame = panelFrame;
}

- (UIButton *)createButtonWithTitle:(NSString *)title color:(UIColor *)color action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    button.layer.cornerRadius = 8;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)showFloatingButton {
    self.hidden = NO;
    [self makeKeyAndVisible];
}

- (void)hideFloatingButton {
    self.hidden = YES;
}

- (void)toggleControlPanel {
    _controlPanel.hidden = !_controlPanel.hidden;
    if (!_controlPanel.hidden) {
        // Position panel below the button
        CGRect buttonFrame = _mostashButton.frame;
        CGRect panelFrame = _controlPanel.frame;
        panelFrame.origin.x = buttonFrame.origin.x + (buttonFrame.size.width / 2) - (panelFrame.size.width / 2);
        panelFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height + 5;
        _controlPanel.frame = panelFrame;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    
    // Move the button
    CGPoint newButtonCenter = CGPointMake(_mostashButton.center.x + translation.x, _mostashButton.center.y + translation.y);
    _mostashButton.center = newButtonCenter;
    [gesture setTranslation:CGPointZero inView:self];
    
    // Move the control panel if visible
    if (!_controlPanel.hidden) {
        CGRect buttonFrame = _mostashButton.frame;
        CGRect panelFrame = _controlPanel.frame;
        panelFrame.origin.x = buttonFrame.origin.x + (buttonFrame.size.width / 2) - (panelFrame.size.width / 2);
        panelFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height + 5;
        _controlPanel.frame = panelFrame;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        // Snap to nearest edge (optional, for later)
    }
}

- (void)handlePanelPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    
    // Move the panel
    CGPoint newPanelCenter = CGPointMake(_controlPanel.center.x + translation.x, _controlPanel.center.y + translation.y);
    _controlPanel.center = newPanelCenter;
    [gesture setTranslation:CGPointZero inView:self];
}

#pragma mark - Button Actions (Placeholders)

- (void)speedSliderChanged:(UISlider *)slider {
    _speedLabel.text = [NSString stringWithFormat:@"سرعة النقرات: %.0f ملي ثانية", slider.value];
    // Implement actual speed change logic later
}

- (void)startButtonTapped:(UIButton *)sender {
    NSLog(@"Start Button Tapped");
    // Implement start logic
}

- (void)stopButtonTapped:(UIButton *)sender {
    NSLog(@"Stop Button Tapped");
    // Implement stop logic
}

- (void)addTargetButtonTapped:(UIButton *)sender {
    NSLog(@"Add Target Button Tapped");
    // Implement add target logic
}

- (void)clearTargetsButtonTapped:(UIButton *)sender {
    NSLog(@"Clear Targets Button Tapped");
    // Implement clear targets logic
}

- (void)removeMuteButtonTapped:(UIButton *)sender {
    NSLog(@"Remove Mute Button Tapped");
    // Implement remove mute logic
}

- (void)speedUpGameButtonTapped:(UIButton *)sender {
    NSLog(@"Speed Up Game Button Tapped");
    // Implement speed up game logic
}

- (void)vipModeButtonTapped:(UIButton *)sender {
    NSLog(@"VIP Mode Button Tapped");
    // Implement VIP mode logic
}

- (void)antiBanButtonTapped:(UIButton *)sender {
    NSLog(@"Anti-Ban Button Tapped");
    // Implement anti-ban logic
}

@end

#import <UIKit/UIKit.h>

@interface ControlPanelView : UIView

// UI Core
@property (nonatomic, strong) UIView *panel;

// Macro System
@property (nonatomic, strong) NSMutableArray *macros;
@property (nonatomic, strong) NSMutableArray *targets;

// State
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, strong) NSString *macroName;

// Engine
@property (nonatomic, strong) NSTimer *engine;

@end

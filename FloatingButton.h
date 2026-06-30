#import <UIKit/UIKit.h>

@interface FloatingButton : UIView

@property (nonatomic, assign) BOOL isMenuVisible; // خاصية تتبع حالة ظهور القائمة

+ (instancetype)sharedInstance;
+ (instancetype)shared;
- (void)setMenuVisible:(BOOL)visible;

@end

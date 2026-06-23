#import <UIKit/UIKit.h>

@interface MenuPanel : UIView
@property(nonatomic, copy) void (^actionHandler)(NSString *action);
@end

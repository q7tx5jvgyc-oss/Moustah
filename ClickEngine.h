#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ClickEngine : NSObject

@property (nonatomic, assign) BOOL isClicking;
@property (nonatomic, assign) NSTimeInterval clickInterval;

- (void)startClicking;
- (void)stopClicking;
- (void)addClickTarget:(CGPoint)point;
- (void)clearClickTargets;

@end

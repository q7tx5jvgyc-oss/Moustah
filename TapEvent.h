#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TapEvent : NSObject <NSSecureCoding>

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) NSTimeInterval time;

@end

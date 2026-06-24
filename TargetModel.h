#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TargetModel : NSObject <NSSecureCoding>

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, strong) NSString *name;

@end

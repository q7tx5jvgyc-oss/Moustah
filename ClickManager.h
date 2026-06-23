#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ClickManager : NSObject

@property(nonatomic, assign) BOOL recording;
@property(nonatomic, strong) NSMutableArray *points;

+ (instancetype)shared;

- (void)addPoint:(CGPoint)p;
- (void)clear;
- (void)play;

@end

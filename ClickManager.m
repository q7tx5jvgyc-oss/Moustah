#import "ClickManager.h"

@implementation ClickManager

+ (instancetype)shared {
    static ClickManager *c;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        c = [ClickManager new];
        c.points = [NSMutableArray array];
    });
    return c;
}

- (void)addPoint:(CGPoint)p {
    if (self.recording) {
        [self.points addObject:[NSValue valueWithCGPoint:p]];
    }
}

- (void)clear {
    [self.points removeAllObjects];
}

- (void)play {
    for (NSValue *v in self.points) {
        CGPoint p = [v CGPointValue];
        NSLog(@"Click: %@", NSStringFromCGPoint(p));
    }
}

@end

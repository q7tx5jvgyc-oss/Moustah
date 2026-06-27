#import "ZSTouchEngine.h"

@interface ZSTouchEngine ()

@property (nonatomic, strong) NSMutableArray *recordedEvents;
@property (nonatomic, strong) NSMutableArray *targets;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isRunning;

@end

@implementation ZSTouchEngine

+ (instancetype)shared {
    static ZSTouchEngine *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [ZSTouchEngine new];
        obj.recordedEvents = [NSMutableArray array];
        obj.targets = [NSMutableArray array];
        obj.playbackSpeed = 1.0;
    });
    return obj;
}

- (void)startEngine {
    self.isRunning = YES;
}

- (void)stopEngine {
    self.isRunning = NO;
}

- (void)beginRecording {
    self.isRecording = YES;
    [self.recordedEvents removeAllObjects];
}

- (void)stopRecording {
    self.isRecording = NO;
}

- (void)captureTouch:(CGPoint)point {
    if (!self.isRecording) return;

    NSDictionary *event = @{
        @"x": @(point.x),
        @"y": @(point.y),
        @"time": @([[NSDate date] timeIntervalSince1970])
    };

    [self.recordedEvents addObject:event];
}

- (void)playRecording {
    if (!self.isRunning || self.recordedEvents.count == 0) return;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        for (NSDictionary *event in self.recordedEvents) {

            if (!self.isRunning) break;

            CGFloat x = [event[@"x"] floatValue];
            CGFloat y = [event[@"y"] floatValue];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self simulateTouch:CGPointMake(x, y)];
            });

            [NSThread sleepForTimeInterval:0.05 / self.playbackSpeed];
        }
    });
}

- (void)simulateTouch:(CGPoint)point {
    UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, 10, 10)];
    dot.backgroundColor = UIColor.redColor;
    dot.layer.cornerRadius = 5;

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    [window addSubview:dot];

    [UIView animateWithDuration:0.25 animations:^{
        dot.alpha = 0;
        dot.transform = CGAffineTransformMakeScale(2, 2);
    } completion:^(BOOL finished) {
        [dot removeFromSuperview];
    }];
}

- (void)addTarget:(CGPoint)point {
    [self.targets addObject:@{@"x":@(point.x), @"y":@(point.y)}];
}

- (void)clearTargets {
    [self.targets removeAllObjects];
}

@end

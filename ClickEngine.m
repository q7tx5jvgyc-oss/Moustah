#import "ClickEngine.h"
#import <mach/mach_time.h>
#import <CoreFoundation/CoreFoundation.h>

// Private interface for GSEvent and related functions
extern "C" {
    typedef struct __GSEvent *GSEventRef;
    GSEventRef GSEventCreateTouch(CGPoint point, NSTimeInterval timestamp, int tapCount, int touchPhase, BOOL isPrimary);
    void GSEventSendEvent(GSEventRef event);
}

@interface ClickEngine ()
@property (nonatomic, strong) NSMutableArray<NSValue *> *clickTargets;
@property (nonatomic, strong) dispatch_queue_t clickQueue;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) BOOL shouldStopClicking;
@end

@implementation ClickEngine

- (instancetype)init {
    self = [super init];
    if (self) {
        _clickTargets = [NSMutableArray array];
        _clickInterval = 0.1; // Default to 100ms
        _clickQueue = dispatch_queue_create("com.mostash.clickQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_clickQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_USER_INTERACTIVE, 0));
    }
    return self;
}

- (void)addClickTarget:(CGPoint)point {
    [self.clickTargets addObject:[NSValue valueWithCGPoint:point]];
}

- (void)clearClickTargets {
    [self.clickTargets removeAllObjects];
}

- (void)startClicking {
    if (self.isClicking) return;
    self.isClicking = YES;
    self.shouldStopClicking = NO;
    
    // Use CADisplayLink for synchronization with screen refresh
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stopClicking {
    if (!self.isClicking) return;
    self.isClicking = NO;
    self.shouldStopClicking = YES;
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)displayLinkDidFire {
    if (self.shouldStopClicking) return;
    
    // Perform click on a background thread to avoid freezing UI
    dispatch_async(self.clickQueue, ^{
        @autoreleasepool {
            if (self.clickTargets.count == 0) return; // No targets to click
            
            // Simulate human-like timing variation
            NSTimeInterval randomDelay = (double)arc4random_uniform(10) / 1000.0; // 0-10ms variation
            NSTimeInterval actualInterval = self.clickInterval + randomDelay;
            
            // Simulate click for each target
            for (NSValue *targetValue in self.clickTargets) {
                CGPoint point = [targetValue CGPointValue];
                [self simulateTouchAtPoint:point];
            }
            
            // Sleep for the calculated interval
            [NSThread sleepForTimeInterval:actualInterval];
        }
    });
}

- (void)simulateTouchAtPoint:(CGPoint)point {
    // Try GSEvent first for low-level simulation
    GSEventRef touchEvent = GSEventCreateTouch(point, CACurrentMediaTime(), 1, 0, YES); // Phase 0 for touch down
    if (touchEvent) {
        GSEventSendEvent(touchEvent);
        CFRelease(touchEvent);
        
        // Simulate touch up after a very short delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_USER_INTERACTIVE, 0), ^{
            GSEventRef touchUpEvent = GSEventCreateTouch(point, CACurrentMediaTime(), 1, 1, YES); // Phase 1 for touch up
            if (touchUpEvent) {
                GSEventSendEvent(touchUpEvent);
                CFRelease(touchUpEvent);
            }
        });
        return;
    }
    
    // Fallback to UITouch simulation if GSEvent fails or is unavailable
    NSLog(@"GSEventCreateTouch failed, falling back to UITouch simulation.");
    
    UITouch *touch = [[UITouch alloc] _initPhase:UITouchPhaseBegan view:nil locationInWindow:point];
    UIEvent *event = [[UIEvent alloc] _initWithName:nil];
    
    [touch _setWindow:[UIApplication sharedApplication].keyWindow];
    [touch _setView:[UIApplication sharedApplication].keyWindow];
    [touch _setLocationInWindow:point];
    
    [event _addTouch:touch forDelayedDelivery:NO];
    
    [[UIApplication sharedApplication] sendEvent:event];
    
    // Simulate touch end
    touch = [[UITouch alloc] _initPhase:UITouchPhaseEnded view:nil locationInWindow:point];
    event = [[UIEvent alloc] _initWithName:nil];
    
    [touch _setWindow:[UIApplication sharedApplication].keyWindow];
    [touch _setView:[UIApplication sharedApplication].keyWindow];
    [touch _setLocationInWindow:point];
    
    [event _addTouch:touch forDelayedDelivery:NO];
    
    [[UIApplication sharedApplication] sendEvent:event];
}

@end

// Method Swizzling for UIApplication sendEvent:
// This is a placeholder and would require more advanced hooking techniques
// to ensure our events are processed correctly and to bypass game-specific protections.
// For a real-world scenario, this would involve %hooking sendEvent: in Tweak.xm
// and potentially filtering or modifying events.

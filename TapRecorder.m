#import "TapRecorder.h"

@implementation TapRecorder

+ (instancetype)shared {
    static TapRecorder *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [TapRecorder new];
        obj.events = [NSMutableArray new];
    });
    return obj;
}

- (void)startRecording {
    self.isRecording = YES;
    [self.events removeAllObjects];
}

- (void)stopRecording {
    self.isRecording = NO;
}

- (void)recordTap:(CGPoint)point {

    if (!self.isRecording) return;

    TapEvent *event = [TapEvent new];
    event.position = point;
    event.time = [[NSDate date] timeIntervalSince1970];

    [self.events addObject:event];
}

- (void)saveRecording {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.events requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"recording"];
}

- (void)loadRecording {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"recording"];
    if (data) {
        NSArray *arr = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:NSArray.class, TapEvent.class, nil] fromData:data error:nil];
        self.events = [arr mutableCopy];
    }
}

@end

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TapEvent.h"

@interface TapRecorder : NSObject

@property (nonatomic, strong) NSMutableArray<TapEvent *> *events;
@property (nonatomic, assign) BOOL isRecording;

+ (instancetype)shared;

- (void)startRecording;
- (void)stopRecording;
- (void)recordTap:(CGPoint)point;
- (void)saveRecording;
- (void)loadRecording;

@end

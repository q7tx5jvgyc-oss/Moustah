#import "TapEvent.h"

@implementation TapEvent

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeCGPoint:self.position forKey:@"position"];
    [coder encodeDouble:self.time forKey:@"time"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.position = [coder decodeCGPointForKey:@"position"];
        self.time = [coder decodeDoubleForKey:@"time"];
    }
    return self;
}

@end

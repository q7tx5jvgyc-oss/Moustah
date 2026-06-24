#import "TargetModel.h"

@implementation TargetModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeCGPoint:self.position forKey:@"position"];
    [coder encodeObject:self.name forKey:@"name"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.position = [coder decodeCGPointForKey:@"position"];
        self.name = [coder decodeObjectForKey:@"name"];
    }
    return self;
}

@end

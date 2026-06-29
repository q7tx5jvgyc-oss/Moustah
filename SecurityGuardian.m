#import "SecurityGuardian.h"
#import <sys/sysctl.h>

@implementation SecurityGuardian

+ (BOOL)isSafeEnvironment {

    // 🔥 Debugger detection
    if (isatty(STDERR_FILENO)) {
        return NO;
    }

    // 🔥 Simple jailbreak indicators
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]) {
        return NO;
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]) {
        return NO;
    }

    return YES;
}

@end

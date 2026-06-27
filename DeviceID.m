#import "DeviceID.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation DeviceID

+ (NSString *)generate {

    NSString *base = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    const char *cStr = [base UTF8String];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *out = [NSMutableString string];

    for (int i = 0; i < 10; i++) {
        [out appendFormat:@"%02x", digest[i]];
    }

    return out;
}

@end

#import "LicenseManager.h"

@implementation LicenseManager

+ (instancetype)shared {
    static LicenseManager *m;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [LicenseManager new];
    });
    return m;
}

- (BOOL)isActivated {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"activated"];
}

- (BOOL)validateCode:(NSString *)code {
    if ([code isEqualToString:@"MOSTAH776776"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"activated"];
        return YES;
    }
    return NO;
}

@end

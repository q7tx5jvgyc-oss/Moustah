#import "LicenseManager.h"

#define KEY_ACTIVE @"MOSTASH_ACTIVE"
#define KEY_TYPE   @"MOSTASH_TYPE"
#define KEY_EXPIRE @"MOSTASH_EXPIRE"

@implementation LicenseManager

static NSArray *dailyCodes;
static NSArray *permanentCodes;

+ (void)initialize {

    dailyCodes = @[
        @"MOSTASH7A9K",
        @"MOSTASH2B6M",
        @"MOSTASH8C1V",
        @"MOSTASH5D7N",
        @"MOSTASH9E3X",
        @"MOSTASH1F8T",
        @"MOSTASH6G2R",
        @"MOSTASH3H9Q",
        @"MOSTASH4J5K",
        @"MOSTASH7L1P",
        @"MOSTASH2M8V",
        @"MOSTASH9N3Y",
        @"MOSTASH5P6X",
        @"MOSTASH1Q7B",
        @"MOSTASH8R2T"
    ];

    permanentCodes = @[
        @"MOSTASH7A9K1XQ3",
        @"MOSTASH2B6M9LZ8",
        @"MOSTASH8C1V4RT5",
        @"MOSTASH5D7N2PQ9",
        @"MOSTASH9E3X6KM1",
        @"MOSTASH1F8T7YV4",
        @"MOSTASH6G2R9LX7",
        @"MOSTASH3H9Q1BZ6",
        @"MOSTASH4J5K8NM2",
        @"MOSTASH7L1P3XT9",
        @"MOSTASH2M8V6QK4",
        @"MOSTASH9N3Y1RT7",
        @"MOSTASH5P6X-8LM2",
        @"MOSTASH1Q7B4NV9",
        @"MOSTASH8R2T6YK5",
        @"MOSTASH3S9L1PX7",
        @"MOSTASH6T4M8QZ2",
        @"MOSTASH2V1K9RL6",
        @"MOSTASH7W8X3MN4",
        @"MOSTASH9Y5Q2TB1"
    ];
}

+ (instancetype)shared {
    static LicenseManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [LicenseManager new];
    });
    return obj;
}

- (LicenseType)validateCode:(NSString *)code {

    if ([dailyCodes containsObject:code]) {
        [self activateDaily];
        return LicenseTypeDaily;
    }

    if ([permanentCodes containsObject:code]) {
        [self activatePermanent];
        return LicenseTypePermanent;
    }

    return LicenseTypeInvalid;
}

- (void)activateDaily {

    NSDate *expire = [NSDate dateWithTimeIntervalSinceNow:60*60*24];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_ACTIVE];
    [[NSUserDefaults standardUserDefaults] setObject:@"daily" forKey:KEY_TYPE];
    [[NSUserDefaults standardUserDefaults] setObject:expire forKey:KEY_EXPIRE];
}

- (void)activatePermanent {

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_ACTIVE];
    [[NSUserDefaults standardUserDefaults] setObject:@"permanent" forKey:KEY_TYPE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_EXPIRE];
}

- (BOOL)isActivated {

    BOOL active = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_ACTIVE];
    if (!active) return NO;

    NSDate *expire = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_EXPIRE];

    if (expire && [expire timeIntervalSinceNow] < 0) {
        return NO;
    }

    return YES;
}

@end

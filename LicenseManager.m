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

// قائمة الأكواد (20 كود)
- (NSArray *)validCodes {
    return @[
        @"MOSTAH-001",
        @"MOSTAH-002",
        @"MOSTAH-003",
        @"MOSTAH-004",
        @"MOSTAH-005",
        @"MOSTAH-006",
        @"MOSTAH-007",
        @"MOSTAH-008",
        @"MOSTAH-009",
        @"MOSTAH-010",
        @"MOSTAH-011",
        @"MOSTAH-012",
        @"MOSTAH-013",
        @"MOSTAH-014",
        @"MOSTAH-015",
        @"MOSTAH-016",
        @"MOSTAH-017",
        @"MOSTAH-018",
        @"MOSTAH-019",
        @"MOSTAH-020"
    ];
}

// جلب معرف الجهاز
- (NSString *)deviceID {
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv ?: @"unknown_device";
}

// تحقق من التفعيل
- (BOOL)validateCode:(NSString *)code {

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];

    // إذا الجهاز مفعّل مسبقًا
    if ([def boolForKey:@"activated"]) {
        return YES;
    }

    // تحقق من الكود
    if ([[self validCodes] containsObject:code]) {

        // تحقق هل الكود مستخدم قبل
        NSString *usedKey = [NSString stringWithFormat:@"used_%@", code];
        if ([def boolForKey:usedKey]) {
            return NO; // مستخدم قبل
        }

        // حفظ التفعيل
        [def setBool:YES forKey:@"activated"];
        [def setObject:[self deviceID] forKey:@"device_id"];
        [def setBool:YES forKey:usedKey];

        [def synchronize];

        return YES;
    }

    return NO;
}

@end

#import "DeviceID.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>

@implementation DeviceID

+ (NSString *)getOrCreateKeychainID {

    NSString *service = @"com.mostah.deviceid";
    NSString *account = @"device";

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (status == errSecSuccess && result) {

        NSData *data = (__bridge_transfer NSData *)result;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    // 🔥 إنشاء ID جديد
    NSString *newID = [self createRawDeviceID];
    NSData *data = [newID dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *addQuery = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecAttrAccount: account,
        (__bridge id)kSecValueData: data
    };

    OSStatus addStatus = SecItemAdd((__bridge CFDictionaryRef)addQuery, NULL);

    // 🔥 إذا فشل الإضافة نحاول update
    if (addStatus != errSecSuccess) {

        NSDictionary *updateQuery = @{
            (__bridge id)kSecAttrService: service,
            (__bridge id)kSecAttrAccount: account
        };

        NSDictionary *updateFields = @{
            (__bridge id)kSecValueData: data
        };

        SecItemUpdate((__bridge CFDictionaryRef)updateQuery,
                      (__bridge CFDictionaryRef)updateFields);
    }

    return newID;
}

+ (NSString *)createRawDeviceID {

    UIDevice *device = [UIDevice currentDevice];

    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *model = device.model ?: @"unknown";
    NSString *system = device.systemVersion ?: @"unknown";

    NSString *raw = [NSString stringWithFormat:@"%@|%@|%@", uuid, model, system];

    const char *cStr = [raw UTF8String];

    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(cStr, (CC_LONG)strlen(cStr), digest);

    NSMutableString *hash = [NSMutableString string];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", digest[i]];
    }

    return hash;
}

+ (NSString *)generate {
    return [self getOrCreateKeychainID];
}

@end

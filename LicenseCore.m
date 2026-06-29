#import "LicenseCore.h"
#import "DeviceID.h"
#import <Security/Security.h>

@implementation LicenseCore

+ (instancetype)shared {
    static LicenseCore *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [LicenseCore new];
    });
    return obj;
}

#pragma mark - Activation

- (BOOL)isActivated {

    NSString *flag = [self load:@"activated_flag"];
    return flag != nil;
}

- (BOOL)validate:(NSString *)code {

    NSString *device = [DeviceID get];

    NSString *saved = [self load:code];

    if (saved && ![saved isEqualToString:device]) {
        return NO;
    }

    return YES;
}

- (void)activate:(NSString *)code {

    NSString *device = [DeviceID get];

    [self save:code value:device];
    [self save:@"activated_flag" value:@"1"];
}

#pragma mark - Secure Keychain

- (void)save:(NSString *)key value:(NSString *)value {

    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecValueData: data
    };

    SecItemDelete((__bridge CFDictionaryRef)query);
    SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

- (NSString *)load:(NSString *)key {

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: @YES
    };

    CFTypeRef dataRef = NULL;

    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataRef) == noErr) {

        NSData *data = (__bridge NSData *)dataRef;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return nil;
}

@end

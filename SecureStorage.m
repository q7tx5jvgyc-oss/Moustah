#import "SecureStorage.h"
#import <Security/Security.h>

@implementation SecureStorage

+ (void)setValue:(NSString *)value forKey:(NSString *)key {

    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key
    };

    SecItemDelete((__bridge CFDictionaryRef)query);

    NSDictionary *item = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecValueData: data
    };

    SecItemAdd((__bridge CFDictionaryRef)item, NULL);
}

+ (NSString *)getValueForKey:(NSString *)key {

    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrAccount: key,
        (__bridge id)kSecReturnData: @YES
    };

    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);

    if (!result) return nil;

    NSData *data = (__bridge NSData *)result;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

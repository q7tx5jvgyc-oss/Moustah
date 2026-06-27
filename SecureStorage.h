#import <Foundation/Foundation.h>

@interface SecureStorage : NSObject

+ (void)setValue:(NSString *)value forKey:(NSString *)key;
+ (NSString *)getValueForKey:(NSString *)key;

@end

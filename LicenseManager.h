#import <Foundation/Foundation.h>

@interface LicenseManager : NSObject
+ (instancetype)shared;
- (BOOL)isActivated;
- (BOOL)validateCode:(NSString *)code;
@end

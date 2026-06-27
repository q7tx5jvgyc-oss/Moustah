#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LicenseType) {
    LicenseTypeInvalid,
    LicenseTypeDaily,
    LicenseTypePermanent
};

@interface LicenseManager : NSObject

+ (instancetype)shared;

- (LicenseType)validateCode:(NSString *)code;
- (BOOL)isActivated;

@end

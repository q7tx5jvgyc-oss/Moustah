#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

+ (instancetype)shared;

@property (nonatomic, assign) BOOL isActivated;

- (void)loadConfig;
- (void)saveConfig;

@end

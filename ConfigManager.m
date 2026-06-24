#import "ConfigManager.h"

@implementation ConfigManager

+ (instancetype)shared {
    static ConfigManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [ConfigManager new];
    });
    return obj;
}

- (void)loadConfig {
    self.isActivated = [[NSUserDefaults standardUserDefaults] boolForKey:@"isActivated"];
}

- (void)saveConfig {
    [[NSUserDefaults standardUserDefaults] setBool:self.isActivated forKey:@"isActivated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

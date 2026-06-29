#import "CoreEngine.h"
#import "OverlaySystem.h"
#import "LicenseCore.h"
#import "SecurityGuardian.h"

@implementation CoreEngine

+ (void)boot {

    dispatch_async(dispatch_get_main_queue(), ^{

        // 🔒 Security check first
        if (![SecurityGuardian isSafeEnvironment]) {
            return;
        }

        // 🧠 Initialize overlay system
        [[OverlaySystem shared] initialize];

        // 🔐 License check
        if ([[LicenseCore shared] isActivated]) {
            [[OverlaySystem shared] showFloating];
        } else {
            [[OverlaySystem shared] showVerification];
        }
    });
}

@end

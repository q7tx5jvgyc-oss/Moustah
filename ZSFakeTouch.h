#import <UIKit/UIKit.h>

@interface ZSFakeTouch : NSObject

// الدالة البرمجية المسؤولة عن إرسال النقرة الحقيقية للنظام عبر الإحداثيات
+ (void)pointTap:(CGPoint)point;

@end

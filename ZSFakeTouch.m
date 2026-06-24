#import "ZSFakeTouch.h"
#import <objc/runtime.h>

// تعريف الهياكل الداخلية لنظام iOS والمسؤولة عن ضخ أحداث اللمس (IOHIDEvent)
typedef struct {
    int origin;
    int page;
    int usage;
} MostashIOHIDEventData;

@implementation ZSFakeTouch

+ (void)pointTap:(CGPoint)point {
    dispatch_async(dispatch_get_main_queue(), ^{
        // استهداف النافذة الرئيسية النشطة للتطبيق وضخ الحدث بداخلها
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                        if (w.isKeyWindow) { window = w; break; }
                    }
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;
        if (!window && [UIApplication sharedApplication].windows.count > 0) {
            window = [UIApplication sharedApplication].windows.firstObject;
        }
        
        if (!window) return;

        // محاكاة مصفوفة النقرات الطبيعية للـ UIKit لمخادعة حماية اللعبة
        UITouch *touch = [[UITouch alloc] init];
        [touch setPhase:UITouchPhaseBegan];
        
        // تعيين إحداثيات النقرة داخل النافذة
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([touch respondsToSelector:@selector(setWindow:)]) {
            [touch performSelector:@selector(setWindow:) withObject:window];
        }
        #pragma clang diagnostic pop
        
        // إرسال كود اللمس الحقيقي المبني على مستوى الأوامر اللاسلكية للنظام
        UIEvent *event = [[UIApplication sharedApplication] performSelector:@selector(_touchesEvent)];
        
        // استدعاء المكونات الأساسية للـ Runtime لضخ النقرة
        CGPoint convertedPoint = [window convertPoint:point toView:window.rootViewController.view];
        UIView *hitView = [window.rootViewController.view hitTest:convertedPoint withEvent:event];
        
        if (hitView) {
            NSMutableSet *touches = [[NSMutableSet alloc] initWithObjects:touch, nil];
            
            // تنفيذ دورة اللمس البشرية الكاملة (Began -> Ended)
            if ([hitView respondsToSelector:@selector(touchesBegan:withEvent:)]) {
                [hitView touchesBegan:touches withEvent:event];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [touch setPhase:UITouchPhaseEnded];
                    [hitView touchesEnded:touches withEvent:event];
                });
            }
        }
    });
}

@end

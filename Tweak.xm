#import <UIKit/UIKit.h>

// متغير عام للاحتفاظ بالنافذة في الذاكرة حتى لا تختفي
static UIWindow *menuWindow = nil;

__attribute__((constructor))
static void load() {

    // تأخير التفعيل قليلاً (2 ثانية) لضمان إقلاع اللعبة بالكامل واستقرار النظام
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC),
                   dispatch_get_main_queue(), ^{

        NSLog(@"🔥 DYLIB LOADED: CREATING OVERLAY WINDOW...");

        // 1. إنشاء نافذة جديدة مخصصة للتويك بحجم الشاشة كاملة
        menuWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        // 2. ضبط مستوى النافذة لتكون فوق اللعبة وفوق أي تنبيهات نظام أخرى
        menuWindow.windowLevel = UIWindowLevelAlert + 100;
        
        // 3. جعل خلفية النافذة شفافة تماماً لكي ترى اللعبة خلفها
        menuWindow.backgroundColor = [UIColor clearColor];
        
        // 4. إنشاء شاشة تحكم رئيسية (Root VC) لمنع انهيار اللعبة (Crash) في نظام iOS الحديث
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor clearColor];
        
        // منع النافذة من حجب اللمس عن الأماكن الفارغة في اللعبة
        rootVC.view.userInteractionEnabled = YES; 
        menuWindow.rootViewController = rootVC;

        // 5. إنشاء الزر الأحمر الخاص بك وإضافته داخل النافذة الجديدة
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(100, 200, 80, 80);
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"M" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        // تدوير زوايا الزر ليكون دائرياً كالعادة في الأزرار العائمة
        btn.layer.cornerRadius = 40; 
        btn.clipsToBounds = YES;

        // إضافة الزر إلى شاشة النافذة الخاصة بنا
        [menuWindow addSubview:btn];

        // 6. إظهار النافذة وجعلها مرئية فوق اللعبة
        [menuWindow makeKeyAndVisible];
        
        NSLog(@"🔥 OVERLAY WINDOW IS NOW VISIBLE ABOVE THE GAME!");
    });
}

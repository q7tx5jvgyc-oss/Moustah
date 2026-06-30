TARGET := iphone:clang:latest:14.0

# 🌟 تحديث: إضافة معمارية arm64e لدعم الأجهزة الحديثة ومحركات الألعاب
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MostashClicker

MostashClicker_FILES = \
    Tweak.xm \
    ClickEngine.m \
    ClickManager.m \
    ConfigManager.m \
    ControlPanelView.m \
    DeviceID.m \
    FloatingButton.m \
    LicenseManager.m \
    MostashUI.m \
    OverlayManager.m \
    SceneDelegate.m \
    SecureStorage.m \
    TargetModel.m \
    Verification.m \
    ZSFakeTouch.m \
    AppDelegate.m \
    ActivationViewController.m

# 🌟 تحديث: إضافة CoreGraphics لضمان معالجة إحداثيات ومواقع الأزرار والمربع
MostashClicker_FRAMEWORKS = UIKit Foundation QuartzCore CoreGraphics

# تفعيل إدارة الذاكرة التلقائية لمنع كراش اللعبة بسبب استهلاك الذاكرة
MostashClicker_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

# أمر اختياري لإعادة تشغيل اللعبة فوراً وتجربة الواجهة الأسطورية بعد التثبيت
after-install::
	install.exec "killall -9 YallaLudo || true"

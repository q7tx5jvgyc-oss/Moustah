TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MostashClicker

# هذه هي جميع ملفات السورس القابلة للبناء والموجودة في قائمتك (18 ملفاً)
# بقية الملفات الـ 45 هي ملفات (.h) ومجلدات يتم تضمينها تلقائياً أثناء المراجعة
MostashClicker_FILES = Tweak.xm \
                       ActivationViewController.m \
                       AppDelegate.m \
                       ClickEngine.m \
                       ClickManager.m \
                       ConfigManager.m \
                       ControlPanelView.m \
                       FloatingButton.m \
                       LicenseManager.m \
                       MenuPanel.m \
                       MostashUI.m \
                       OverlayManager.m \
                       SceneDelegate.m \
                       TapEvent.m \
                       TapRecorder.m \
                       TargetModel.m \
                       Verification.m \
                       ZSFakeTouch.m

MostashClicker_FRAMEWORKS = UIKit Foundation CoreGraphics

# تفعيل التجميع التلقائي وإدارة الذاكرة لضمان عمل كافة الملفات معاً بدون تعارض
MostashClicker_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

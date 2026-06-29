TARGET := iphone:clang:latest:14.0
ARCHS = arm64

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

MostashClicker_FRAMEWORKS = UIKit Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

TARGET := iphone:clang:latest:14.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MostashClicker

MostashClicker_FILES = Tweak.xm ClickManager.m MenuPanel.m FloatingButton.m
MostashClicker_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

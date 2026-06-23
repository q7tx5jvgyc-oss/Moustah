TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = MostashClicker

MostashClicker_FILES = Tweak.xm FloatingButton.m MenuPanel.m ClickManager.m
MostashClicker_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

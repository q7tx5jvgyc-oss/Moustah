TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MostashClicker

# هنا نخبر المترجم ببناء ملف التويك وملف مكتبة اللمس معاً
MostashClicker_FILES = Tweak.xm ZSFakeTouch.m
MostashClicker_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

TARGET := iphone:clang:latest:14.0

TWEAK_NAME = MostashClicker

MostashClicker_FILES = Tweak.xm
MostashClicker_FRAMEWORKS = UIKit Foundation

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

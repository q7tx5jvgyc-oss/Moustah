TARGET := iphone:clang:latest:14.0
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MostashClicker

# هنا تم إبقاء ملف Tweak.xm فقط لمنع أي تعارض أثناء الحقن بـ Ksign
MostashClicker_FILES = Tweak.xm
MostashClicker_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

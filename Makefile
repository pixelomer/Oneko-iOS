TARGET := iphone:13.7:13.0
ARCHS = arm64e arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Oneko

Oneko_FILES = Oneko.m resources.m Tweak.xm
Oneko_CFLAGS = -include macros.h -Wno-deprecated-declarations
Tweak.x_CFLAGS = -fobjc-arc
resources.m_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
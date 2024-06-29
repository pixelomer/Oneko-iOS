ifeq ($(SIMULATOR),1)
TARGET := simulator:clang::14.0
ARCHS = arm64
else
TARGET := iphone:15.6:15.0
ARCHS = arm64e arm64
INSTALL_TARGET_PROCESSES = SpringBoard
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Oneko

Oneko_FILES = Oneko.m resources.m Tweak.xm
Oneko_CFLAGS = -include macros.h -Wno-deprecated-declarations
Tweak.xm_CFLAGS = -fobjc-arc
resources.m_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

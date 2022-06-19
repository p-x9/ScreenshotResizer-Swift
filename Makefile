DEBUG = 0
GO_EASY_ON_ME := 1

ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:15.0
THEOS_DEVICE_IP = 192.168.0.15 -p 22

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = screenshotresizer

$(TWEAK_NAME)_FILES = $(shell find Sources/ScreenShotResizer -name '*.swift') $(shell find Sources/ScreenShotResizerC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
$(TWEAK_NAME)_SWIFTFLAGS = -ISources/ScreenShotResizerC/include
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -ISources/ScreenShotResizerC/include

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += ssrpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

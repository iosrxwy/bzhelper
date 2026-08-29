ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BZDeviceSpoofExample
BZDeviceSpoofExample_FILES = BZDeviceSpoof.m BZFishhook.c
BZDeviceSpoofExample_CFLAGS = -fobjc-arc
BZDeviceSpoofExample_FRAMEWORKS = Foundation UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk

LOCAL_CFLAGS += -DHAVE_CONFIG_H -DKHTML_NO_EXCEPTIONS -DGKWQ_NO_JAVA
LOCAL_CFLAGS += -DNO_SUPPORT_JS_BINDING -DQT_NO_WHEELEVENT -DKHTML_NO_XBL
LOCAL_CFLAGS += -U__APPLE__
LOCAL_CFLAGS += -Wno-unused-parameter
LOCAL_CFLAGS += -Wno-non-virtual-dtor
LOCAL_CFLAGS += -Wno-maybe-uninitialized -Wno-parentheses
LOCAL_CPPFLAGS += -Wno-conversion-null

ifeq ($(TARGET_ARCH), arm)
    LOCAL_CFLAGS += -DPACKED="__attribute__ ((packed))"
else
    LOCAL_CFLAGS += -DPACKED=""
endif

ifneq ($(ENABLE_CPUSETS),)
    LOCAL_CFLAGS += -DENABLE_CPUSETS
endif

ifneq ($(ENABLE_SCHED_BOOST),)
    LOCAL_CFLAGS += -DENABLE_SCHED_BOOST
endif

LOCAL_CFLAGS += -DGL_GLEXT_PROTOTYPES -DEGL_EGLEXT_PROTOTYPES

LOCAL_CFLAGS += -DU_USING_ICU_NAMESPACE=0

LOCAL_SRC_FILES:= \
    AndroidRuntime.cpp

LOCAL_C_INCLUDES += \
    $(JNI_H_INCLUDE) \
    $(LOCAL_PATH)/android/graphics \
    $(LOCAL_PATH)/../../libs/hwui \
    $(LOCAL_PATH)/../../../native/opengl/libs \
    $(call include-path-for, bluedroid) \
    $(call include-path-for, libhardware)/hardware \
    $(call include-path-for, libhardware_legacy)/hardware_legacy \
    $(TOP)/frameworks/av/include \
    $(TOP)/frameworks/base/media/jni \
    $(TOP)/system/media/camera/include \
    $(TOP)/system/netd/include \
    $(TOP)/frameworks/base/core/jni \
    external/pdfium/core/include/fpdfapi \
    external/pdfium/core/include/fpdfdoc \
    external/pdfium/fpdfsdk/include \
    external/pdfium/public \
    external/skia/src/core \
    external/skia/src/effects \
    external/skia/src/images \
    external/sqlite/dist \
    external/sqlite/android \
    external/expat/lib \
    external/tremor/Tremor \
    external/jpeg \
    external/harfbuzz_ng/src \
    frameworks/opt/emoji \
    libcore/include \
    $(call include-path-for, audio-utils) \
    frameworks/minikin/include \
    external/freetype/include
# TODO: clean up Minikin so it doesn't need the freetype include

LOCAL_SHARED_LIBRARIES := \
    libmemtrack \
    libandroidfw \
    libexpat \
    libnativehelper \
    liblog \
    libcutils \
    libutils \
    libbinder \
    libnetutils \
    libui \
    libgui \
    libinput \
    libinputflinger \
    libcamera_client \
    libcamera_metadata \
    libskia \
    libsqlite \
    libEGL \
    libGLESv1_CM \
    libGLESv2 \
    libETC1 \
    libhardware \
    libhardware_legacy \
    libselinux \
    libsonivox \
    libcrypto \
    libssl \
    libicuuc \
    libicui18n \
    libmedia \
    libjpeg \
    libusbhost \
    libharfbuzz_ng \
    libz \
    libaudioutils \
    libpdfium \
    libimg_utils \
    libnetd_client \
    libradio \
    libsoundtrigger \
    libminikin \
    libprocessgroup \
    libnativebridge \
	libandroid_runtime \
    libradio_metadata

LOCAL_SHARED_LIBRARIES += \
    libhwui \
    libdl

# we need to access the private Bionic header
# <bionic_tls.h> in com_google_android_gles_jni_GLImpl.cpp
LOCAL_C_INCLUDES += bionic/libc/private

LOCAL_MODULE:= libbruce_runtime

# -Wno-unknown-pragmas: necessary for Clang as the GL bindings need to turn
#                       off a GCC warning that Clang doesn't know.
LOCAL_CFLAGS += -Wall -Werror -Wno-error=deprecated-declarations -Wunused -Wunreachable-code \
        -Wno-unknown-pragmas

# -Wno-c++11-extensions: Clang warns about Skia using the C++11 override keyword, but this project
#                        is not being compiled with that level. Remove once this has changed.
LOCAL_CFLAGS += -Wno-c++11-extensions

# b/22414716: thread_local (android/graphics/Paint.cpp) and Clang don't like each other at the
#             moment.
LOCAL_CLANG := false

include $(BUILD_SHARED_LIBRARY)

include $(call all-makefiles-under,$(LOCAL_PATH))

#!/bin/bash

#SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd)
SCRIPT_PATH="/Volumes/android/android-6.0.1/third-party/framework/base"
LIBBRUCE_RUNTIME_PATH=$SCRIPT_PATH"/core/jni/"
APP_PROCESS_PATH=$SCRIPT_PATH"/cmd/app_process/"
ADB=/Users/yutao/Library/Android/sdk/platform-tools/adb

pushd $LIBBRUCE_RUNTIME_PATH
mm && $ADB push $ANDROID_PRODUCT_OUT/system/lib64/libbruce_runtime.so /data/data/cn.bruce.yu/libbruce_runtime.so
popd


pushd $APP_PROCESS_PATH
mm && $ADB push $ANDROID_PRODUCT_OUT/system/bin/app_process64_bruce /data/data/cn.bruce.yu/app_process64_bruce
popd

mm && $ADB push $ANDROID_PRODUCT_OUT/system/framework/framework_bruce.jar /data/data/cn.bruce.yu/framework_bruce.jar

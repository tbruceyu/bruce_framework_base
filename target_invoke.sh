#!/system/bin/sh
#BASE_APP_DIR=/data/app/io.virtualapp-2/
#BASE_DATA_DIR=/data/data/io.virtualapp
export CLASSPATH=$BASE_APP_DIR/base.apk
export LD_LIBRARY_PATH=$BASE_DATA_DIR
./app_process64_bruce com.tby.main.RuntimeInit cn.bruce.yu 12456

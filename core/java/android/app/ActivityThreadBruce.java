/*
 * Copyright (C) 2006 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package android.app;

import android.os.Environment;
import android.os.Looper;
import android.os.Process;
import android.os.Trace;
import android.os.UserHandle;
import android.security.keystore.AndroidKeyStoreProvider;
import android.util.EventLog;
import android.util.Log;
import android.util.LogPrinter;
import android.util.Singleton;

import com.android.internal.os.SamplingProfilerIntegration;
import com.android.org.conscrypt.TrustedCertificateStore;

import java.io.File;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import dalvik.system.CloseGuard;
import libcore.io.EventLogger;

public class ActivityThreadBruce {

    private static final Singleton<IActivityManager> gDefault = new Singleton<IActivityManager>() {
        protected IActivityManager create() {
            Object stubActivityManager = Proxy.newProxyInstance(IActivityManager.class.getClassLoader(),
                    new Class<?>[]{IActivityManager.class}, new InvocationHandler() {
                        @Override
                        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                            if (method.getName().equals("attachApplication")) {
                                Log.d("yutao", "attachApplication");
                                return null;
                            } else return null;
                        }
                    });

            return (IActivityManager) stubActivityManager;
        }
    };

    public static void main(String[] args) {
        try {
            Log.e("yutao", "Activity thread started!");
            Trace.traceBegin(Trace.TRACE_TAG_ACTIVITY_MANAGER, "ActivityThreadMain");
            SamplingProfilerIntegration.start();

            // CloseGuard defaults to true and can be quite spammy.  We
            // disable it here, but selectively enable it later (via
            // StrictMode) on debug builds, but using DropBox, not logs.
            CloseGuard.setEnabled(false);

            Environment.initForCurrentUser();

            // Set the reporter for event logging in libcore
            EventLogger.setReporter(new EventLoggingReporter());

            AndroidKeyStoreProvider.install();

            // Make sure TrustedCertificateStore looks in the right place for CA certificates
            final File configDir = Environment.getUserConfigDirectory(UserHandle.myUserId());
            TrustedCertificateStore.setDefaultUserDirectory(configDir);

            Process.setArgV0("<pre-initialized>");

            Log.e("yutao", "2222222");
            Looper.prepareMainLooper();

            // New ActivityThread object here
            ClassLoader classLoader = ClassLoader.getSystemClassLoader();
            Class<?> activityThreadClass = classLoader.loadClass("android.app.ActivityThread");
            Constructor constructor = activityThreadClass.getDeclaredConstructor();
            constructor.setAccessible(true);
            ActivityThread thread = (ActivityThread) constructor.newInstance();
            Log.e("yutao", "prepare to attach");
            //thread.attach(false);
            // set gDefault
            Class<ActivityManagerNative> activityManagerNativeClass = ActivityManagerNative.class;
            Field gDefaultField = activityManagerNativeClass.getDeclaredField("gDefault");
            gDefaultField.setAccessible(true);
            gDefaultField.set(activityManagerNativeClass, gDefault);
            // Call attach
            Method attachMethod = activityThreadClass.getDeclaredMethod("attach", new Class[]{boolean.class});
            attachMethod.setAccessible(true);
            attachMethod.invoke(thread, false);

            // set mainThreadHandler
            Field sMainThreadHandlerField = activityThreadClass.getDeclaredField("sMainThreadHandler");
            sMainThreadHandlerField.setAccessible(true);
            if (sMainThreadHandlerField.get(activityThreadClass) == null) {
                Method handlerMethod = activityThreadClass.getDeclaredMethod("getHandler");
                handlerMethod.setAccessible(true);
                sMainThreadHandlerField.set(activityThreadClass, handlerMethod.invoke(thread));
            }

            if (false) {
                Looper.myLooper().setMessageLogging(new
                        LogPrinter(Log.DEBUG, "ActivityThread"));
            }

            // End of event ActivityThreadMain.
            Trace.traceEnd(Trace.TRACE_TAG_ACTIVITY_MANAGER);
            Looper.loop();
        } catch (Throwable e) {
            e.printStackTrace();
        }

        throw new RuntimeException("Main thread loop unexpectedly exited");
    }

    private static class EventLoggingReporter implements EventLogger.Reporter {
        @Override
        public void report(int code, Object... list) {
            EventLog.writeEvent(code, list);
        }
    }
}

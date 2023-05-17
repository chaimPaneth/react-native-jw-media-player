//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.appgoalz.rnjwplayer.session;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import androidx.annotation.Nullable;
import androidx.media.session.MediaButtonReceiver;

import com.jwplayer.pub.api.background.ServiceMediaApi;

public class RNJWMediaService extends Service {
    protected final IBinder a = new Binder();
    protected RNJWMediaSessionHelper b;

    public RNJWMediaService() {
    }

    public void doStartForeground(RNJWMediaSessionHelper mediaSessionHelper, RNJWNotificationHelper notificationHelper, ServiceMediaApi serviceMediaApi) {
        if (this.b != null) {
            this.b.a();
        }

        this.b = mediaSessionHelper;
        Notification mediaSessionHelper1 = notificationHelper.a(this.b.b, this.b.a, serviceMediaApi);
        this.startForeground(notificationHelper.b, mediaSessionHelper1);
    }

    public int onStartCommand(Intent intent, int flags, int startId) {
        if (this.b != null) {
            MediaButtonReceiver.handleIntent(this.b.a.a, intent);
        }

        return Service.START_STICKY;
    }

    @Nullable
    public IBinder onBind(Intent intent) {
        return this.a;
    }

    public boolean onUnbind(Intent intent) {
        if (this.b != null) {
            this.b.a();
        }

        this.stopForeground(true);
        this.stopSelf();
        return false;
    }

    public void onDestroy() {
        if (this.b != null) {
            this.b.a();
        }

    }

    public class Binder extends android.os.Binder {
        public Binder() {
        }

        public RNJWMediaService getService() {
            return RNJWMediaService.this;
        }
    }
}

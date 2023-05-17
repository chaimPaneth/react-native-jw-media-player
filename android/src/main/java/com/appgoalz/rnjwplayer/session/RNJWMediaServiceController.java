//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.appgoalz.rnjwplayer.session;

import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.appgoalz.rnjwplayer.misc.a;
import com.jwplayer.pub.api.JWPlayer;
import com.jwplayer.pub.api.background.ServiceMediaApi;

public class RNJWMediaServiceController implements ServiceConnection {
    protected RNJWMediaService a;
    protected AppCompatActivity b;
    protected RNJWNotificationHelper c;
    protected RNJWMediaSessionHelper d;
    protected ServiceMediaApi e;
    protected Class<? extends RNJWMediaService> f;
    private com.appgoalz.rnjwplayer.misc.a g;

    protected RNJWMediaServiceController(AppCompatActivity activity, RNJWNotificationHelper notificationHelper, RNJWMediaSessionHelper mediaSessionHelper, ServiceMediaApi serviceMediaApi, Class<? extends RNJWMediaService> mediaServiceClass, a bgaFactory) {
        this.b = activity;
        this.c = notificationHelper;
        this.d = mediaSessionHelper;
        this.e = serviceMediaApi;
        this.f = mediaServiceClass;
        this.g = bgaFactory;
    }

    public void updateServiceMediaApi(@NonNull ServiceMediaApi serviceMediaApi) {
        if (serviceMediaApi != null) {
            serviceMediaApi.getPlayer().allowBackgroundAudio(true);
            this.e = serviceMediaApi;
            this.d.a(serviceMediaApi);
        }

    }

    public void bindService() {
        if (this.a == null) {
            Class var2 = this.f;
            AppCompatActivity var1 = this.b;
            this.b.bindService(new Intent(var1, var2), this, Context.BIND_AUTO_CREATE);
        }

    }

    public void unbindService() {
        if (this.a != null) {
            this.e.getPlayer().allowBackgroundAudio(false);
            this.b.unbindService(this);
            this.a = null;
        }

        this.b = null;
    }

    public void onServiceConnected(ComponentName name, IBinder service) {
        this.a = ((RNJWMediaService.Binder)service).getService();
        this.a.doStartForeground(this.d, this.c, this.e);
        this.e.getPlayer().allowBackgroundAudio(true);
    }

    public void onServiceDisconnected(ComponentName name) {
        this.a = null;
    }

    public static class Builder {
        protected AppCompatActivity a;
        protected RNJWNotificationHelper b;
        protected RNJWMediaSessionHelper c;
        protected ServiceMediaApi d;
        protected Class<? extends RNJWMediaService> e;
        protected a f;

        public Builder(AppCompatActivity activity, JWPlayer player) {
            this(activity, player, new a());
        }

        private Builder(AppCompatActivity activity, JWPlayer player, a factory) {
            this.a = activity;
            this.f = factory;
            this.b = (new RNJWNotificationHelper.Builder((NotificationManager)activity.getSystemService(Context.NOTIFICATION_SERVICE))).build();
            this.d = new ServiceMediaApi(player);
            AppCompatActivity var10001 = activity;
            ServiceMediaApi player1 = this.d;
            RNJWNotificationHelper activity1 = this.b;
            AppCompatActivity factory1 = var10001;
            this.c = new RNJWMediaSessionHelper(factory1, activity1, player1);
            this.e = RNJWMediaService.class;
        }

        public Builder notificationHelper(RNJWNotificationHelper notificationHelper) {
            this.b = notificationHelper;
            return this;
        }

        public Builder serviceMediaApi(ServiceMediaApi serviceMediaApi) {
            this.d = serviceMediaApi;
            return this;
        }

        public Builder mediaSessionHelper(RNJWMediaSessionHelper mediaSessionHelper) {
            this.c = mediaSessionHelper;
            return this;
        }

        public RNJWMediaServiceController build() {
            return new RNJWMediaServiceController(this.a, this.b, this.c, this.d, this.e, this.f);
        }
    }
}

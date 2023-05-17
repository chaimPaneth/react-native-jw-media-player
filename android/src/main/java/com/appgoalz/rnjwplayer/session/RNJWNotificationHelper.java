//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.appgoalz.rnjwplayer.session;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build.VERSION;
import android.support.v4.media.MediaDescriptionCompat;
import android.support.v4.media.session.MediaSessionCompat;

import androidx.core.app.NotificationCompat;

import com.appgoalz.rnjwplayer.misc.a;
import com.jwplayer.pub.api.background.ServiceMediaApi;
import com.longtailvideo.jwplayer.R.drawable;

public class RNJWNotificationHelper extends MediaSessionCompat.Callback {
    final NotificationManager a;
    private NotificationChannel c;
    private final int d;
    final int b;
    private final String e;
    private final String f;
    private final String g;
    private final com.appgoalz.rnjwplayer.misc.a h;

    protected RNJWNotificationHelper(NotificationManager notificationManager, int iconDrawableResource, int notificationId, String notificationChannelId, String channelNameDisplayedToUser, String channelDescription, a factory) {
        this.a = notificationManager;
        this.d = iconDrawableResource;
        this.b = notificationId;
        this.e = notificationChannelId;
        this.f = channelNameDisplayedToUser;
        this.g = channelDescription;
        this.h = factory;
        if (VERSION.SDK_INT >= 26) {
            String notificationId1 = this.f;
            String iconDrawableResource1 = this.e;
            this.c = new NotificationChannel(iconDrawableResource1, notificationId1, NotificationManager.IMPORTANCE_LOW);
            this.c.setDescription(this.g);
            this.c.setShowBadge(false);
            this.c.setLockscreenVisibility(1);
            this.a.createNotificationChannel(this.c);
        }

    }

    final Notification a(Context var1, com.appgoalz.rnjwplayer.misc.b var2, ServiceMediaApi var3) {
        MediaDescriptionCompat var4 = var2.a.getController().getMetadata().getDescription();
        String var7 = this.e;
        NotificationCompat.Builder var5 = new NotificationCompat.Builder(var1, var7);
        var3.addNotificationActions(var1, var5);
        var5.setContentTitle(var4.getTitle()).setContentText(var4.getSubtitle()).setSubText(var4.getDescription()).setLargeIcon(var4.getIconBitmap()).setOnlyAlertOnce(true).setStyle((new androidx.media.app.NotificationCompat.MediaStyle()).setMediaSession(var2.a.getSessionToken()).setShowActionsInCompactView(var3.getCompactActions())).setVisibility(NotificationCompat.VISIBILITY_PUBLIC).setSmallIcon(this.d).setDeleteIntent(var3.getActionIntent(var1, 86));
        Intent var9;
        (var9 = new Intent(var1, var1.getClass())).setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        var5.setContentIntent(PendingIntent.getActivity(var1, 0, var9, PendingIntent.FLAG_IMMUTABLE));
        Notification var8 = var5.build();
        this.a.notify(this.b, var8);
        return var8;
    }

    public static class Builder {
        protected NotificationManager a;
        protected a b;
        protected int c;
        protected int d;
        protected String e;
        protected String f;
        protected String g;

        public Builder(NotificationManager notificationManager) {
            this(notificationManager, new a());
        }

        private Builder(NotificationManager manager, a factory) {
            this.c = drawable.ic_jw_play;
            this.d = 2005;
            this.e = "NotificationBarController";
            this.f = "Player Notification";
            this.g = "Control playback of the media player";
            this.a = manager;
            this.b = factory;
        }

        public Builder iconDrawableResource(int iconDrawableResource) {
            this.c = iconDrawableResource;
            return this;
        }

        public Builder notificationId(int notificationId) {
            this.d = notificationId;
            return this;
        }

        public Builder notificationChannelId(String notificationChannelId) {
            this.e = notificationChannelId;
            return this;
        }

        public Builder channelNameDisplayedToUser(String channelNameDisplayedToUser) {
            this.f = channelNameDisplayedToUser;
            return this;
        }

        public Builder channelDescription(String channelDescription) {
            this.g = channelDescription;
            return this;
        }

        public RNJWNotificationHelper build() {
            return new RNJWNotificationHelper(this.a, this.c, this.d, this.e, this.f, this.g, this.b);
        }
    }
}

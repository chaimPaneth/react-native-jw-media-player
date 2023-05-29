//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.appgoalz.rnjwplayer.session;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import com.appgoalz.rnjwplayer.misc.a;
import com.appgoalz.rnjwplayer.misc.b;
import com.appgoalz.rnjwplayer.misc.c;
import com.jwplayer.pub.api.JWPlayer;
import com.jwplayer.pub.api.PlayerState;
import com.jwplayer.pub.api.background.ServiceMediaApi;
import com.jwplayer.pub.api.events.AdCompleteEvent;
import com.jwplayer.pub.api.events.AdErrorEvent;
import com.jwplayer.pub.api.events.AdPlayEvent;
import com.jwplayer.pub.api.events.AdSkippedEvent;
import com.jwplayer.pub.api.events.BufferEvent;
import com.jwplayer.pub.api.events.ErrorEvent;
import com.jwplayer.pub.api.events.EventType;
import com.jwplayer.pub.api.events.PauseEvent;
import com.jwplayer.pub.api.events.PlayEvent;
import com.jwplayer.pub.api.events.PlaylistCompleteEvent;
import com.jwplayer.pub.api.events.PlaylistItemEvent;
import com.jwplayer.pub.api.events.listeners.AdvertisingEvents;
import com.jwplayer.pub.api.events.listeners.VideoPlayerEvents;
import com.jwplayer.pub.api.media.playlists.PlaylistItem;
import com.longtailvideo.jwplayer.o.f;
import com.mediabrowser.MediaSessionSingleton;

public class RNJWMediaSessionHelper implements AdvertisingEvents.OnAdCompleteListener, AdvertisingEvents.OnAdErrorListener, AdvertisingEvents.OnAdPlayListener, AdvertisingEvents.OnAdSkippedListener, VideoPlayerEvents.OnBufferListener, VideoPlayerEvents.OnErrorListener, VideoPlayerEvents.OnPauseListener, VideoPlayerEvents.OnPlayListener, VideoPlayerEvents.OnPlaylistCompleteListener, VideoPlayerEvents.OnPlaylistItemListener {
    private JWPlayer c;
    private f d;
    com.appgoalz.rnjwplayer.misc.b a;
    private ServiceMediaApi e;
    private final RNJWNotificationHelper f;
    final Context b;
    private final com.appgoalz.rnjwplayer.misc.a g;

    public RNJWMediaSessionHelper(Context context, RNJWNotificationHelper notificationHelper, ServiceMediaApi serviceMediaApi) {
        this(context, notificationHelper, serviceMediaApi, new a());
    }

    private RNJWMediaSessionHelper(Context context, RNJWNotificationHelper notificationHelper, ServiceMediaApi serviceMediaApi, a bgaFactory) {
        this.b = context;
        this.f = notificationHelper;
        this.g = bgaFactory;
        this.a(serviceMediaApi);
    }

    final void a(ServiceMediaApi var1) {
        this.a();
        if (var1 != null) {
            this.c = var1.getPlayer();
            Context var10001 = this.b;
            String var3 = RNJWMediaSessionHelper.class.getSimpleName();
            Context var2 = var10001;
            this.a =  new b(MediaSessionSingleton.getInstance(var2));
//            this.a = new b(new MediaSessionCompat(var2, var3));
            this.e = var1;
            this.a.a.setCallback(var1);
            this.c.addListeners(this, new EventType[]{EventType.PLAY, EventType.PAUSE, EventType.BUFFER, EventType.ERROR, EventType.PLAYLIST_ITEM, EventType.PLAYLIST_COMPLETE, EventType.AD_PLAY, EventType.AD_SKIPPED, EventType.AD_COMPLETE, EventType.AD_ERROR});
            JWPlayer var4 = this.c;
            this.a(var4.getPlaylistItem());
            this.a(var4.getState());
        }

    }

    final void a() {
        RNJWNotificationHelper var1;
        if (this.a != null) {
            this.a.a.setActive(false);
            this.e = null;
            var1 = null;
            this.a.a.setCallback(var1);
            this.a.a.release();
            this.a = null;
        }

        if (this.c != null) {
            this.c.removeListeners(this, new EventType[]{EventType.PLAY, EventType.PAUSE, EventType.BUFFER, EventType.ERROR, EventType.PLAYLIST_ITEM, EventType.PLAYLIST_COMPLETE, EventType.AD_PLAY, EventType.AD_SKIPPED, EventType.AD_COMPLETE, EventType.AD_ERROR});
            (var1 = this.f).a.cancel(var1.b);
            if (this.d != null) {
                this.d.cancel(true);
                this.d = null;
            }

            this.c = null;
        }

    }

    private void a(PlayerState var1) {
        com.appgoalz.rnjwplayer.misc.c var5 = this.a.a();
        c.a var2 = new c.a(var5);
        long var3 = this.e.getNotificationCapabilities();
        var2.a.setActions(var3);
        byte var8 = 0;
        switch (var1) {
            case PLAYING:
                var8 = PlaybackStateCompat.STATE_PLAYING;
                break;
            case PAUSED:
                var8 = PlaybackStateCompat.STATE_PAUSED;
                break;
            case BUFFERING:
                var8 = PlaybackStateCompat.STATE_BUFFERING;
                break;
            case ERROR:
                var8 = PlaybackStateCompat.STATE_ERROR;
                break;
            case IDLE:
            default:
                var8 = PlaybackStateCompat.STATE_STOPPED;
        }

        long var9 = (long)this.c.getPosition();
        var2.a.setState(var8, var9, 1.0F);
        b var10000 = this.a;
        c var10 = new c(var2.a.build());
        var10000.a.setPlaybackState(var10.a);
        boolean var7 = var1 != PlayerState.ERROR && var1 != PlayerState.IDLE;
        this.a.a.setActive(var7);
        if (var7) {
            this.f.a(this.b, this.a, this.e);
        } else {
            RNJWNotificationHelper var11;
            (var11 = this.f).a.cancel(var11.b);
        }
    }

    private void a(PlaylistItem var1) {
        MediaMetadataCompat var2 = null;
        var2 = (null == null ? new MediaMetadataCompat.Builder() : new MediaMetadataCompat.Builder(var2)).putString("android.media.metadata.DISPLAY_TITLE", var1.getTitle()).putString("android.media.metadata.DISPLAY_SUBTITLE", var1.getDescription()).putString("android.media.metadata.MEDIA_ID", var1.getMediaId()).putString("android.media.metadata.ARTIST", this.c.getPlaylistItem().getDescription()).putString("android.media.metadata.TITLE", this.c.getPlaylistItem().getTitle()).build();
        this.a.a.setMetadata(var2);
        if (this.d != null) {
            this.d.cancel(true);
            this.d = null;
        }

        f.a var3 = this::a;
        this.d = new f(var3);
        this.d.execute(new String[]{var1.getImage()});
    }

    public void onPlaylistItem(PlaylistItemEvent playlistItemEvent) {
        this.a(playlistItemEvent.getPlaylistItem());
    }

    public void onError(ErrorEvent errorEvent) {
        this.a(PlayerState.ERROR);
        this.a.a.release();
    }

    public void onAdComplete(AdCompleteEvent adCompleteEvent) {
    }

    public void onAdSkipped(AdSkippedEvent adSkippedEvent) {
    }

    public void onAdPlay(AdPlayEvent adPlayEvent) {
    }

    public void onAdError(AdErrorEvent adErrorEvent) {
    }

    public void onBuffer(BufferEvent bufferEvent) {
        this.a(PlayerState.BUFFERING);
    }

    public void onPause(PauseEvent pauseEvent) {
        this.a(PlayerState.PAUSED);
    }

    public void onPlay(PlayEvent playEvent) {
        this.a(PlayerState.PLAYING);
    }

    public void onPlaylistComplete(PlaylistCompleteEvent playlistCompleteEvent) {
        this.a.a.setActive(false);
        this.a.a.release();
    }

    void a(Bitmap var1) {
        if (this.a != null) {
            MediaMetadataCompat var2;
            MediaMetadataCompat.Builder var4;
            (var4 = (var2 = this.a.a.getController().getMetadata()) == null ? new MediaMetadataCompat.Builder() : new MediaMetadataCompat.Builder(var2)).putBitmap("android.media.metadata.ART", var1);
            b var10000 = this.a;
            MediaMetadataCompat var3 = var4.build();
            var10000.a.setMetadata(var3);
        }

    }
}

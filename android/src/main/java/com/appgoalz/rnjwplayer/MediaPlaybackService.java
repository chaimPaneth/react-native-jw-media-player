package com.appgoalz.rnjwplayer;

import android.app.Notification;
import android.app.Service;
import android.content.Intent;
import android.os.Binder;
import android.os.IBinder;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.media.session.MediaButtonReceiver;

/**
 * Manages the {@link android.media.session.MediaSession} and responds to {@link MediaButtonReceiver}
 * events.
 */
public class MediaPlaybackService extends Service {

	/**
	 * The binder used by clients to access this instance.
	 */
	private final Binder mBinder = new MediaPlaybackServiceBinder();

	/**
	 * The MediaSession used to control this service.
	 */
	private MediaSessionManager mMediaSessionManager;

	@Override
	public void onCreate() {
		super.onCreate();
		startForeground(NotificationWrapper.NOTIFICATION_ID, new NotificationCompat.Builder(this, NotificationWrapper.getNotificationChannel(this)).build());
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		if (mMediaSessionManager != null) {
			MediaButtonReceiver.handleIntent(mMediaSessionManager.getMediaSession(), intent);
		}
		return START_STICKY;
	}

	@Nullable
	@Override
	public IBinder onBind(Intent intent) {
		return mBinder;
	}

	@Override
	public void onDestroy() {
		if (mMediaSessionManager != null) {
			mMediaSessionManager.release();
		}
		stopForeground(true);
	}

	@Override
	public boolean onUnbind(Intent intent) {
		// Stop this service when all clients have been unbound.
		if (mMediaSessionManager != null) {
			mMediaSessionManager.release();
		}
		stopForeground(true);
		stopSelf();
		return false;
	}


	public void setupMediaSession(MediaSessionManager mediaSessionManager,
								  NotificationWrapper notificationWrapper) {

		if (mMediaSessionManager != null) {
			mMediaSessionManager.release();
		}

		mMediaSessionManager = mediaSessionManager;

		Notification notification = notificationWrapper
				.createNotification(mediaSessionManager.getPlayer().getContext(),
									mMediaSessionManager.getMediaSession(),
									mMediaSessionManager
											.getCapabilities(mediaSessionManager.getPlayer()
																				.getState())
				);
		startForeground(NotificationWrapper.NOTIFICATION_ID, notification);
	}


	/**
	 * Clients access this service through this class.
	 * Because we know this service always runs in the same process
	 * as its clients, we don't need to deal with IPC.
	 */
	public class MediaPlaybackServiceBinder extends Binder {
		MediaPlaybackService getService() {
			return MediaPlaybackService.this;
		}
	}
}

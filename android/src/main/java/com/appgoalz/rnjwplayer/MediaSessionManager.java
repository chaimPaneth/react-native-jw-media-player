package com.appgoalz.rnjwplayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v4.media.MediaMetadataCompat;
import android.support.v4.media.session.MediaSessionCompat;
import android.support.v4.media.session.PlaybackStateCompat;

import com.jwplayer.pub.api.PlayerState;
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
import com.jwplayer.pub.api.events.PlaylistEvent;
import com.jwplayer.pub.api.events.PlaylistItemEvent;
import com.jwplayer.pub.api.events.listeners.AdvertisingEvents;
import com.jwplayer.pub.api.events.listeners.VideoPlayerEvents;
import com.jwplayer.pub.api.media.playlists.PlaylistItem;
import com.jwplayer.pub.view.JWPlayerView;

import java.util.List;

/**
 * Manages a {@link MediaSessionCompat}.
 */
public class MediaSessionManager implements VideoPlayerEvents.OnPlayListener,
											VideoPlayerEvents.OnPauseListener,
											VideoPlayerEvents.OnBufferListener,
											VideoPlayerEvents.OnErrorListener,
											VideoPlayerEvents.OnPlaylistListener,
											VideoPlayerEvents.OnPlaylistItemListener,
											VideoPlayerEvents.OnPlaylistCompleteListener,
											AdvertisingEvents.OnAdPlayListener,
											AdvertisingEvents.OnAdErrorListener,
											AdvertisingEvents.OnAdSkippedListener,
											AdvertisingEvents.OnAdCompleteListener,
											DownloadImageTask.ImageDownloadListener {

	/**
	 * Playback Rate for the JW Player is always 1.0.
	 */
	private static final float PLAYBACK_RATE = 1.0f;

	/**
	 * The Player we're managing the media session of.
	 */
	private JWPlayerView mPlayerView;

	/**
	 * The current playlist index.
	 */
	private int mPlaylistIndex;

	/**
	 * The playlist that is currently loaded on the player.
	 */
	private List<PlaylistItem> mPlaylist;

	/**
	 * The underlying {@link MediaSessionCompat}.
	 */
	private MediaSessionCompat mMediaSessionCompat;

	/**
	 * Whether the {@link JWPlayerView} broadcasted an error.
	 */
	private boolean mReceivedError;

	/**
	 * An {@link android.os.AsyncTask} used for downloading artwork.
	 */
	private DownloadImageTask mDownloadImageTask;


	private NotificationWrapper mNotificationWrapper;

	/**
	 * Initializes a new MediaSessionManager.
	 *
	 * @param context
	 * @param playerView
	 */
	public MediaSessionManager(Context context,
                               JWPlayerView playerView,
                               NotificationWrapper notificationWrapper) {
		mPlayerView = playerView;
		mNotificationWrapper = notificationWrapper;

		// Create a new MediaSession
		mMediaSessionCompat = new MediaSessionCompat(context,
													 MediaSessionManager.class.getSimpleName());
		mMediaSessionCompat.setFlags(MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
											 | MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS);
		mMediaSessionCompat.setCallback(new MediaSessionCallback(mPlayerView));

		// Register listeners.
		mPlayerView.getPlayer().addListener(EventType.PLAY, this);
		mPlayerView.getPlayer().addListener(EventType.PAUSE, this);
		mPlayerView.getPlayer().addListener(EventType.BUFFER, this);
		mPlayerView.getPlayer().addListener(EventType.ERROR, this);
		mPlayerView.getPlayer().addListener(EventType.PLAYLIST, this);
		mPlayerView.getPlayer().addListener(EventType.PLAYLIST_ITEM, this);
		mPlayerView.getPlayer().addListener(EventType.PLAYLIST_COMPLETE, this);

		mPlayerView.getPlayer().addListener(EventType.AD_PLAY, this);
//		mPlayerView.getPlayer().addListener(EventType.AD_PAUSE, this);
		mPlayerView.getPlayer().addListener(EventType.AD_COMPLETE, this);
		mPlayerView.getPlayer().addListener(EventType.AD_SKIPPED, this);
		mPlayerView.getPlayer().addListener(EventType.AD_ERROR, this);
	}

	public @PlaybackStateCompat.Actions
	long getCapabilities(PlayerState playerState) {
		long capabilities = 0;

		switch (playerState) {
			case PLAYING:
				capabilities |= PlaybackStateCompat.ACTION_PAUSE
						| PlaybackStateCompat.ACTION_STOP
						| PlaybackStateCompat.ACTION_SEEK_TO;
				break;
			case PAUSED:
				capabilities |= PlaybackStateCompat.ACTION_PLAY
						| PlaybackStateCompat.ACTION_STOP
						| PlaybackStateCompat.ACTION_SEEK_TO;
				break;
			case BUFFERING:
				capabilities |= PlaybackStateCompat.ACTION_PAUSE
						| PlaybackStateCompat.ACTION_STOP
						| PlaybackStateCompat.ACTION_SEEK_TO;
				break;
			case IDLE:
				if (!mReceivedError && mPlaylist != null && mPlaylist.size() >= 1) {
					capabilities |= PlaybackStateCompat.ACTION_PLAY;
				}
				break;
		}

		if (mPlaylist != null && mPlaylist.size() - mPlaylistIndex > 1) {
			capabilities |= PlaybackStateCompat.ACTION_SKIP_TO_NEXT;
		}

		if (mPlaylistIndex > 0 && mPlaylist != null && mPlaylist.size() > 1) {
			capabilities |= PlaybackStateCompat.ACTION_SKIP_TO_PREVIOUS;
		}

		return capabilities;
	}

	public JWPlayerView getPlayerView() {
		return mPlayerView;
	}


	private PlaybackStateCompat.Builder getPlaybackStateBuilder() {
		PlaybackStateCompat playbackState = mMediaSessionCompat.getController().getPlaybackState();
		return playbackState == null
				? new PlaybackStateCompat.Builder()
				: new PlaybackStateCompat.Builder(playbackState);
	}

	private void updatePlaybackState(PlayerState playerState) {
		PlaybackStateCompat.Builder newPlaybackState = getPlaybackStateBuilder();
		long capabilities = getCapabilities(playerState);
		//noinspection WrongConstant
		newPlaybackState.setActions(capabilities);

		int playbackStateCompat = PlaybackStateCompat.STATE_NONE;
		switch (playerState) {
			case PLAYING:
				playbackStateCompat = PlaybackStateCompat.STATE_PLAYING;
				break;
			case PAUSED:
				playbackStateCompat = PlaybackStateCompat.STATE_PAUSED;
				break;
			case BUFFERING:
				playbackStateCompat = PlaybackStateCompat.STATE_BUFFERING;
				break;
			case IDLE:
				if (mReceivedError) {
					playbackStateCompat = PlaybackStateCompat.STATE_ERROR;
				} else {
					playbackStateCompat = PlaybackStateCompat.STATE_STOPPED;
				}
				break;
		}

		if (mPlayerView != null) {
			newPlaybackState.setState(playbackStateCompat, (long)mPlayerView.getPlayer().getPosition(), (float) mPlayerView.getPlayer().getPlaybackRate()); // PLAYBACK_RATE
			mMediaSessionCompat.setPlaybackState(newPlaybackState.build());
			mNotificationWrapper
					.createNotification(mPlayerView.getContext(), mMediaSessionCompat, capabilities);
		}
	}

	@Override
	public void onPlaylistItem(PlaylistItemEvent playlistItemEvent) {
		int index = playlistItemEvent.getIndex();
		PlaylistItem playlistItem = playlistItemEvent.getPlaylistItem();

		mPlaylistIndex = index;

		// Update Metadata
		MediaMetadataCompat metadata = new MediaMetadataCompat.Builder()
				.putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_TITLE, playlistItem.getTitle())
				.putString(MediaMetadataCompat.METADATA_KEY_DISPLAY_SUBTITLE,
						   playlistItem.getDescription())
				.putString(MediaMetadataCompat.METADATA_KEY_MEDIA_ID, playlistItem.getMediaId())
				.build();
		mMediaSessionCompat.setMetadata(metadata);

		// Fetch artwork
		if (mDownloadImageTask != null) {
			mDownloadImageTask.cancel(true);
		}
		mDownloadImageTask = new DownloadImageTask(this);
		mDownloadImageTask.execute(playlistItem.getImage());
	}


	@Override
	public void onError(ErrorEvent errorEvent) {
		mReceivedError = true;
	}

	@Override
	public void onAdComplete(AdCompleteEvent adCompleteEvent) {
		mMediaSessionCompat.setFlags(MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
											 | MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS);
	}

	@Override
	public void onAdSkipped(AdSkippedEvent adSkippedEvent) {
		mMediaSessionCompat.setFlags(MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
											 | MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS);
	}

	@Override
	public void onAdPlay(AdPlayEvent adPlayEvent) {
		mMediaSessionCompat.setFlags(0);
	}

	/**
	 * Returns the underlying media session.
	 *
	 * @return
	 */
	public MediaSessionCompat getMediaSession() {
		return mMediaSessionCompat;
	}

	/**
	 * Releases this MediaSession.
	 */
	public void release() {
		mMediaSessionCompat.release();
		mPlayerView.getPlayer().removeAllListeners(this);

		// Remove any notifications
		mNotificationWrapper.cancelNotification();
	}

	@Override
	public void onAdError(AdErrorEvent adErrorEvent) {
		mMediaSessionCompat.setFlags(MediaSessionCompat.FLAG_HANDLES_TRANSPORT_CONTROLS
											 | MediaSessionCompat.FLAG_HANDLES_MEDIA_BUTTONS);
	}

	@Override
	public void onBuffer(BufferEvent bufferEvent) {
		// Update the PlaybackState.
		updatePlaybackState(PlayerState.BUFFERING);
	}

	@Override
	public void onPause(PauseEvent pauseEvent) {
		updatePlaybackState(PlayerState.PAUSED);
	}

	@Override
	public void onPlay(PlayEvent playEvent) {
		// Tell Android that we're playing media.
		mMediaSessionCompat.setActive(true);
		// Update the MediaSession
		updatePlaybackState(PlayerState.PLAYING);
	}

	@Override
	public void onPlaylistComplete(PlaylistCompleteEvent playlistCompleteEvent) {
		mMediaSessionCompat.setActive(false);
		mMediaSessionCompat.release();
		mPlaylistIndex = 0;
	}

	@Override
	public void onPlaylist(PlaylistEvent playlistEvent) {
		mPlaylist = playlistEvent.getPlaylist();
	}

	@Override
	public void onBitmapReady(Bitmap bitmap) {
		if (mMediaSessionCompat != null) {
			MediaMetadataCompat currentMetadata = mMediaSessionCompat.getController()
																	 .getMetadata();
			MediaMetadataCompat.Builder newBuilder = currentMetadata == null
					? new MediaMetadataCompat.Builder()
					: new MediaMetadataCompat.Builder(currentMetadata);
			mMediaSessionCompat.setMetadata(newBuilder
													.putBitmap(MediaMetadataCompat.METADATA_KEY_ART,
															   bitmap)
													.build());
		}
	}


	/**
	 * A {@link android.support.v4.media.session.MediaSessionCompat.Callback} implementation for JW Player.
	 */
	private final class MediaSessionCallback extends MediaSessionCompat.Callback {

		public MediaSessionCallback(JWPlayerView playerView) {
			mPlayerView = playerView;
		}

		@Override
		public void onPause() {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().pause();
			}
		}

		@Override
		public void onPlay() {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().play();
			}
		}

		@Override
		public void onSeekTo(long pos) {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().seek(pos);
			}
		}

		@Override
		public void onSkipToNext() {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().playlistItem(mPlayerView.getPlayer().getPlaylistIndex() + 1);
			}
		}

		@Override
		public void onSkipToPrevious() {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().playlistItem(mPlayerView.getPlayer().getPlaylistIndex() - 1);
			}
		}

		@Override
		public void onStop() {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().stop();
			}
		}

		@Override
		public void onSkipToQueueItem(long id) {
			if (mPlayerView != null) {
				mPlayerView.getPlayer().playlistItem((int)id);
			}
		}
	}

}

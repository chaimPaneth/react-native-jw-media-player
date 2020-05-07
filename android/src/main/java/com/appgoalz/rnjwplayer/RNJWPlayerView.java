package com.appgoalz.rnjwplayer;


import android.app.Activity;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.ActivityInfo;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;
import com.longtailvideo.jwplayer.configuration.SkinConfig;
import com.longtailvideo.jwplayer.events.AudioTrackChangedEvent;
import com.longtailvideo.jwplayer.events.AudioTracksEvent;
import com.longtailvideo.jwplayer.events.BeforeCompleteEvent;
import com.longtailvideo.jwplayer.events.BeforePlayEvent;
import com.longtailvideo.jwplayer.events.BufferEvent;
import com.longtailvideo.jwplayer.events.CompleteEvent;
import com.longtailvideo.jwplayer.events.ControlBarVisibilityEvent;
import com.longtailvideo.jwplayer.events.ControlsEvent;
import com.longtailvideo.jwplayer.events.DisplayClickEvent;
import com.longtailvideo.jwplayer.events.ErrorEvent;
import com.longtailvideo.jwplayer.events.FirstFrameEvent;
import com.longtailvideo.jwplayer.events.FullscreenEvent;
import com.longtailvideo.jwplayer.events.IdleEvent;
import com.longtailvideo.jwplayer.events.PauseEvent;
import com.longtailvideo.jwplayer.events.PlayEvent;
import com.longtailvideo.jwplayer.events.PlaylistCompleteEvent;
import com.longtailvideo.jwplayer.events.PlaylistEvent;
import com.longtailvideo.jwplayer.events.PlaylistItemEvent;
import com.longtailvideo.jwplayer.events.ReadyEvent;
import com.longtailvideo.jwplayer.events.SeekEvent;
import com.longtailvideo.jwplayer.events.SeekedEvent;
import com.longtailvideo.jwplayer.events.SetupErrorEvent;
import com.longtailvideo.jwplayer.events.TimeEvent;
import com.longtailvideo.jwplayer.events.listeners.AdvertisingEvents;
import com.longtailvideo.jwplayer.events.listeners.VideoPlayerEvents;
import com.longtailvideo.jwplayer.fullscreen.FullscreenHandler;
import com.longtailvideo.jwplayer.media.ads.ImaVMAPAdvertising;
import com.longtailvideo.jwplayer.media.playlists.PlaylistItem;

import java.util.ArrayList;
import java.util.List;

import static com.longtailvideo.jwplayer.configuration.PlayerConfig.STRETCHING_UNIFORM;

public class RNJWPlayerView extends RelativeLayout implements VideoPlayerEvents.OnFullscreenListener,
        VideoPlayerEvents.OnReadyListener,
        VideoPlayerEvents.OnPlayListener,
        VideoPlayerEvents.OnPauseListener,
        VideoPlayerEvents.OnCompleteListener,
        VideoPlayerEvents.OnIdleListener,
        VideoPlayerEvents.OnErrorListener,
        VideoPlayerEvents.OnSetupErrorListener,
        VideoPlayerEvents.OnBufferListener,
        VideoPlayerEvents.OnTimeListener,
        VideoPlayerEvents.OnPlaylistListener,
        VideoPlayerEvents.OnPlaylistItemListener,
        VideoPlayerEvents.OnPlaylistCompleteListener,
        VideoPlayerEvents.OnAudioTracksListener,
        VideoPlayerEvents.OnAudioTrackChangedListener,
        VideoPlayerEvents.OnControlsListener,
        VideoPlayerEvents.OnControlBarVisibilityListener,
        VideoPlayerEvents.OnDisplayClickListener,
        VideoPlayerEvents.OnFirstFrameListener,
        VideoPlayerEvents.OnSeekListener,
        VideoPlayerEvents.OnSeekedListener,
        AdvertisingEvents.OnBeforePlayListener,
        AdvertisingEvents.OnBeforeCompleteListener,
        AudioManager.OnAudioFocusChangeListener {
    public RNJWPlayer mPlayer = null;
    private RNJWPlayer mFullscreenPlayer;

    private ViewGroup mRootView;

    List<PlaylistItem> mPlayList = null;

    //Props
    String file = "";
    String image = "";
    String title = "";
    String desc = "";
    String mediaId = "";
    String customStyle;
    String adVmap = "";

    Boolean autostart = true;
    Boolean controls = true;
    Boolean repeat = false;
    Boolean displayTitle = false;
    Boolean displayDesc = false;
    Boolean nextUpDisplay = false;

    Boolean nativeFullScreen = false;
    Boolean landscapeOnFullScreen = false;
    Boolean fullScreenOnLandscape = false;
    Boolean portraitOnExitFullScreen = false;

    ReadableMap playlistItem; // PlaylistItem
    ReadableArray playlist; // List <PlaylistItem>
    Number currentPlayingIndex;

    private static final String TAG = "RNJWPlayerView";

    static Activity mActivity;

    Window mWindow;

    public static AudioManager audioManager;

    final Object focusLock = new Object();

    AudioFocusRequest focusRequest;

    boolean hasAudioFocus = false;
    boolean playbackDelayed = false;
    boolean playbackNowAuthorized = false;
    boolean userPaused = false;
    boolean wasInterrupted = false;

    private final ReactApplicationContext mAppContext;

    private ThemedReactContext mThemedReactContext;

    /**
     * Whether we have bound to a {@link MediaPlaybackService}.
     */
    private boolean mIsBound = false;

    /**
     * The {@link MediaPlaybackService} we are bound to. T
     */
    private MediaPlaybackService mMediaPlaybackService;

    /**
     * The {@link MediaSessionManager} handles the MediaSession logic, along with updates to the notification
     */
    private MediaSessionManager mMediaSessionManager;

    /**
     * The {@link MediaSessionManager} handles the Notification set and dismissal logic
     */
    private NotificationWrapper mNotificationWrapper;

    /**
     * The {@link ServiceConnection} serves as glue between this activity and the {@link MediaPlaybackService}.
     */
    private ServiceConnection mServiceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName componentName, IBinder service) {
            // This is called when the connection with the service has been
            // established, giving us the service object we can use to
            // interact with the service.  Because we have bound to a explicit
            // service that we know is running in our own process, we can
            // cast its IBinder to a concrete class and directly access it.
            mIsBound = true;
            mMediaPlaybackService = ((MediaPlaybackService.MediaPlaybackServiceBinder)service)
                    .getService();
            mMediaPlaybackService.setupMediaSession(mMediaSessionManager, mNotificationWrapper);
        }

        @Override
        public void onServiceDisconnected(ComponentName componentName) {
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            // Because it is running in our same process, we should never
            // see this happen.
            mMediaPlaybackService = null;
        }
    };

    private static boolean contextHasBug(Context context) {
        return context == null ||
                context.getResources() == null ||
                context.getResources().getConfiguration() == null;
    }


    private static Context getNonBuggyContext(ThemedReactContext reactContext,
                                              ReactApplicationContext appContext) {
        Context superContext = reactContext;
        if (!contextHasBug(appContext.getCurrentActivity())) {
            superContext = appContext.getCurrentActivity();
        } else if (contextHasBug(superContext)) {
            // we have the bug! let's try to find a better context to use
            if (!contextHasBug(reactContext.getCurrentActivity())) {
                superContext = reactContext.getCurrentActivity();
            } else if (!contextHasBug(reactContext.getApplicationContext())) {
                superContext = reactContext.getApplicationContext();
            } else {
                // ¯\_(ツ)_/¯
            }
        }
        return superContext;
    }

    public RNJWPlayerView(ThemedReactContext reactContext, ReactApplicationContext appContext) {
        super(getNonBuggyContext(reactContext, appContext));
        mAppContext = appContext;

        mThemedReactContext = reactContext;

        mActivity = getActivity();
        if (mActivity != null) {
            mWindow = mActivity.getWindow();
        }

        mRootView = mActivity.findViewById(android.R.id.content);

        Context simpleContext = getNonBuggyContext(getReactContext(), getAppContext());

        audioManager = (AudioManager) simpleContext.getSystemService(Context.AUDIO_SERVICE);
    }

    public ReactApplicationContext getAppContext() {
        return mAppContext;
    }

    public ThemedReactContext getReactContext() {
        return mThemedReactContext;
    }

    public Activity getActivity() {
        return (Activity) getContext();
    }

    public void destroyPlayer() {
        if (mPlayer != null) {
            mPlayer.stop();

            mPlayer.removeOnReadyListener(this);
            mPlayer.removeOnPlayListener(this);
            mPlayer.removeOnPauseListener(this);
            mPlayer.removeOnSeekListener(this);
            mPlayer.removeOnSeekedListener(this);
            mPlayer.removeOnCompleteListener(this);
            mPlayer.removeOnIdleListener(this);
            mPlayer.removeOnErrorListener(this);
            mPlayer.removeOnSetupErrorListener(this);
            mPlayer.removeOnBufferListener(this);
            mPlayer.removeOnTimeListener(this);
            mPlayer.removeOnPlaylistListener(this);
            mPlayer.removeOnPlaylistItemListener(this);
            mPlayer.removeOnPlaylistCompleteListener(this);
            mPlayer.removeOnFirstFrameListener(this);
            mPlayer.removeOnBeforePlayListener(this);
            mPlayer.removeOnBeforeCompleteListener(this);
            mPlayer.removeOnControlsListener(this);
            mPlayer.removeOnControlBarVisibilityListener(this);
            mPlayer.removeOnDisplayClickListener(this);
            mPlayer.removeOnFullscreenListener(this);

            mPlayer.onDestroy();
            mPlayer = null;

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (audioManager != null && focusRequest != null) {
                    audioManager.abandonAudioFocusRequest(focusRequest);
                }
            } else {
                if (audioManager != null) {
                    audioManager.abandonAudioFocus(this);
                }
            }

            audioManager = null;
            doUnbindService();
        }
    }

    public void setupPlayerView() {
        if (mPlayer != null) {
            mPlayer.addOnReadyListener(this);
            mPlayer.addOnPlayListener(this);
            mPlayer.addOnPauseListener(this);
            mPlayer.addOnSeekListener(this);
            mPlayer.addOnSeekedListener(this);
            mPlayer.addOnCompleteListener(this);
            mPlayer.addOnIdleListener(this);
            mPlayer.addOnErrorListener(this);
            mPlayer.addOnSetupErrorListener(this);
            mPlayer.addOnBufferListener(this);
            mPlayer.addOnTimeListener(this);
            mPlayer.addOnPlaylistListener(this);
            mPlayer.addOnPlaylistItemListener(this);
            mPlayer.addOnPlaylistCompleteListener(this);
            mPlayer.addOnFirstFrameListener(this);
            mPlayer.addOnBeforePlayListener(this);
            mPlayer.addOnBeforeCompleteListener(this);
            mPlayer.addOnControlsListener(this);
            mPlayer.addOnControlBarVisibilityListener(this);
            mPlayer.addOnDisplayClickListener(this);
            mPlayer.addOnFullscreenListener(this);
            mPlayer.setFullscreenHandler(new FullscreenHandler() {
                ViewGroup mPlayerContainer = (ViewGroup) mPlayer.getParent();
                private View mDecorView;

                @Override
                public void onFullscreenRequested() {
                    if (nativeFullScreen) {
                        mDecorView = mActivity.getWindow().getDecorView();

                        // Hide system ui
                        mDecorView.setSystemUiVisibility(
                                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hides bottom bar
                                        | View.SYSTEM_UI_FLAG_FULLSCREEN // hides top bar
                                        | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY // prevents navigation bar from overriding
                                // exit-full-screen button. Swipe from side to access nav bar.
                        );

                        // Enter landscape mode for fullscreen videos
                        if (landscapeOnFullScreen) {
                            mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
                        }

                        // Destroy the player's rendering surface, we need to do this to prevent Android's
                        // MediaDecoders from crashing.
//                        mPlayer.destroySurface();

                        mPlayerContainer = (ViewGroup) mPlayer.getParent();

                        // Remove the JWPlayerView from the list item.
                        if (mPlayerContainer != null) {
                            mPlayerContainer.removeView(mPlayer);
                        }

                        // Initialize a new rendering surface.
//                        mPlayer.initializeSurface();

                        // Add the JWPlayerView to the RootView as soon as the UI thread is ready.
                        mRootView.post(new Runnable() {
                            @Override
                            public void run() {
                                mRootView.addView(mPlayer, new ViewGroup.LayoutParams(
                                        ViewGroup.LayoutParams.MATCH_PARENT,
                                        ViewGroup.LayoutParams.MATCH_PARENT
                                ));
                                mFullscreenPlayer = mPlayer;
                            }
                        });
                    }

                    WritableMap eventEnterFullscreen = Arguments.createMap();
                    eventEnterFullscreen.putString("message", "onFullscreen");
                    getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                            getId(),
                            "topFullScreen",
                            eventEnterFullscreen);
                }

                @Override
                public void onFullscreenExitRequested() {
                    if (nativeFullScreen) {
                        mDecorView.setSystemUiVisibility(
                                View.SYSTEM_UI_FLAG_VISIBLE // clear the hide system flags
                        );

                        // Enter portrait mode
                        if (portraitOnExitFullScreen) {
                            mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
                        }

                        // Destroy the surface that is used for video output, we need to do this before
                        // we can detach the JWPlayerView from a ViewGroup.
//                        mPlayer.destroySurface();

                        // Remove the player view from the root ViewGroup.
                        mRootView.removeView(mPlayer);

                        // After we've detached the JWPlayerView we can safely reinitialize the surface.
//                        mPlayer.initializeSurface();

                        // As soon as the UI thread has finished processing the current message queue it
                        // should add the JWPlayerView back to the list item.
                        mPlayerContainer.post(new Runnable() {
                            @Override
                            public void run() {
                                mPlayerContainer.addView(mPlayer, new ViewGroup.LayoutParams(
                                        ViewGroup.LayoutParams.MATCH_PARENT,
                                        ViewGroup.LayoutParams.MATCH_PARENT
                                ));
                                mPlayer.layout(mPlayerContainer.getLeft(), mPlayerContainer.getTop(), mPlayerContainer.getRight(), mPlayerContainer.getBottom());
                                mFullscreenPlayer = null;
                            }
                        });
                    }

                    WritableMap eventExitFullscreen = Arguments.createMap();
                    eventExitFullscreen.putString("message", "onFullscreenExit");
                    getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                            getId(),
                            "topFullScreenExit",
                            eventExitFullscreen);
                }

                @Override
                public void onResume() {

                }

                @Override
                public void onPause() {

                }

                @Override
                public void onDestroy() {
                    if (mFullscreenPlayer != null) {
                        onFullscreenExitRequested();
                    }
                }

                @Override
                public void onAllowRotationChanged(boolean b) {
                    Log.e(TAG, "onAllowRotationChanged: "+b );
                }

                @Override
                public void updateLayoutParams(ViewGroup.LayoutParams layoutParams) {
//        View.setSystemUiVisibility(int).
//        Log.e(TAG, "updateLayoutParams: "+layoutParams );
                }

                @Override
                public void setUseFullscreenLayoutFlags(boolean b) {
//        View.setSystemUiVisibility(int).
//        Log.e(TAG, "setUseFullscreenLayoutFlags: "+b );
                }
            });

            mPlayer.setControls(true);
            mPlayer.setBackgroundAudio(true); // TODO: - add as prop
        }
    }

    public void resetPlaylist() {
        playlist = null;
    }

    public void setPlaylistItem(ReadableMap prop) {
        if(playlistItem != prop) {
            playlistItem = prop;

            if (playlistItem != null) {
                if (playlistItem.hasKey("file")) {
                    String newFile = playlistItem.getString("file");

                    if (mPlayer == null || mPlayer.getPlaylistItem() == null) {
                        resetPlaylist();

                        PlaylistItem newPlayListItem = new PlaylistItem();

                        newPlayListItem.setFile(newFile);

                        if (playlistItem.hasKey("title")) {
                            newPlayListItem.setTitle(playlistItem.getString("title"));
                        }

                        if (playlistItem.hasKey("desc")) {
                            newPlayListItem.setDescription(playlistItem.getString("desc"));
                        }

                        if (playlistItem.hasKey("image")) {
                            newPlayListItem.setImage(playlistItem.getString("image"));
                        }

                        if (playlistItem.hasKey("mediaId")) {
                            newPlayListItem.setMediaId(playlistItem.getString("mediaId"));
                        }

                        SkinConfig skinConfig;

                        if (playlistItem.hasKey("playerStyle")) {
                            skinConfig = getCustomSkinConfig(playlistItem.getString("playerStyle"));
                        } else if (customStyle != null && !customStyle.isEmpty()) {
                            skinConfig = getCustomSkinConfig(customStyle);
                        } else {
                            skinConfig = new SkinConfig.Builder().build();
                        }

                        boolean autostart = false;
                        if (playlistItem.hasKey("autostart")) {
                            autostart = playlistItem.getBoolean("autostart");
                        }

                        if (playlistItem.hasKey("adVmap")) {
                            adVmap = playlistItem.getString("adVmap");
                        }

                        List<PlaylistItem> playlist = new ArrayList<>();
                        playlist.add(newPlayListItem);

                        ImaVMAPAdvertising imaVMAPAdvertising = new ImaVMAPAdvertising(adVmap);

                        PlayerConfig playerConfig = new PlayerConfig.Builder()
                                .skinConfig(skinConfig)
                                .repeat(false)
                                .controls(true)
                                .autostart(autostart)
                                .displayTitle(true)
                                .displayDescription(true)
                                .nextUpDisplay(true)
                                .stretching(STRETCHING_UNIFORM)
                                .playlist(playlist)
                                .advertising(imaVMAPAdvertising)
                                .build();

                        Context simpleContext = getNonBuggyContext(getReactContext(), getAppContext());

                        mPlayer = new RNJWPlayer(simpleContext, playerConfig);
                        setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
                        mPlayer.setLayoutParams(new LinearLayout.LayoutParams(
                                LinearLayout.LayoutParams.MATCH_PARENT,
                                LinearLayout.LayoutParams.MATCH_PARENT));
                        addView(mPlayer);

                        setupPlayerView();

                        NotificationManager notificationManager = (NotificationManager)mActivity.getSystemService(Context.NOTIFICATION_SERVICE);
                        mNotificationWrapper = new NotificationWrapper(notificationManager);
                        mMediaSessionManager = new MediaSessionManager(simpleContext,
                                mPlayer,
                                mNotificationWrapper);

                        if (playlistItem.hasKey("autostart")) {
                            mPlayer.getConfig().setAutostart(playlistItem.getBoolean("autostart"));
                        }

                        mPlayer.load(newPlayListItem);

                        if (autostart) {
                            mPlayer.play();
                        }
                    } else {
                        boolean autostart = mPlayer.getConfig().getAutostart();
                        if (autostart) {
                            mPlayer.play();
                        }
                    }
                }
            }
        }
    }

    public void setPlaylist(ReadableArray prop) {
        if(playlist != prop) {
            playlist = prop;

            if (playlist != null && playlist.size() > 0) {
                mPlayList = new ArrayList<>();

                int j = 0;
                while (playlist.size() > j) {
                    playlistItem = playlist.getMap(j);

                    if (playlistItem != null) {

                        if (playlistItem.hasKey("file")) {
                            file = playlistItem.getString("file");
                        }

                        if (playlistItem.hasKey("title")) {
                            title = playlistItem.getString("title");
                        }

                        if (playlistItem.hasKey("desc")) {
                            desc = playlistItem.getString("desc");
                        }

                        if (playlistItem.hasKey("image")) {
                            image = playlistItem.getString("image");
                        }

                        if (playlistItem.hasKey("mediaId")) {
                            mediaId = playlistItem.getString("mediaId");
                        }

                        PlaylistItem newPlayListItem = new PlaylistItem.Builder()
                                .file(file)
                                .title(title)
                                .description(desc)
                                .image(image)
                                .mediaId(mediaId)
                                .build();

                        mPlayList.add(newPlayListItem);
                    }

                    j++;
                }

                SkinConfig skinConfig;

                if (playlist.getMap(0).hasKey("playerStyle")) {
                    skinConfig = getCustomSkinConfig(playlist.getMap(0).getString("playerStyle"));
                } else if (customStyle != null && !customStyle.isEmpty()) {
                    skinConfig = getCustomSkinConfig(customStyle);
                } else {
                    skinConfig = new SkinConfig.Builder().build();
                }

                boolean autostart = false;
                if (playlist.getMap(0).hasKey("autostart")) {
                    autostart = playlist.getMap(0).getBoolean("autostart");
                }

                PlayerConfig playerConfig = new PlayerConfig.Builder()
                        .skinConfig(skinConfig)
                        .repeat(false)
                        .controls(true)
                        .autostart(autostart)
                        .displayTitle(true)
                        .displayDescription(true)
                        .nextUpDisplay(true)
                        .stretching(STRETCHING_UNIFORM)
                        .build();

                Context simpleContext = getNonBuggyContext(getReactContext(), getAppContext());

                mPlayer = new RNJWPlayer(simpleContext, playerConfig);

                setupPlayerView();

                NotificationManager notificationManager = (NotificationManager)mActivity.getSystemService(Context.NOTIFICATION_SERVICE);
                mNotificationWrapper = new NotificationWrapper(notificationManager);
                mMediaSessionManager = new MediaSessionManager(simpleContext,
                        mPlayer,
                        mNotificationWrapper);

                if (playlist.getMap(0).hasKey("autostart")) {
                    mPlayer.getConfig().setAutostart(playlist.getMap(0).getBoolean("autostart"));
                }

                mPlayer.load(mPlayList);

                if (autostart) {
                    mPlayer.play();
                }
            }
        }
    }

    private void doBindService() {
        // Establish a connection with the service.  We use an explicit
        // class name because we want a specific service implementation that
        // we know will be running in our own process (and thus won't be
        // supporting component replacement by other applications).
        mActivity.bindService(new Intent(RNJWPlayerView.mActivity,
                        MediaPlaybackService.class),
                mServiceConnection,
                Context.BIND_AUTO_CREATE);

    }

    private void doUnbindService() {
        if (mIsBound) {
            // Detach our existing connection.
            mActivity.unbindService(mServiceConnection);
            mIsBound = false;
        }
    }

    public void setCustomStyle(String name) {
        if (mPlayer != null) {
            PlayerConfig config = getCustomConfig(getCustomSkinConfig((name)));
            mPlayer.setup(config);
        }
    }

    public SkinConfig getCustomSkinConfig(String name) {
        return new SkinConfig.Builder()
                .name(name)
                .url(String.format("file:///android_asset/%s.css", name))
                .build();
    }

    public PlayerConfig getCustomConfig(SkinConfig skinConfig) {
        return new PlayerConfig.Builder()
                .skinConfig(skinConfig)
                .repeat(false)
                .controls(true)
                .autostart(false)
                .displayTitle(true)
                .displayDescription(true)
                .nextUpDisplay(true)
                .stretching(STRETCHING_UNIFORM)
                .build();
    }

    public PlayerConfig getDefaultConfig() {
        return new PlayerConfig.Builder()
                .skinConfig(new SkinConfig.Builder().build())
                .repeat(false)
                .controls(true)
                .autostart(false)
                .displayTitle(true)
                .displayDescription(true)
                .nextUpDisplay(true)
                .stretching(STRETCHING_UNIFORM)
                .build();
    }

    @Override
    public void onDisplayClick(DisplayClickEvent displayClickEvent) {

    }

    @Override
    public void onAudioTracks(AudioTracksEvent audioTracksEvent) {

    }

    @Override
    public void onAudioTrackChanged(AudioTrackChangedEvent audioTrackChangedEvent) {

    }

    @Override
    public void onBeforePlay(BeforePlayEvent beforePlayEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBeforePlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBeforePlay", event);
    }


    @Override
    public void onBeforeComplete(BeforeCompleteEvent beforeCompleteEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBeforeComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBeforeComplete", event);
    }

    @Override
    public void onIdle(IdleEvent idleEvent) {

    }

    @Override
    public void onPlaylist(PlaylistEvent playlistEvent) {

    }

    public void resetPlaylistItem() {
        playlistItem = null;
    }

    @Override
    public void onPlaylistItem(PlaylistItemEvent playlistItemEvent) {
        if (!mIsBound) {
            doBindService();
        }

        currentPlayingIndex = playlistItemEvent.getIndex();

        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlaylistItem");
        event.putInt("index",playlistItemEvent.getIndex());
        event.putString("playlistItem", playlistItemEvent.getPlaylistItem().toJson().toString());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlaylistItem", event);
    }

    @Override
    public void onPlaylistComplete(PlaylistCompleteEvent playlistCompleteEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlaylistComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlaylistComplete", event);
    }

    @Override
    public void onBuffer(BufferEvent bufferEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBuffer");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBuffer", event);

        updateWakeLock(true);
    }

    public void requestAudioFocus() {
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
            if (hasAudioFocus) {
                return;
            }

            if (audioManager != null) {
                AudioAttributes playbackAttributes = new AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_MEDIA)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC) // CONTENT_TYPE_SPEECH
                        .build();
                focusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                        .setAudioAttributes(playbackAttributes)
                        .setAcceptsDelayedFocusGain(true)
//                    .setWillPauseWhenDucked(true)
                        .setOnAudioFocusChangeListener(this)
                        .build();

                int res = audioManager.requestAudioFocus(focusRequest);
                synchronized(focusLock) {
                    if (res == AudioManager.AUDIOFOCUS_REQUEST_FAILED) {
                        playbackNowAuthorized = false;
                    } else if (res == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                        playbackNowAuthorized = true;
                        hasAudioFocus = true;
                    } else if (res == AudioManager.AUDIOFOCUS_REQUEST_DELAYED) {
                        playbackDelayed = true;
                        playbackNowAuthorized = false;
                    }
                }
                Log.e(TAG, "audioRequest: " + res);
            }
        }
        else {
            int result = 0;
            if (audioManager != null) {
                if (hasAudioFocus) {
                    return;
                }

                result = audioManager.requestAudioFocus(this,
                        // Use the music stream.
                        AudioManager.STREAM_MUSIC,
                        // Request permanent focus.
                        AudioManager.AUDIOFOCUS_GAIN);
            }
            if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
                hasAudioFocus = true;
            }
            Log.e(TAG, "audioRequest: " + result);
        }
    }

    @Override
    public void onPlay(PlayEvent playEvent) {
        requestAudioFocus();

        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlay", event);

        updateWakeLock(true);

        userPaused = false;
        wasInterrupted = false;
    }

    @Override
    public void onReady(ReadyEvent readyEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlayerReady");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topOnPlayerReady", event);

        updateWakeLock(true);
    }

    @Override
    public void onPause(PauseEvent pauseEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPause");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPause", event);

        updateWakeLock(false);

        if (!wasInterrupted) {
            userPaused = true;
        }
    }

    @Override
    public void onComplete(CompleteEvent completeEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topComplete", event);

        updateWakeLock(false);
    }

    @Override
    public void onFullscreen(FullscreenEvent fullscreenEvent) {

    }

    @Override
    public void onError(ErrorEvent errorEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onError");
        Exception ex = errorEvent.getException();
        if (ex != null) {
            event.putString("error", ex.toString());
            event.putString("description",  errorEvent.getMessage());
        }
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlayerError", event);

        updateWakeLock(false);
    }

    @Override
    public void onSetupError(SetupErrorEvent setupErrorEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onSetupError");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topSetupPlayerError", event);

        updateWakeLock(false);
    }

    @Override
    public void onTime(TimeEvent timeEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onTime");
        event.putDouble("position", timeEvent.getPosition());
        event.putDouble("duration", timeEvent.getDuration());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topTime", event);
    }

    @Override
    public void onSeek(SeekEvent seekEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onSeek");
        event.putDouble("position", seekEvent.getPosition());
        event.putDouble("offset", seekEvent.getOffset());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topSeek", event);
    }

    @Override
    public void onSeeked(SeekedEvent seekedEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onSeeked");
        event.putDouble("position", seekedEvent.getPosition());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topSeeked", event);
    }

    @Override
    public void onControls(ControlsEvent controlsEvent) {

    }

    @Override
    public void onControlBarVisibilityChanged(ControlBarVisibilityEvent controlBarVisibilityEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onControlBarVisible");
        event.putBoolean("controls", controlBarVisibilityEvent.isVisible());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topControlBarVisible", event);

        updateWakeLock(true);
    }

    @Override
    public void onFirstFrame(FirstFrameEvent firstFrameEvent) {

    }

    public void lowerApiOnAudioFocus(int focusChange) {
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN:
                if (!userPaused) {
                    boolean autostart = mPlayer.getConfig().getAutostart();
                    if (autostart) {
                        mPlayer.play();
                    }
                }
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
                mPlayer.pause();
                wasInterrupted = true;
                hasAudioFocus = false;
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                wasInterrupted = true;
                mPlayer.pause();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                // ... pausing or ducking depends on your app
                break;
        }
    }

    public void onAudioFocusChange(int focusChange) {
        if (mPlayer != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                switch (focusChange) {
                    case AudioManager.AUDIOFOCUS_GAIN:
                        if (playbackDelayed || !userPaused) {
                            synchronized(focusLock) {
                                playbackDelayed = false;
                            }
                            boolean autostart = mPlayer.getConfig().getAutostart();
                            if (autostart) {
                                mPlayer.play();
                            }
                        }
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                        synchronized(focusLock) {
                            wasInterrupted = true;
                            playbackDelayed = false;
                        }
                        mPlayer.pause();
                        hasAudioFocus = false;
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        synchronized(focusLock) {
                            wasInterrupted = true;
                            playbackDelayed = false;
                        }
                        mPlayer.pause();
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                        // ... pausing or ducking depends on your app
                        break;
                }
            } else {
                lowerApiOnAudioFocus(focusChange);
            }
        }
    }

    private void updateWakeLock(boolean enable) {
        if (mWindow != null) {
            if (enable) {
                mWindow.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            } else {
                mWindow.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        }
    }

}

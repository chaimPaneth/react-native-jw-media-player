package com.appgoalz.rnjwplayer;


import android.app.Activity;
import android.app.NotificationManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import androidx.mediarouter.app.MediaRouteButton;
import androidx.mediarouter.app.MediaRouteChooserDialog;
import androidx.mediarouter.media.MediaRouter;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.android.gms.cast.Cast;
import com.google.android.gms.cast.CastDevice;
import com.google.android.gms.cast.framework.CastButtonFactory;
import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.google.android.gms.cast.framework.SessionManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.gson.Gson;
import com.jwplayer.pub.api.configuration.PlayerConfig;
import com.jwplayer.pub.api.configuration.ads.AdvertisingConfig;
import com.jwplayer.pub.api.configuration.ads.VastAdvertisingConfig;
import com.jwplayer.pub.api.configuration.ads.ima.ImaAdvertisingConfig;
import com.jwplayer.pub.api.configuration.ads.ima.dai.ImaDaiAdvertisingConfig;
import com.jwplayer.pub.api.events.AdPauseEvent;
import com.jwplayer.pub.api.events.AdPlayEvent;
import com.jwplayer.pub.api.events.AudioTrackChangedEvent;
import com.jwplayer.pub.api.events.AudioTracksEvent;
import com.jwplayer.pub.api.events.BeforeCompleteEvent;
import com.jwplayer.pub.api.events.BeforePlayEvent;
import com.jwplayer.pub.api.events.BufferEvent;
import com.jwplayer.pub.api.events.CompleteEvent;
import com.jwplayer.pub.api.events.ControlBarVisibilityEvent;
import com.jwplayer.pub.api.events.ControlsEvent;
import com.jwplayer.pub.api.events.DisplayClickEvent;
import com.jwplayer.pub.api.events.ErrorEvent;
import com.jwplayer.pub.api.events.EventType;
import com.jwplayer.pub.api.events.FirstFrameEvent;
import com.jwplayer.pub.api.events.FullscreenEvent;
import com.jwplayer.pub.api.events.IdleEvent;
import com.jwplayer.pub.api.events.PauseEvent;
import com.jwplayer.pub.api.events.PlayEvent;
import com.jwplayer.pub.api.events.PlaylistCompleteEvent;
import com.jwplayer.pub.api.events.PlaylistEvent;
import com.jwplayer.pub.api.events.PlaylistItemEvent;
import com.jwplayer.pub.api.events.ReadyEvent;
import com.jwplayer.pub.api.events.SeekEvent;
import com.jwplayer.pub.api.events.SeekedEvent;
import com.jwplayer.pub.api.events.SetupErrorEvent;
import com.jwplayer.pub.api.events.TimeEvent;
import com.jwplayer.pub.api.events.listeners.AdvertisingEvents;
import com.jwplayer.pub.api.events.listeners.VideoPlayerEvents;
import com.jwplayer.pub.api.fullscreen.FullscreenHandler;
import com.jwplayer.pub.api.license.LicenseUtil;
import com.jwplayer.pub.api.media.ads.AdBreak;
import com.jwplayer.pub.api.media.ads.AdClient;
import com.jwplayer.pub.api.media.captions.Caption;
import com.jwplayer.pub.api.media.playlists.PlaylistItem;
import com.jwplayer.pub.view.JWPlayerView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.jwplayer.pub.api.configuration.PlayerConfig.STRETCHING_UNIFORM;

public class RNJWPlayerView extends RelativeLayout implements
        VideoPlayerEvents.OnFullscreenListener,
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
        AdvertisingEvents.OnAdPauseListener,
        AdvertisingEvents.OnAdPlayListener,
//        AdvertisingEvents.OnAdRequestListener,
//        AdvertisingEvents.OnAdScheduleListener,
//        AdvertisingEvents.OnAdStartedListener,
//        AdvertisingEvents.OnAdBreakStartListener,
//        AdvertisingEvents.OnAdBreakEndListener,
//        AdvertisingEvents.OnAdClickListener,
//        AdvertisingEvents.OnAdCompleteListener,
//        AdvertisingEvents.OnAdCompanionsListener,
//        AdvertisingEvents.OnAdErrorListener,
//        AdvertisingEvents.OnAdImpressionListener,
//        AdvertisingEvents.OnAdMetaListener,
//        AdvertisingEvents.OnAdSkippedListener,
//        AdvertisingEvents.OnAdTimeListener,
//        AdvertisingEvents.OnAdViewableImpressionListener,

        AudioManager.OnAudioFocusChangeListener,
        LifecycleEventListener {
    public JWPlayerView mPlayerView = null;
    private JWPlayerView mFullscreenPlayer;

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
    String stretching = STRETCHING_UNIFORM;
    Double startTime = 0.0;

    Boolean autostart = true;
    Boolean controls = true;
    Boolean repeat = false;
    Boolean mute = false;
    Boolean displayTitle = false;
    Boolean displayDesc = false;
    Boolean nextUpDisplay = false;
    Boolean backgroundAudioEnabled = false;

    Boolean nativeFullScreen = false;
    Boolean landscapeOnFullScreen = false;
    Boolean fullScreenOnLandscape = false;
    Boolean portraitOnExitFullScreen = false;

    ReadableMap playlistItem; // PlaylistItem
    ReadableArray playlist; // List <PlaylistItem>
    Number currentPlayingIndex;

    private CastContext mCastContext;
    private CastSession mCastSession;
    private SessionManager mSessionManager;
    private MediaRouteButton mMediaRouteButton;
    private boolean mAutoHide;
    private Cast.Listener mCastClientListener;
    private GoogleApiClient mApiClient;

    private static final String GOOGLE_PLAY_STORE_PACKAGE_NAME_OLD = "com.google.market";
    private static final String GOOGLE_PLAY_STORE_PACKAGE_NAME_NEW = "com.android.vending";

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

    private void doBindService() {
        // Establish a connection with the service.  We use an explicit
        // class name because we want a specific service implementation that
        // we know will be running in our own process (and thus won't be
        // supporting component replacement by other applications).
        getAppContext().bindService(new Intent(RNJWPlayerView.mActivity,
                        MediaPlaybackService.class),
                mServiceConnection,
                Context.BIND_AUTO_CREATE);

    }

    private void doUnbindService() {
        if (mIsBound) {
            // Detach our existing connection.
            getAppContext().unbindService(mServiceConnection);
            mIsBound = false;
        }
    }

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

        getReactContext().addLifecycleEventListener(this);
    }

    private boolean doesPackageExist(String targetPackage) {
        try {
            getActivity().getPackageManager().getPackageInfo(targetPackage, PackageManager.GET_META_DATA);
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
        return true;
    }

    // Without the Google API's Chromecast won't work
    private boolean isGoogleApiAvailable(Context context) {
        boolean isOldPlayStoreInstalled = doesPackageExist(GOOGLE_PLAY_STORE_PACKAGE_NAME_OLD);
        boolean isNewPlayStoreInstalled = doesPackageExist(GOOGLE_PLAY_STORE_PACKAGE_NAME_NEW);

        boolean isPlaystoreInstalled = isNewPlayStoreInstalled||isOldPlayStoreInstalled;

        boolean isGoogleApiAvailable = GoogleApiAvailability.getInstance()
                .isGooglePlayServicesAvailable(context) == ConnectionResult.SUCCESS;
        return isPlaystoreInstalled && isGoogleApiAvailable;
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
        if (mPlayerView != null) {
            mPlayerView.getPlayer().stop();

            mPlayerView.getPlayer().removeAllListeners(this);
            mPlayerView = null;

            getReactContext().removeLifecycleEventListener(this);

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

    public void setupPlayerView(Boolean backgroundAudioEnabled) {
        if (mPlayerView != null) {

            // VideoPlayerEvents
            mPlayerView.getPlayer().addListener(EventType.READY, this);
            mPlayerView.getPlayer().addListener(EventType.PLAY, this);
            mPlayerView.getPlayer().addListener(EventType.PAUSE, this);
            mPlayerView.getPlayer().addListener(EventType.COMPLETE, this);
            mPlayerView.getPlayer().addListener(EventType.IDLE, this);
            mPlayerView.getPlayer().addListener(EventType.ERROR, this);
            mPlayerView.getPlayer().addListener(EventType.SETUP_ERROR, this);
            mPlayerView.getPlayer().addListener(EventType.BUFFER, this);
            mPlayerView.getPlayer().addListener(EventType.TIME, this);
            mPlayerView.getPlayer().addListener(EventType.PLAYLIST, this);
            mPlayerView.getPlayer().addListener(EventType.PLAYLIST_ITEM, this);
            mPlayerView.getPlayer().addListener(EventType.PLAYLIST_COMPLETE, this);
            mPlayerView.getPlayer().addListener(EventType.FIRST_FRAME, this);
            mPlayerView.getPlayer().addListener(EventType.CONTROLS, this);
            mPlayerView.getPlayer().addListener(EventType.CONTROLBAR_VISIBILITY, this);
            mPlayerView.getPlayer().addListener(EventType.DISPLAY_CLICK, this);
            mPlayerView.getPlayer().addListener(EventType.FULLSCREEN, this);
            mPlayerView.getPlayer().addListener(EventType.SEEK, this);
            mPlayerView.getPlayer().addListener(EventType.SEEKED, this);

            // Ad events
            mPlayerView.getPlayer().addListener(EventType.BEFORE_PLAY, this);
            mPlayerView.getPlayer().addListener(EventType.BEFORE_COMPLETE, this);
            mPlayerView.getPlayer().addListener(EventType.AD_PLAY, this);
            mPlayerView.getPlayer().addListener(EventType.AD_PAUSE, this);

            mPlayerView.getPlayer().setFullscreenHandler(new FullscreenHandler() {
                ViewGroup mPlayerViewContainer = (ViewGroup) mPlayerView.getParent();
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
//                        mPlayerView.destroySurface();

                        mPlayerViewContainer = (ViewGroup) mPlayerView.getParent();

                        // Remove the JWPlayerView from the list item.
                        if (mPlayerViewContainer != null) {
                            mPlayerViewContainer.removeView(mPlayerView);
                        }

                        // Initialize a new rendering surface.
//                        mPlayerView.initializeSurface();

                        // Add the JWPlayerView to the RootView as soon as the UI thread is ready.
                        mRootView.post(new Runnable() {
                            @Override
                            public void run() {
                                mRootView.addView(mPlayerView, new ViewGroup.LayoutParams(
                                        ViewGroup.LayoutParams.MATCH_PARENT,
                                        ViewGroup.LayoutParams.MATCH_PARENT
                                ));
                                mFullscreenPlayer = mPlayerView;
                            }
                        });
                    }

                    WritableMap eventEnterFullscreen = Arguments.createMap();
                    eventEnterFullscreen.putString("message", "onFullscreenRequested");
                    getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                            getId(),
                            "topFullScreenRequested",
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
//                        mPlayerView.destroySurface();

                        // Remove the player view from the root ViewGroup.
                        mRootView.removeView(mPlayerView);

                        // After we've detached the JWPlayerView we can safely reinitialize the surface.
//                        mPlayerView.initializeSurface();

                        // As soon as the UI thread has finished processing the current message queue it
                        // should add the JWPlayerView back to the list item.
                        mPlayerViewContainer.post(new Runnable() {
                            @Override
                            public void run() {
                                mPlayerViewContainer.addView(mPlayerView, new ViewGroup.LayoutParams(
                                        ViewGroup.LayoutParams.MATCH_PARENT,
                                        ViewGroup.LayoutParams.MATCH_PARENT
                                ));
                                mPlayerView.layout(mPlayerViewContainer.getLeft(), mPlayerViewContainer.getTop(), mPlayerViewContainer.getRight(), mPlayerViewContainer.getBottom());
                                mFullscreenPlayer = null;
                            }
                        });
                    }

                    WritableMap eventExitFullscreen = Arguments.createMap();
                    eventExitFullscreen.putString("message", "onFullscreenExitRequested");
                    getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                            getId(),
                            "topFullScreenExitRequested",
                            eventExitFullscreen);
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

            mPlayerView.getPlayer().setControls(true);
            mPlayerView.getPlayer().allowBackgroundAudio(backgroundAudioEnabled);
        }
    }

    public PlaylistItem getPlaylistItem (ReadableMap playlistItem) {
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

        if (playlistItem.hasKey("startTime")) {
            startTime = playlistItem.getDouble("startTime");
        }

        ArrayList<Caption> tracks = new ArrayList<>();

//        if (playlistItem.hasKey("tracks")) {
//            ReadableArray track = playlistItem.getArray("tracks");
//            if (track != null) {
//                for (int i = 0; i < track.size(); i++) {
//                    ReadableMap trackProp = track.getMap(i);
//                    if (trackProp != null && trackProp.hasKey("file")) {
//                        String file = trackProp.getString("file");
//                        String label = trackProp.getString("label");
//                        Caption caption = new Caption(file, CaptionType.CAPTIONS, label, false);
//                        tracks.add(caption);
//                    }
//                }
//            }
//        }

        ArrayList<AdBreak> adSchedule = new ArrayList<>();

        if (playlistItem.hasKey("adSchedule")) {
            ReadableArray ad = playlistItem.getArray("adSchedule");

            for (int i = 0; i < ad.size(); i++) {
                ReadableMap adBreakProp = ad.getMap(i);
                String offset = adBreakProp.hasKey("offset") ? adBreakProp.getString("offset") : "pre";
                if (adBreakProp.hasKey("tag")) {
                    AdBreak adBreak = new AdBreak.Builder().offset(offset).tag(adBreakProp.getString("tag")).build();
                    adSchedule.add(adBreak);
                }
            }
        }

        return new PlaylistItem.Builder()
                .file(file)
                .title(title)
                .description(desc)
                .image(image)
                .mediaId(mediaId)
                .startTime(startTime)
                .adSchedule(adSchedule)
                .tracks(tracks)
                .build();
    }

    public void setConfig(ReadableMap prop) {
        if (prop.hasKey("license")) {
            LicenseUtil.setLicenseKey(getReactContext(), prop.getString("license"));
        }

        if (prop.hasKey("items") && playlist != prop.getArray("items") && !Arrays.deepEquals(new ReadableArray[]{playlist}, new ReadableArray[]{prop.getArray("items")})) {
            playlist = prop.getArray("items");
            if (playlist != null && playlist.size() > 0) {
                mPlayList = new ArrayList<>();

                int j = 0;
                while (playlist.size() > j) {
                    playlistItem = playlist.getMap(j);

                    if (playlistItem != null) {
                        PlaylistItem newPlayListItem = this.getPlaylistItem((playlistItem));
                        mPlayList.add(newPlayListItem);
                    }

                    j++;
                }

                this.setupPlayer(prop);
            }
        } else {
//            if (mPlayerView != null && mPlayerView.getConfig().getFile() != null) {
//                boolean autostart = mPlayerView.getPlayer().getConfig().getAutostart();
//                if (autostart) {
//                    mPlayerView.getPlayer().play();
//                }
//            }
        }
    }

    private void setupPlayer(ReadableMap prop) {
        boolean autostart = false;
        if (prop.hasKey("autostart")) {
            autostart = prop.getBoolean("autostart");
        }

        int nextUpOffset = -10;
        if (prop.hasKey("nextUpOffset")) {
            nextUpOffset = prop.getInt("nextUpOffset");
        }

        List<AdBreak> adSchedule = new ArrayList<>();
        AdClient client;
        AdvertisingConfig advertisingConfig;

        if (prop.hasKey("adVmap")) {
            adVmap = prop.getString("adVmap");

            AdBreak adBreak = new AdBreak.Builder()
                    .tag(adVmap)
                    .build();

            adSchedule.add(adBreak);

            if (prop.hasKey("adClient")) {
                switch (prop.getInt("adClient")) {
                    case 1:
                        client = AdClient.IMA;
                        advertisingConfig = new ImaAdvertisingConfig.Builder().schedule(adSchedule).build();
                        break;
                    case 2:
                        client = AdClient.IMA_DAI;
                        advertisingConfig = new ImaDaiAdvertisingConfig.Builder().build();
                        break;
                    default:
                        client = AdClient.VAST;
                        advertisingConfig = new VastAdvertisingConfig.Builder()
                                .schedule(adSchedule)
                                .build();
                        break;
                }
            } else {
                client = AdClient.VAST;
                advertisingConfig = new VastAdvertisingConfig.Builder()
                        .schedule(adSchedule)
                        .build();
            }
        } else {
            client = AdClient.VAST;
            advertisingConfig = new VastAdvertisingConfig.Builder()
                    .schedule(adSchedule)
                    .build();
        }

        if (prop.hasKey("stretching")) {
            stretching = prop.getString("stretching");
        }

//        new UiConfig.Builder().build()

        PlayerConfig playerConfig = new PlayerConfig.Builder()
//                .skinConfig(skinConfig)
                .repeat(false)
//                .controls(true)
                .autostart(autostart)
                .displayTitle(true)
                .displayDescription(true)
//                .nextUpDisplay(true)
                .nextUpOffset(nextUpOffset)
                .advertisingConfig(advertisingConfig)
                .stretching(stretching)
                .playlist(mPlayList)
//                .uiConfig()
                .build();

        Context simpleContext = getNonBuggyContext(getReactContext(), getAppContext());

        this.destroyPlayer();
        
        mPlayerView = new JWPlayerView(simpleContext);
        mPlayerView.getPlayer().setup(playerConfig);

        setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
        mPlayerView.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));
        addView(mPlayerView);

        if (prop.hasKey("backgroundAudioEnabled")) {
            backgroundAudioEnabled = prop.getBoolean("backgroundAudioEnabled");
        }

        setupPlayerView(backgroundAudioEnabled);

        if (backgroundAudioEnabled) {
            audioManager = (AudioManager) simpleContext.getSystemService(Context.AUDIO_SERVICE);

            NotificationManager notificationManager = (NotificationManager)mActivity.getSystemService(Context.NOTIFICATION_SERVICE);
            mNotificationWrapper = new NotificationWrapper(notificationManager);
            mMediaSessionManager = new MediaSessionManager(simpleContext,
                    mPlayerView,
                    mNotificationWrapper);
        }
    }

    float dipToPix(float dip) {
        Resources r = getResources();
        return TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                dip,
                r.getDisplayMetrics()
        );
    }

    void showCastButton(float x, float y, Number width, Number height, boolean autoHide) {
        if (isGoogleApiAvailable(getContext())) {
            if (mMediaRouteButton == null) {
                mAutoHide = autoHide;

                mMediaRouteButton = new MediaRouteButton(getReactContext());
                CastButtonFactory.setUpMediaRouteButton(getReactContext(), mMediaRouteButton);

                mMediaRouteButton.setX(dipToPix(x));
                mMediaRouteButton.setY(dipToPix(y));

                if (width != null) {
                    mMediaRouteButton.setMinimumWidth(width.intValue());
                }

                if (height != null) {
                    mMediaRouteButton.setMinimumHeight(height.intValue());
                }

                addView(mMediaRouteButton);
                bringChildToFront(mMediaRouteButton);
            } else {
                mMediaRouteButton.setVisibility(VISIBLE);
            }

            setUpCastController();
        }
    }

    void hideCastButton() {
        if (mMediaRouteButton != null)  mMediaRouteButton.setVisibility(GONE);
    }

    void presentCastDialog() {
        MediaRouteChooserDialog dialog = new MediaRouteChooserDialog(getReactContext());
        dialog.show();
    }

    void setUpCastController() {
        if (mCastContext == null) {
            mCastContext = CastContext.getSharedInstance(getReactContext());
            mSessionManager = mCastContext.getSessionManager();
        }
    }

    int castState() {
        if (mCastContext != null) {
            return mCastContext.getCastState();
        }

        return -1;
    }

    CastDevice connectedDevice() {
        if (mCastContext != null && mCastContext.getSessionManager() != null && mCastContext.getSessionManager().getCurrentCastSession() != null) {
            return mCastContext.getSessionManager().getCurrentCastSession().getCastDevice();
        }

        return null;
    }

    List<CastDevice> availableDevice() {
        if (mCastContext != null) {
            MediaRouter router =
                    MediaRouter.getInstance(getReactContext());
            List<MediaRouter.RouteInfo> routes = router.getRoutes();

            List<CastDevice> devices = new ArrayList<>();

            for (MediaRouter.RouteInfo routeInfo : routes) {
                CastDevice device = CastDevice.getFromBundle(routeInfo.getExtras());
                if (device != null) {
                    devices.add(device);
                }
            }

            return devices;
        }

        return null;
    }

    // Audio Focus

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


    public void lowerApiOnAudioFocus(int focusChange) {
        switch (focusChange) {
            case AudioManager.AUDIOFOCUS_GAIN:
                if (!userPaused) {
                    boolean autostart = mPlayerView.getPlayer().getConfig().getAutostart();
                    if (autostart) {
                        mPlayerView.getPlayer().play();
                    }
                }
                break;
            case AudioManager.AUDIOFOCUS_LOSS:
                mPlayerView.getPlayer().pause();
                wasInterrupted = true;
                hasAudioFocus = false;
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                wasInterrupted = true;
                mPlayerView.getPlayer().pause();
                break;
            case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                // ... pausing or ducking depends on your app
                break;
        }
    }

    public void onAudioFocusChange(int focusChange) {
        if (mPlayerView != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                switch (focusChange) {
                    case AudioManager.AUDIOFOCUS_GAIN:
                        if (playbackDelayed || !userPaused) {
                            synchronized(focusLock) {
                                playbackDelayed = false;
                            }
                            boolean autostart = mPlayerView.getPlayer().getConfig().getAutostart();
                            if (autostart) {
                                mPlayerView.getPlayer().play();
                            }
                        }
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                        synchronized(focusLock) {
                            wasInterrupted = true;
                            playbackDelayed = false;
                        }
                        mPlayerView.getPlayer().pause();
                        hasAudioFocus = false;
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        synchronized(focusLock) {
                            wasInterrupted = true;
                            playbackDelayed = false;
                        }
                        mPlayerView.getPlayer().pause();
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

    // AdEvents
    
    @Override
    public void onAdPause(AdPauseEvent adPauseEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdPause");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdPause", event);
    }

    @Override
    public void onAdPlay(AdPlayEvent adPlayEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdPlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdPlay", event);
    }

    @Override
    public void onBeforeComplete(BeforeCompleteEvent beforeCompleteEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBeforeComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBeforeComplete", event);


        updateWakeLock(false);
    }

    @Override
    public void onBeforePlay(BeforePlayEvent beforePlayEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBeforePlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBeforePlay", event);
    }

    // VideoPlayerEvents

    @Override
    public void onAudioTrackChanged(AudioTrackChangedEvent audioTrackChangedEvent) {

    }

    @Override
    public void onAudioTracks(AudioTracksEvent audioTracksEvent) {

    }

    @Override
    public void onBuffer(BufferEvent bufferEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBuffer");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBuffer", event);

        updateWakeLock(true);
    }

    @Override
    public void onComplete(CompleteEvent completeEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topComplete", event);

        updateWakeLock(false);
    }

    @Override
    public void onControlBarVisibilityChanged(ControlBarVisibilityEvent controlBarVisibilityEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onControlBarVisible");
        event.putBoolean("controls", controlBarVisibilityEvent.isVisible());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topControlBarVisible", event);

        updateWakeLock(true);

        if (mAutoHide && mMediaRouteButton != null) {
            if (controlBarVisibilityEvent.isVisible()) {
                hideCastButton();
            } else {
                showCastButton(mMediaRouteButton.getX(), mMediaRouteButton.getY(), mMediaRouteButton.getWidth(), mMediaRouteButton.getHeight(), mAutoHide);
            }
        }
    }

    @Override
    public void onControls(ControlsEvent controlsEvent) {

    }

    @Override
    public void onDisplayClick(DisplayClickEvent displayClickEvent) {

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
    public void onFirstFrame(FirstFrameEvent firstFrameEvent) {

    }

    @Override
    public void onFullscreen(FullscreenEvent fullscreenEvent) {
        if (fullscreenEvent.getFullscreen()) {
            WritableMap eventExitFullscreen = Arguments.createMap();
            eventExitFullscreen.putString("message", "onFullscreen");
            getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                    getId(),
                    "topFullScreen",
                    eventExitFullscreen);
        } else {
            WritableMap eventExitFullscreen = Arguments.createMap();
            eventExitFullscreen.putString("message", "onFullscreenExit");
            getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                    getId(),
                    "topFullScreenExit",
                    eventExitFullscreen);
        }
    }

    @Override
    public void onIdle(IdleEvent idleEvent) {

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
    public void onPlay(PlayEvent playEvent) {
        if (backgroundAudioEnabled) {
            requestAudioFocus();
        }

        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlay", event);

        updateWakeLock(true);

        userPaused = false;
        wasInterrupted = false;
    }

    @Override
    public void onPlaylistComplete(PlaylistCompleteEvent playlistCompleteEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlaylistComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlaylistComplete", event);

        updateWakeLock(false);
    }

    @Override
    public void onPlaylistItem(PlaylistItemEvent playlistItemEvent) {
        if (!mIsBound && backgroundAudioEnabled) {
            doBindService();
        }

        currentPlayingIndex = playlistItemEvent.getIndex();

        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlaylistItem");
        event.putInt("index",playlistItemEvent.getIndex());
        Gson gson = new Gson();
        String json = gson.toJson(playlistItemEvent.getPlaylistItem());
        event.putString("playlistItem", json);
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlaylistItem", event);
    }

    @Override
    public void onPlaylist(PlaylistEvent playlistEvent) {

    }

    @Override
    public void onReady(ReadyEvent readyEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlayerReady");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topOnPlayerReady", event);

        updateWakeLock(true);
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
    
    // LifecycleEventListener

    @Override
    public void onHostResume() {

    }

    @Override
    public void onHostPause() {

    }

    @Override
    public void onHostDestroy() {

    }
}



package com.appgoalz.rnjwplayer;


import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import androidx.appcompat.app.AppCompatActivity;
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
import com.google.android.gms.cast.framework.CastContext;
import com.google.android.gms.cast.framework.CastSession;
import com.google.android.gms.cast.framework.SessionManager;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.gson.Gson;
import com.jwplayer.pub.api.JWPlayer;
import com.jwplayer.pub.api.background.MediaServiceController;
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
import com.jwplayer.pub.api.events.CaptionsChangedEvent;
import com.jwplayer.pub.api.events.CaptionsListEvent;
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
import com.jwplayer.pub.api.media.captions.CaptionType;
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
        VideoPlayerEvents.OnCaptionsListListener,
        VideoPlayerEvents.OnCaptionsChangedListener,

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
        LifecycleEventListener {
    public RNJWPlayer mPlayerView = null;
    public JWPlayer mPlayer = null;
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

    private MediaServiceController mMediaServiceController;

    private void doBindService() {
        mMediaServiceController.bindService();
    }

    private void doUnbindService() {
        mMediaServiceController.unbindService();
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
            mPlayer.stop();

            mPlayer.removeAllListeners(this);
            mPlayerView = null;

            getReactContext().removeLifecycleEventListener(this);

            doUnbindService();
        }
    }

    public void setupPlayerView(Boolean backgroundAudioEnabled) {
        if (mPlayerView != null) {

            // VideoPlayerEvents
            mPlayer.addListener(EventType.READY, this);
            mPlayer.addListener(EventType.PLAY, this);
            mPlayer.addListener(EventType.PAUSE, this);
            mPlayer.addListener(EventType.COMPLETE, this);
            mPlayer.addListener(EventType.IDLE, this);
            mPlayer.addListener(EventType.ERROR, this);
            mPlayer.addListener(EventType.SETUP_ERROR, this);
            mPlayer.addListener(EventType.BUFFER, this);
            mPlayer.addListener(EventType.TIME, this);
            mPlayer.addListener(EventType.PLAYLIST, this);
            mPlayer.addListener(EventType.PLAYLIST_ITEM, this);
            mPlayer.addListener(EventType.PLAYLIST_COMPLETE, this);
            mPlayer.addListener(EventType.FIRST_FRAME, this);
            mPlayer.addListener(EventType.CONTROLS, this);
            mPlayer.addListener(EventType.CONTROLBAR_VISIBILITY, this);
            mPlayer.addListener(EventType.DISPLAY_CLICK, this);
            mPlayer.addListener(EventType.FULLSCREEN, this);
            mPlayer.addListener(EventType.SEEK, this);
            mPlayer.addListener(EventType.SEEKED, this);
            mPlayer.addListener(EventType.CAPTIONS_LIST, this);
            mPlayer.addListener(EventType.CAPTIONS_CHANGED, this);

            // Ad events
            mPlayer.addListener(EventType.BEFORE_PLAY, this);
            mPlayer.addListener(EventType.BEFORE_COMPLETE, this);
            mPlayer.addListener(EventType.AD_PLAY, this);
            mPlayer.addListener(EventType.AD_PAUSE, this);

            mPlayer.setFullscreenHandler(new FullscreenHandler() {
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

//            mPlayer.setControls(true);
            mPlayer.allowBackgroundAudio(backgroundAudioEnabled);
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

        if (playlistItem.hasKey("tracks")) {
            ReadableArray track = playlistItem.getArray("tracks");
            if (track != null) {
                for (int i = 0; i < track.size(); i++) {
                    ReadableMap trackProp = track.getMap(i);
                    if (trackProp.hasKey("file")) {
                        String file = trackProp.getString("file");
                        String label = trackProp.getString("label");
                        Caption caption = new Caption.Builder().file(file).label(label).kind(CaptionType.CAPTIONS).isDefault(false).build();
                        tracks.add(caption);
                    }
                }
            }
        }

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
        } else {
            Log.e(TAG, "JW SDK license not set");
        }

        if (prop.hasKey("items") && playlist != prop.getArray("items") && !Arrays.deepEquals(new ReadableArray[]{playlist}, new ReadableArray[]{prop.getArray("items")})) {
            playlist = prop.getArray("items");
            if (playlist != null && playlist.size() > 0) {
                mPlayList = new ArrayList<>();

                int j = 0;
                while (playlist.size() > j) {
                    playlistItem = playlist.getMap(j);

                    PlaylistItem newPlayListItem = this.getPlaylistItem((playlistItem));
                    mPlayList.add(newPlayListItem);

                    j++;
                }

                this.setupPlayer(prop);
            }
        } else {
//            if (mPlayerView != null && mPlayerView.getConfig().getFile() != null) {
//                boolean autostart = mPlayer.getConfig().getAutostart();
//                if (autostart) {
//                    mPlayer.play();
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

        if (prop.hasKey("nativeFullScreen")) {
            nativeFullScreen = prop.getBoolean("nativeFullScreen");
        }

//        UiConfig uiConfig = new UiConfig.Builder().displayAllControls().build();

        PlayerConfig playerConfig = new PlayerConfig.Builder()
                .repeat(false)
                .autostart(autostart)
                .displayTitle(true)
                .displayDescription(true)
                .nextUpOffset(nextUpOffset)
                .advertisingConfig(advertisingConfig)
                .stretching(stretching)
                .playlist(mPlayList)
//                .uiConfig(uiConfig)
                .build();

        Context simpleContext = getNonBuggyContext(getReactContext(), getAppContext());

        this.destroyPlayer();

        mPlayerView = new RNJWPlayer(simpleContext);

//        mPlayerView.fullScreenOnLandscape
//        mPlayerView.exitFullScreenOnPortrait

        setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        mPlayerView.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));
        addView(mPlayerView);

        mPlayer = mPlayerView.getPlayer();
        mPlayer.setup(playerConfig);

        if (prop.hasKey("backgroundAudioEnabled")) {
            backgroundAudioEnabled = prop.getBoolean("backgroundAudioEnabled");
        }

        setupPlayerView(backgroundAudioEnabled);

        if (backgroundAudioEnabled) {
            mMediaServiceController = new MediaServiceController.Builder((AppCompatActivity) mActivity, mPlayer).build();
        }
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
//        if (backgroundAudioEnabled) {
//            requestAudioFocus();
//        }

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
        if (backgroundAudioEnabled) { // !mIsBound &&
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

    @Override
    public void onCaptionsChanged(CaptionsChangedEvent captionsChangedEvent) {

    }

    @Override
    public void onCaptionsList(CaptionsListEvent captionsListEvent) {

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



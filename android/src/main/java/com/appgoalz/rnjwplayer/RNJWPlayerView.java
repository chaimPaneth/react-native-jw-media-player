package com.appgoalz.rnjwplayer;


import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;

import androidx.appcompat.app.AppCompatActivity;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.google.common.collect.ImmutableMap;
import com.google.gson.Gson;
import com.jwplayer.pub.api.JsonHelper;
import com.jwplayer.pub.api.JWPlayer;
import com.jwplayer.pub.api.UiGroup;
import com.jwplayer.pub.api.background.MediaServiceController;
import com.jwplayer.pub.api.configuration.PlayerConfig;
import com.jwplayer.pub.api.configuration.UiConfig;
import com.jwplayer.pub.api.configuration.ads.AdvertisingConfig;
import com.jwplayer.pub.api.events.AdBreakEndEvent;
import com.jwplayer.pub.api.events.AdBreakIgnoredEvent;
import com.jwplayer.pub.api.events.AdBreakStartEvent;
import com.jwplayer.pub.api.events.AdClickEvent;
import com.jwplayer.pub.api.events.AdCompanionsEvent;
import com.jwplayer.pub.api.events.AdCompleteEvent;
import com.jwplayer.pub.api.events.AdErrorEvent;
import com.jwplayer.pub.api.events.AdImpressionEvent;
import com.jwplayer.pub.api.events.AdLoadedEvent;
import com.jwplayer.pub.api.events.AdLoadedXmlEvent;
import com.jwplayer.pub.api.events.AdMetaEvent;
import com.jwplayer.pub.api.events.AdPauseEvent;
import com.jwplayer.pub.api.events.AdPlayEvent;
import com.jwplayer.pub.api.events.AdRequestEvent;
import com.jwplayer.pub.api.events.AdScheduleEvent;
import com.jwplayer.pub.api.events.AdSkippedEvent;
import com.jwplayer.pub.api.events.AdStartedEvent;
import com.jwplayer.pub.api.events.AdTimeEvent;
import com.jwplayer.pub.api.events.AdViewableImpressionEvent;
import com.jwplayer.pub.api.events.AdWarningEvent;
import com.jwplayer.pub.api.events.AudioTrackChangedEvent;
import com.jwplayer.pub.api.events.AudioTracksEvent;
import com.jwplayer.pub.api.events.BeforeCompleteEvent;
import com.jwplayer.pub.api.events.BeforePlayEvent;
import com.jwplayer.pub.api.events.BufferEvent;
import com.jwplayer.pub.api.events.CaptionsChangedEvent;
import com.jwplayer.pub.api.events.CaptionsListEvent;
import com.jwplayer.pub.api.events.CastEvent;
import com.jwplayer.pub.api.events.CompleteEvent;
import com.jwplayer.pub.api.events.ControlBarVisibilityEvent;
import com.jwplayer.pub.api.events.ControlsEvent;
import com.jwplayer.pub.api.events.DisplayClickEvent;
import com.jwplayer.pub.api.events.ErrorEvent;
import com.jwplayer.pub.api.events.EventType;
import com.jwplayer.pub.api.events.FirstFrameEvent;
import com.jwplayer.pub.api.events.FullscreenEvent;
import com.jwplayer.pub.api.events.IdleEvent;
import com.jwplayer.pub.api.events.MetaEvent;
import com.jwplayer.pub.api.events.PauseEvent;
import com.jwplayer.pub.api.events.PipCloseEvent;
import com.jwplayer.pub.api.events.PipOpenEvent;
import com.jwplayer.pub.api.events.PlayEvent;
import com.jwplayer.pub.api.events.PlaybackRateChangedEvent;
import com.jwplayer.pub.api.events.PlaylistCompleteEvent;
import com.jwplayer.pub.api.events.PlaylistEvent;
import com.jwplayer.pub.api.events.PlaylistItemEvent;
import com.jwplayer.pub.api.events.ReadyEvent;
import com.jwplayer.pub.api.events.SeekEvent;
import com.jwplayer.pub.api.events.SeekedEvent;
import com.jwplayer.pub.api.events.SetupErrorEvent;
import com.jwplayer.pub.api.events.TimeEvent;
import com.jwplayer.pub.api.events.listeners.AdvertisingEvents;
import com.jwplayer.pub.api.events.listeners.CastingEvents;
import com.jwplayer.pub.api.events.listeners.PipPluginEvents;
import com.jwplayer.pub.api.events.listeners.VideoPlayerEvents;
import com.jwplayer.pub.api.fullscreen.FullscreenHandler;
import com.jwplayer.pub.api.license.LicenseUtil;
import com.jwplayer.pub.api.media.playlists.PlaylistItem;
import com.jwplayer.ui.views.CueMarkerSeekbar;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONObject;

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
        VideoPlayerEvents.OnPlaybackRateChangedListener,
        VideoPlayerEvents.OnCaptionsListListener,
        VideoPlayerEvents.OnCaptionsChangedListener,
        VideoPlayerEvents.OnMetaListener,

        CastingEvents.OnCastListener,

        PipPluginEvents.OnPipCloseListener,
        PipPluginEvents.OnPipOpenListener,

        AdvertisingEvents.OnBeforePlayListener,
        AdvertisingEvents.OnBeforeCompleteListener,
        AdvertisingEvents.OnAdPauseListener,
        AdvertisingEvents.OnAdPlayListener,
        AdvertisingEvents.OnAdRequestListener,
        AdvertisingEvents.OnAdScheduleListener,
        AdvertisingEvents.OnAdStartedListener,
        AdvertisingEvents.OnAdBreakStartListener,
        AdvertisingEvents.OnAdBreakEndListener,
        AdvertisingEvents.OnAdClickListener,
        AdvertisingEvents.OnAdCompleteListener,
        AdvertisingEvents.OnAdCompanionsListener,
        AdvertisingEvents.OnAdErrorListener,
        AdvertisingEvents.OnAdImpressionListener,
        AdvertisingEvents.OnAdMetaListener,
        AdvertisingEvents.OnAdSkippedListener,
        AdvertisingEvents.OnAdTimeListener,
        AdvertisingEvents.OnAdViewableImpressionListener,
        AdvertisingEvents.OnAdBreakIgnoredListener,
        AdvertisingEvents.OnAdWarningListener,
        AdvertisingEvents.OnAdLoadedListener,
        AdvertisingEvents.OnAdLoadedXmlListener,

        AudioManager.OnAudioFocusChangeListener,

        LifecycleEventListener {
    public RNJWPlayer mPlayerView = null;
    public JWPlayer mPlayer = null;

    private ViewGroup mRootView;

    // Props
    ReadableMap mConfig = null;
    ReadableArray mPlaylistProp = null;
    ReadableMap mColors = null;

    Boolean backgroundAudioEnabled = false;

    Boolean landscapeOnFullScreen = false;
    Boolean fullScreenOnLandscape = false;
    Boolean portraitOnExitFullScreen = false;
    Boolean exitFullScreenOnPortrait = false;

    Number currentPlayingIndex;

    private static final String TAG = "RNJWPlayerView";

    static ReactActivity mActivity;

    Window mWindow;

    public static AudioManager audioManager;

    final Object focusLock = new Object();

    AudioFocusRequest focusRequest;

    boolean hasAudioFocus = false;
    boolean playbackDelayed = false;
    boolean playbackNowAuthorized = false;
    boolean userPaused = false;
    boolean wasInterrupted = false;

    private static int sessionDepth = 0;
    boolean isInBackground = false;

    private final ReactApplicationContext mAppContext;

    private ThemedReactContext mThemedReactContext;

    private MediaServiceController mMediaServiceController;

    private void doBindService() {
        if (mMediaServiceController != null) {
            mMediaServiceController.bindService();
        }
    }

    private void doUnbindService() {
        if (mMediaServiceController != null) {
            mMediaServiceController.unbindService();
            mMediaServiceController = null;
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

        mActivity = (ReactActivity) getActivity();
        if (mActivity != null) {
            mWindow = mActivity.getWindow();
        }

        mRootView = mActivity.findViewById(android.R.id.content);

        getReactContext().addLifecycleEventListener(this);
    }

    public ReactApplicationContext getAppContext() {
        return mAppContext;
    }

    public ThemedReactContext getReactContext() {
        return mThemedReactContext;
    }

    public Activity getActivity() {
        if (!contextHasBug(mAppContext.getCurrentActivity())) {
            return mAppContext.getCurrentActivity();
        } else if (contextHasBug(mThemedReactContext)) {
            if (!contextHasBug(mThemedReactContext.getCurrentActivity())) {
                return mThemedReactContext.getCurrentActivity();
            } else if (!contextHasBug(mThemedReactContext.getApplicationContext())) {
                return (Activity) mThemedReactContext.getApplicationContext();
            }
        }

        return mThemedReactContext.getReactApplicationContext().getCurrentActivity();
    }

    public void destroyPlayer() {
        if (mPlayer != null) {
            mPlayer.stop();

            mPlayer.removeListeners(this,
                    // VideoPlayerEvents
                    EventType.READY,
                    EventType.PLAY,
                    EventType.PAUSE,
                    EventType.COMPLETE,
                    EventType.IDLE,
                    EventType.ERROR,
                    EventType.SETUP_ERROR,
                    EventType.BUFFER,
                    EventType.TIME,
                    EventType.PLAYLIST,
                    EventType.PLAYLIST_ITEM,
                    EventType.PLAYLIST_COMPLETE,
                    EventType.FIRST_FRAME,
                    EventType.CONTROLS,
                    EventType.CONTROLBAR_VISIBILITY,
                    EventType.DISPLAY_CLICK,
                    EventType.FULLSCREEN,
                    EventType.SEEK,
                    EventType.SEEKED,
                    EventType.PLAYBACK_RATE_CHANGED,
                    EventType.CAPTIONS_LIST,
                    EventType.CAPTIONS_CHANGED,
                    EventType.META,

                    // Ad events
                    EventType.BEFORE_PLAY,
                    EventType.BEFORE_COMPLETE,
                    EventType.AD_BREAK_START,
                    EventType.AD_BREAK_END,
                    EventType.AD_BREAK_IGNORED,
                    EventType.AD_CLICK,
                    EventType.AD_COMPANIONS,
                    EventType.AD_COMPLETE,
                    EventType.AD_ERROR,
                    EventType.AD_IMPRESSION,
                    EventType.AD_WARNING,
                    EventType.AD_LOADED,
                    EventType.AD_LOADED_XML,
                    EventType.AD_META,
                    EventType.AD_PAUSE,
                    EventType.AD_PLAY,
                    EventType.AD_REQUEST,
                    EventType.AD_SCHEDULE,
                    EventType.AD_SKIPPED,
                    EventType.AD_STARTED,
                    EventType.AD_TIME,
                    EventType.AD_VIEWABLE_IMPRESSION,
                    // Cast event
                    EventType.CAST,
                    // Pip events
                    EventType.PIP_CLOSE,
                    EventType.PIP_OPEN
            );

            mPlayer  = null;
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
        if (mPlayer != null) {

            mPlayer.addListeners(this,
                    // VideoPlayerEvents
                    EventType.READY,
                    EventType.PLAY,
                    EventType.PAUSE,
                    EventType.COMPLETE,
                    EventType.IDLE,
                    EventType.ERROR,
                    EventType.SETUP_ERROR,
                    EventType.BUFFER,
                    EventType.TIME,
                    EventType.PLAYLIST,
                    EventType.PLAYLIST_ITEM,
                    EventType.PLAYLIST_COMPLETE,
                    EventType.FIRST_FRAME,
                    EventType.CONTROLS,
                    EventType.CONTROLBAR_VISIBILITY,
                    EventType.DISPLAY_CLICK,
                    EventType.FULLSCREEN,
                    EventType.SEEK,
                    EventType.SEEKED,
                    EventType.PLAYBACK_RATE_CHANGED,
                    EventType.CAPTIONS_LIST,
                    EventType.CAPTIONS_CHANGED,
                    EventType.META,
                    // Ad events
                    EventType.BEFORE_PLAY,
                    EventType.BEFORE_COMPLETE,
                    EventType.AD_BREAK_START,
                    EventType.AD_BREAK_END,
                    EventType.AD_BREAK_IGNORED,
                    EventType.AD_CLICK,
                    EventType.AD_COMPANIONS,
                    EventType.AD_COMPLETE,
                    EventType.AD_ERROR,
                    EventType.AD_IMPRESSION,
                    EventType.AD_WARNING,
                    EventType.AD_LOADED,
                    EventType.AD_LOADED_XML,
                    EventType.AD_META,
                    EventType.AD_PAUSE,
                    EventType.AD_PLAY,
                    EventType.AD_REQUEST,
                    EventType.AD_SCHEDULE,
                    EventType.AD_SKIPPED,
                    EventType.AD_STARTED,
                    EventType.AD_TIME,
                    EventType.AD_VIEWABLE_IMPRESSION,
                    // Cast event
                    EventType.CAST,
                    // Pip events
                    EventType.PIP_CLOSE,
                    EventType.PIP_OPEN
            );

            mPlayer.setFullscreenHandler(new fullscreenHandler());

            mPlayer.allowBackgroundAudio(backgroundAudioEnabled);
        }
    }

    private class fullscreenHandler implements FullscreenHandler {
        ViewGroup mPlayerViewContainer = (ViewGroup) mPlayerView.getParent();
        private View mDecorView;

        @Override
        public void onFullscreenRequested() {
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

            mPlayerViewContainer = (ViewGroup) mPlayerView.getParent();

            // Remove the JWPlayerView from the list item.
            if (mPlayerViewContainer != null) {
                mPlayerViewContainer.removeView(mPlayerView);
            }

            // Initialize a new rendering surface.
            // mPlayerView.initializeSurface();

            // Add the JWPlayerView to the RootView as soon as the UI thread is ready.
            mRootView.post(new Runnable() {
                @Override
                public void run() {
                    mRootView.addView(mPlayerView, new ViewGroup.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.MATCH_PARENT));
                }
            });

            WritableMap eventEnterFullscreen = Arguments.createMap();
            eventEnterFullscreen.putString("message", "onFullscreenRequested");
            getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                    getId(),
                    "topFullScreenRequested",
                    eventEnterFullscreen);
        }

        @Override
        public void onFullscreenExitRequested() {
            mDecorView.setSystemUiVisibility(
                    View.SYSTEM_UI_FLAG_VISIBLE // clear the hide system flags
            );

            // Enter portrait mode
            if (portraitOnExitFullScreen) {
                mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }

            // Remove the player view from the root ViewGroup.
            mRootView.removeView(mPlayerView);

            // As soon as the UI thread has finished processing the current message queue it
            // should add the JWPlayerView back to the list item.
            mPlayerViewContainer.post(new Runnable() {
                @Override
                public void run() {
                    mPlayerViewContainer.addView(mPlayerView, new ViewGroup.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            ViewGroup.LayoutParams.MATCH_PARENT));
                    mPlayerView.layout(mPlayerViewContainer.getLeft(), mPlayerViewContainer.getTop(),
                            mPlayerViewContainer.getRight(), mPlayerViewContainer.getBottom());
                }
            });

            WritableMap eventExitFullscreen = Arguments.createMap();
            eventExitFullscreen.putString("message", "onFullscreenExitRequested");
            getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                    getId(),
                    "topFullScreenExitRequested",
                    eventExitFullscreen);
        }

        @Override
        public void onAllowRotationChanged(boolean b) {
            Log.e(TAG, "onAllowRotationChanged: " + b );
        }

        @Override
        public void onAllowFullscreenPortraitChanged(boolean allowFullscreenPortrait) {
            Log.e(TAG, "onAllowFullscreenPortraitChanged: " + allowFullscreenPortrait );
        }

        @Override
        public void updateLayoutParams(ViewGroup.LayoutParams layoutParams) {
            // View.setSystemUiVisibility(int).
            // Log.e(TAG, "updateLayoutParams: "+layoutParams );
        }

        @Override
        public void setUseFullscreenLayoutFlags(boolean b) {
            // View.setSystemUiVisibility(int).
            // Log.e(TAG, "setUseFullscreenLayoutFlags: "+b );
        }
    }

    public void setConfig(ReadableMap prop) {
        if (mConfig == null || !mConfig.equals(prop)) {
            // TODO what if playlist is a url or something?
            // TODO How to handle a jwConfig vs old config
            if (mConfig != null && isOnlyDiff(prop, "playlist") && mPlayer != null) { // still safe check, even with JW
                                                                                      // JSON change
                PlayerConfig oldConfig = mPlayer.getConfig();
                PlayerConfig config = new PlayerConfig.Builder()
                        .autostart(oldConfig.getAutostart())
                        .nextUpOffset(oldConfig.getNextUpOffset())
                        .repeat(oldConfig.getRepeat())
                        .relatedConfig(oldConfig.getRelatedConfig())
                        .displayDescription(oldConfig.getDisplayDescription())
                        .displayTitle(oldConfig.getDisplayTitle())
                        .advertisingConfig(oldConfig.getAdvertisingConfig())
                        .stretching(oldConfig.getStretching())
                        .uiConfig(oldConfig.getUiConfig())
                        .playlist(Util.createPlaylist(mPlaylistProp))
                        .allowCrossProtocolRedirects(oldConfig.getAllowCrossProtocolRedirects())
                        .preload(oldConfig.getPreload())
                        .useTextureView(oldConfig.useTextureView())
                        .thumbnailPreview(oldConfig.getThumbnailPreview())
                        .mute(oldConfig.getMute())
                        .build();

                mPlayer.setup(config);
            } else {
                if (prop.hasKey("license")) {
                    new LicenseUtil().setLicenseKey(getReactContext(), prop.getString("license"));
                } else {
                    Log.e(TAG, "JW SDK license not set");
                }

                // The entire config is different (other than the "playlist" key)
                this.setupPlayer(prop);
            }
        } else {
            // No change
        }

        mConfig = prop;
    }

    public boolean isOnlyDiff(ReadableMap prop, String keyName) {
        // Convert ReadableMap to HashMap
        Map<String, Object> mConfigMap = mConfig.toHashMap();
        Map<String, Object> propMap = prop.toHashMap();

        Map<String, Object> differences = new HashMap<>();

        // Find keys in mConfig that aren't in prop or have different values
        for (Map.Entry<String, Object> entry : mConfigMap.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();

            if (!propMap.containsKey(key) || !propMap.get(key).equals(value)) {
                differences.put(key, value);
            }
        }

        // Find keys in prop that aren't in mConfig
        for (String key : propMap.keySet()) {
            if (!mConfigMap.containsKey(key)) {
                differences.put(key, propMap.get(key));
            }
        }

        return differences.size() == 1 && differences.containsKey(keyName);
    }

    boolean playlistNotTheSame(ReadableMap prop) {
        return prop.hasKey("playlist") && mPlaylistProp != prop.getArray("playlist") && !Arrays
                .deepEquals(new ReadableArray[] { mPlaylistProp }, new ReadableArray[] { prop.getArray("playlist") });
    }

    private void setupPlayer(ReadableMap prop) {
        // Legacy
        PlayerConfig.Builder configBuilder = new PlayerConfig.Builder();

        // TODO check if I'm a JW config before doign below
        JSONObject obj;
        PlayerConfig jwConfig = null;
        Boolean isJwConfig = false;
        try {
            obj = MapUtil.toJSONObject(prop);
            jwConfig = JsonHelper.parseConfigJson(obj);
            isJwConfig = true;
        } catch (Exception ex) {
            Log.e("RNJWPlayerView", ex.toString());
        }

        // TODO TODO TODO -- Fix the reading of fields when isJwConfig is true

        if (!isJwConfig) {
            // Legacy
            if (playlistNotTheSame(prop)) {
                List<PlaylistItem> playlist = new ArrayList<>();
                mPlaylistProp = prop.getArray("playlist");
                if (mPlaylistProp != null && mPlaylistProp.size() > 0) {

                    int j = 0;
                    while (mPlaylistProp.size() > j) {
                        ReadableMap playlistItem = mPlaylistProp.getMap(j);

                        PlaylistItem newPlayListItem = Util.getPlaylistItem((playlistItem));
                        playlist.add(newPlayListItem);
                        j++;
                    }
                }

                configBuilder.playlist(playlist);
            }

            // Legacy
            if (prop.hasKey("autostart")) {
                boolean autostart = prop.getBoolean("autostart");
                configBuilder.autostart(autostart);
            }

            // Legacy
            if (prop.hasKey("nextUpStyle")) {
                ReadableMap nextUpStyle = prop.getMap("nextUpStyle");
                if (nextUpStyle != null && nextUpStyle.hasKey("offsetSeconds")
                        && nextUpStyle.hasKey("offsetPercentage")) {
                    int offsetSeconds = prop.getInt("offsetSeconds");
                    int offsetPercentage = prop.getInt("offsetPercentage");
                    configBuilder.nextUpOffset(offsetSeconds).nextUpOffsetPercentage(offsetPercentage);
                }
            }

            // Legacy
            if (prop.hasKey("repeat")) {
                boolean repeat = prop.getBoolean("repeat");
                configBuilder.repeat(repeat);
            }

            // Legacy
            if (prop.hasKey("styling")) {
                ReadableMap styling = prop.getMap("styling");
                if (styling != null) {
                    if (styling.hasKey("displayDescription")) {
                        boolean displayDescription = styling.getBoolean("displayDescription");
                        configBuilder.displayDescription(displayDescription);
                    }

                    if (styling.hasKey("displayTitle")) {
                        boolean displayTitle = styling.getBoolean("displayTitle");
                        configBuilder.displayTitle(displayTitle);
                    }

                    if (styling.hasKey("colors")) {
                        mColors = styling.getMap("colors");
                    }
                }
            }

            // Legacy
            if (prop.hasKey("advertising")) {
                ReadableMap ads = prop.getMap("advertising");
                AdvertisingConfig advertisingConfig = RNJWPlayerAds.getAdvertisingConfig(ads);
                if (advertisingConfig != null) {
                    configBuilder.advertisingConfig(advertisingConfig);
                }
            }

            // Legacy
            if (prop.hasKey("stretching")) {
                String stretching = prop.getString("stretching");
                configBuilder.stretching(stretching);
            }

            // Legacy
            // this isn't the ideal way to do controls...
            // Better to just expose the `.setControls` method
            if (prop.hasKey("controls")) {
                boolean controls = prop.getBoolean("controls");
                if (!controls) {
                    UiConfig uiConfig = new UiConfig.Builder().hideAllControls().build();
                    configBuilder.uiConfig(uiConfig);
                }
            }

            // Legacy
            if (prop.hasKey("hideUIGroups")) {
                ReadableArray uiGroupsArray = prop.getArray("hideUIGroups");
                UiConfig.Builder hideConfigBuilder = new UiConfig.Builder().displayAllControls();
                for (int i = 0; i < uiGroupsArray.size(); i++) {
                    UiGroup uiGroup = GROUP_TYPES.get(uiGroupsArray.getString(i));
                    if (uiGroup != null) {
                        hideConfigBuilder.hide(uiGroup);
                    }
                }
                UiConfig hideJwControlbarUiConfig = hideConfigBuilder.build();
                configBuilder.uiConfig(hideJwControlbarUiConfig);
            }
        }

        Context simpleContext = getNonBuggyContext(getReactContext(), getAppContext());

        this.destroyPlayer();

        mPlayerView = new RNJWPlayer(simpleContext);

        mPlayerView.setFocusable(true);
        mPlayerView.setFocusableInTouchMode(true);

        setLayoutParams(
                new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        mPlayerView.setLayoutParams(new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT));
        addView(mPlayerView);

        if (prop.hasKey("controls")) { // Hack for controls hiding not working right away
            mPlayerView.getPlayer().setControls(prop.getBoolean("controls"));
        }

        if (prop.hasKey("fullScreenOnLandscape")) {
            fullScreenOnLandscape = prop.getBoolean("fullScreenOnLandscape");
            mPlayerView.fullScreenOnLandscape = fullScreenOnLandscape;
        }

        if (prop.hasKey("exitFullScreenOnPortrait")) {
            exitFullScreenOnPortrait = prop.getBoolean("exitFullScreenOnPortrait");
            mPlayerView.exitFullScreenOnPortrait = exitFullScreenOnPortrait;
        }

        mPlayer = mPlayerView.getPlayer();

        if (isJwConfig) {
            mPlayer.setup(jwConfig);
        } else {
            PlayerConfig playerConfig = configBuilder.build();
            mPlayer.setup(playerConfig);
        }

        if (mActivity != null && prop.hasKey("pipEnabled")) {
            boolean pipEnabled = prop.getBoolean("pipEnabled");
            if (pipEnabled) {
                mPlayer.registerActivityForPip(mActivity, mActivity.getSupportActionBar());
            } else {
                mPlayer.deregisterActivityForPip();
            }
        }

        // Legacy
        // This isn't the ideal way to do this on Android
        if (mColors != null) {
            if (mColors.hasKey("backgroundColor")) {
                mPlayerView.setBackgroundColor(Color.parseColor("#" + mColors.getString("backgroundColor")));
            }

            if (mColors.hasKey("buttons")) {

            }

            if (mColors.hasKey("timeslider")) {
                CueMarkerSeekbar seekBar = findViewById(com.longtailvideo.jwplayer.R.id.controlbar_seekbar);
                ReadableMap timeslider = mColors.getMap("timeslider");
                if (timeslider != null) {
                    LayerDrawable progressDrawable = (LayerDrawable) seekBar.getProgressDrawable();

                    if (timeslider.hasKey("progress")) {
                        // seekBar.getProgressDrawable().setColorFilter(Color.parseColor("#" +
                        // timeslider.getString("progress")), PorterDuff.Mode.SRC_IN);
                        Drawable processDrawable = progressDrawable.findDrawableByLayerId(android.R.id.progress);
                        processDrawable.setColorFilter(Color.parseColor("#" + timeslider.getString("progress")),
                                PorterDuff.Mode.SRC_IN);
                    }

                    if (timeslider.hasKey("buffer")) {
                        Drawable secondaryProgressDrawable = progressDrawable
                                .findDrawableByLayerId(android.R.id.secondaryProgress);
                        secondaryProgressDrawable.setColorFilter(Color.parseColor("#" + timeslider.getString("buffer")),
                                PorterDuff.Mode.SRC_IN);
                    }

                    if (timeslider.hasKey("rail")) {
                        Drawable backgroundDrawable = progressDrawable.findDrawableByLayerId(android.R.id.background);
                        backgroundDrawable.setColorFilter(Color.parseColor("#" + timeslider.getString("rail")),
                                PorterDuff.Mode.SRC_IN);
                    }

                    if (timeslider.hasKey("thumb")) {
                        seekBar.getThumb().setColorFilter(Color.parseColor("#" + timeslider.getString("thumb")),
                                PorterDuff.Mode.SRC_IN);
                    }
                }
            }
        }

        // Needed to handle volume control
        audioManager = (AudioManager) simpleContext.getSystemService(Context.AUDIO_SERVICE);

        if (prop.hasKey("backgroundAudioEnabled")) {
            backgroundAudioEnabled = prop.getBoolean("backgroundAudioEnabled");
        }

        setupPlayerView(backgroundAudioEnabled);

        if (backgroundAudioEnabled) {
            audioManager = (AudioManager) simpleContext.getSystemService(Context.AUDIO_SERVICE);
            // Throws a fatal error if using a playlistURL instead of manually created playlist
            // Related to SDK-11346
            mMediaServiceController = new MediaServiceController.Builder((AppCompatActivity) mActivity, mPlayer)
                    .build();
        }
    }

    // Audio Focus

    public void requestAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
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
                        // .setWillPauseWhenDucked(true)
                        .setOnAudioFocusChangeListener(this)
                        .build();

                int res = audioManager.requestAudioFocus(focusRequest);
                synchronized (focusLock) {
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
        } else {
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
        if (mPlayer != null) {
            int initVolume = mPlayer.getVolume();

            switch (focusChange) {
                case AudioManager.AUDIOFOCUS_GAIN:
                    if (!userPaused) {
                        setVolume(initVolume);

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
                    mPlayer.pause();
                    wasInterrupted = true;
                    break;
                case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                    setVolume(initVolume / 2);
                    break;
            }
        }
    }

    public void onAudioFocusChange(int focusChange) {
        if (mPlayer != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                int initVolume = mPlayer.getVolume();

                switch (focusChange) {
                    case AudioManager.AUDIOFOCUS_GAIN:
                        if (playbackDelayed || !userPaused) {
                            synchronized (focusLock) {
                                playbackDelayed = false;
                            }

                            setVolume(initVolume);

                            boolean autostart = mPlayer.getConfig().getAutostart();
                            if (autostart) {
                                mPlayer.play();
                            }
                        }
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS:
                        mPlayer.pause();
                        synchronized (focusLock) {
                            wasInterrupted = true;
                            playbackDelayed = false;
                        }
                        hasAudioFocus = false;
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT:
                        mPlayer.pause();
                        synchronized (focusLock) {
                            wasInterrupted = true;
                            playbackDelayed = false;
                        }
                        break;
                    case AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK:
                        setVolume(initVolume / 2);
                        break;
                }
            } else {
                lowerApiOnAudioFocus(focusChange);
            }
        }
    }

    private void setVolume(int volume) {
        if (!mPlayer.getMute()) {
            mPlayer.setVolume(volume);
        }
    }

    private void updateWakeLock(boolean enable) {
        if (mWindow != null) {
            if (enable && !isInBackground) {
                mWindow.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            } else {
                mWindow.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        }
    }

    // Ad events

    @Override
    public void onAdLoaded(AdLoadedEvent adLoadedEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adLoadedEvent.getClient().toString());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdLoadedXml(AdLoadedXmlEvent adLoadedXmlEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adLoadedXmlEvent.getClient().toString());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdPause(AdPauseEvent adPauseEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("reason", adPauseEvent.getAdPauseReason().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypePause));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdPlay(AdPlayEvent adPlayEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("reason", adPlayEvent.getAdPlayReason().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypePlay));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdBreakEnd(AdBreakEndEvent adBreakEndEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adBreakEndEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeAdBreakEnd));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdBreakStart(AdBreakStartEvent adBreakStartEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adBreakStartEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeAdBreakStart));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdBreakIgnored(AdBreakIgnoredEvent adBreakIgnoredEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adBreakIgnoredEvent.getClient().toString());
        // missing type code
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdClick(AdClickEvent adClickEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adClickEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeClicked));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdCompanions(AdCompanionsEvent adCompanionsEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeCompanion));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdComplete(AdCompleteEvent adCompleteEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adCompleteEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeComplete));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdError(AdErrorEvent adErrorEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlayerAdError");
        event.putInt("code", adErrorEvent.getCode());
        event.putInt("adErrorCode", adErrorEvent.getAdErrorCode());
        event.putString("error", adErrorEvent.getMessage());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlayerAdError", event);
    }

    @Override
    public void onAdWarning(AdWarningEvent adWarningEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlayerAdWarning");
        event.putInt("code", adWarningEvent.getCode());
        event.putInt("adErrorCode", adWarningEvent.getAdErrorCode());
        event.putString("error", adWarningEvent.getMessage());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlayerAdWarning", event);
    }

    @Override
    public void onAdImpression(AdImpressionEvent adImpressionEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adImpressionEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeImpression));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdMeta(AdMetaEvent adMetaEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adMetaEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeMeta));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdRequest(AdRequestEvent adRequestEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adRequestEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeRequest));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdSchedule(AdScheduleEvent adScheduleEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adScheduleEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeSchedule));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdSkipped(AdSkippedEvent adSkippedEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putString("client", adSkippedEvent.getClient().toString());
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeSkipped));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdStarted(AdStartedEvent adStartedEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdEvent");
        event.putInt("type", Util.getEventTypeValue(Util.AdEventType.JWAdEventTypeStarted));
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdEvent", event);
    }

    @Override
    public void onAdTime(AdTimeEvent adTimeEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAdTime");
        event.putDouble("position", adTimeEvent.getPosition());
        event.putDouble("duration", adTimeEvent.getDuration());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAdTime", event);
    }

    @Override
    public void onAdViewableImpression(AdViewableImpressionEvent adViewableImpressionEvent) {
        // send everything?
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
        // Ideally done in onFirstFrame instead
        // if (backgroundAudioEnabled) {
        //     doBindService();
        // }

        WritableMap event = Arguments.createMap();
        event.putString("message", "onBeforePlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBeforePlay", event);
    }

    // Audio Events

    @Override
    public void onAudioTracks(AudioTracksEvent audioTracksEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onAudioTracks");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topAudioTracks", event);
    }

    @Override
    public void onAudioTrackChanged(AudioTrackChangedEvent audioTrackChangedEvent) {

    }

    // Player Events

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
        event.putBoolean("visible", controlBarVisibilityEvent.isVisible());
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
            event.putString("description", errorEvent.getMessage());
        }
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlayerError", event);

        updateWakeLock(false);
    }

    @Override
    public void onFirstFrame(FirstFrameEvent firstFrameEvent) {
        if (backgroundAudioEnabled) {
            doBindService();
            requestAudioFocus();
        }
    }

    @Override
    public void onFullscreen(FullscreenEvent fullscreenEvent) {
        if (fullscreenEvent.getFullscreen()) {
            if (mPlayerView != null) {
                mPlayerView.requestFocus();
            }

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
        // Ideally done in onFirstFrame instead
        // if (backgroundAudioEnabled) {
        //     doBindService();
        //     requestAudioFocus();
        // }

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
        // Ideally done in onFirstFrame instead
        // if (backgroundAudioEnabled) {
        //     doBindService();
        // }

        currentPlayingIndex = playlistItemEvent.getIndex();

        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlaylistItem");
        event.putInt("index", playlistItemEvent.getIndex());
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
    public void onPlaybackRateChanged(PlaybackRateChangedEvent playbackRateChangedEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onRateChanged");
        event.putDouble("rate", playbackRateChangedEvent.getPlaybackRate());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topRateChanged", event);
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

    @Override
    public void onMeta(MetaEvent metaEvent) {

    }

    // Picture in Picture events

    @Override
    public void onPipClose(PipCloseEvent pipCloseEvent) {

    }

    @Override
    public void onPipOpen(PipOpenEvent pipOpenEvent) {

    }

    // Casting events

    @Override
    public void onCast(CastEvent castEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onCasting");
        event.putString("device", castEvent.getDeviceName());
        event.putBoolean("active", castEvent.isActive());
        event.putBoolean("available", castEvent.isAvailable());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topCasting", event);
    }

    // LifecycleEventListener

    @Override
    public void onHostResume() {
        sessionDepth++;
        if (sessionDepth == 1) {
            isInBackground = false;
        }
    }

    @Override
    public void onHostPause() {
        if (sessionDepth > 0)
            sessionDepth--;
        if (sessionDepth == 0) {
            isInBackground = true;
        }
    }

    @Override
    public void onHostDestroy() {
        this.destroyPlayer();
    }

    // utils
    private final Map<String, Integer> CLIENT_TYPES = MapBuilder.of(
            "vast", 0,
            "ima", 1,
            "ima_dai", 2);

    private final Map<String, UiGroup> GROUP_TYPES = ImmutableMap.<String, UiGroup>builder()
            .put("overlay", UiGroup.OVERLAY)
            .put("control_bar", UiGroup.CONTROLBAR)
            .put("center_controls", UiGroup.CENTER_CONTROLS)
            .put("next_up", UiGroup.NEXT_UP)
            .put("error", UiGroup.ERROR)
            .put("playlist", UiGroup.PLAYLIST)
            .put("controls_container", UiGroup.PLAYER_CONTROLS_CONTAINER)
            .put("settings_menu", UiGroup.SETTINGS_MENU)
            .put("quality_submenu", UiGroup.SETTINGS_QUALITY_SUBMENU)
            .put("captions_submenu", UiGroup.SETTINGS_CAPTIONS_SUBMENU)
            .put("playback_submenu", UiGroup.SETTINGS_PLAYBACK_SUBMENU)
            .put("audiotracks_submenu", UiGroup.SETTINGS_AUDIOTRACKS_SUBMENU)
            .put("casting_menu", UiGroup.CASTING_MENU).build();
}



package com.appgoalz.rnjwplayer;


import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.ViewGroup;
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
import com.longtailvideo.jwplayer.events.FullscreenEvent;
import com.longtailvideo.jwplayer.events.IdleEvent;
import com.longtailvideo.jwplayer.events.PauseEvent;
import com.longtailvideo.jwplayer.events.PlayEvent;
import com.longtailvideo.jwplayer.events.PlaylistCompleteEvent;
import com.longtailvideo.jwplayer.events.PlaylistEvent;
import com.longtailvideo.jwplayer.events.PlaylistItemEvent;
import com.longtailvideo.jwplayer.events.ReadyEvent;
import com.longtailvideo.jwplayer.events.SetupErrorEvent;
import com.longtailvideo.jwplayer.events.TimeEvent;
import com.longtailvideo.jwplayer.events.listeners.AdvertisingEvents;
import com.longtailvideo.jwplayer.events.listeners.VideoPlayerEvents;
import com.longtailvideo.jwplayer.fullscreen.FullscreenHandler;
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
        AdvertisingEvents.OnBeforePlayListener,
        AdvertisingEvents.OnBeforeCompleteListener {

    public RNJWPlayer mPlayer = null;

    List<PlaylistItem> mPlayList = null;

    //Props
    String file = "";
    String image = "";
    String title = "";
    String desc = "";
    String mediaId = "";
    String customStyle;

    Boolean autostart = true;
    Boolean controls = true;
    Boolean repeat = false;
    Boolean displayTitle = false;
    Boolean displayDesc = false;
    Boolean nextUpDisplay = false;

    ReadableMap playlistItem; // PlaylistItem
    ReadableArray playlist; // List <PlaylistItem>
    Number currentPlayingIndex;

    private static final String TAG = "RNJWPlayerView";

    Activity mActivity;

    private final ReactApplicationContext mAppContext;

    private ThemedReactContext mThemedReactContext;

//    public static  String type="";

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

    public void removeListeners() {
        mPlayer.removeOnReadyListener(this);
        mPlayer.removeOnPlayListener(this);
        mPlayer.removeOnPauseListener(this);
        mPlayer.removeOnCompleteListener(this);
        mPlayer.removeOnIdleListener(this);
        mPlayer.removeOnErrorListener(this);
        mPlayer.removeOnSetupErrorListener(this);
        mPlayer.removeOnBufferListener(this);
        mPlayer.removeOnTimeListener(this);
        mPlayer.removeOnPlaylistListener(this);
        mPlayer.removeOnPlaylistItemListener(this);
        mPlayer.removeOnPlaylistCompleteListener(this);
//        mPlayer.removeOnBeforePlayListener(this);
//        mPlayer.removeOnBeforeCompleteListener(this);
        mPlayer.removeOnControlsListener(this);
        mPlayer.removeOnControlBarVisibilityListener(this);
        mPlayer.removeOnDisplayClickListener(this);
        mPlayer.removeOnFullscreenListener(this);
    }

    public void setupPlayerView() {
        mPlayer.addOnReadyListener(this);
        mPlayer.addOnPlayListener(this);
        mPlayer.addOnPauseListener(this);
        mPlayer.addOnCompleteListener(this);
        mPlayer.addOnIdleListener(this);
        mPlayer.addOnErrorListener(this);
        mPlayer.addOnSetupErrorListener(this);
        mPlayer.addOnBufferListener(this);
        mPlayer.addOnTimeListener(this);
        mPlayer.addOnPlaylistListener(this);
        mPlayer.addOnPlaylistItemListener(this);
        mPlayer.addOnPlaylistCompleteListener(this);
//        mPlayer.addOnBeforePlayListener(this);
//        mPlayer.addOnBeforeCompleteListener(this);
        mPlayer.addOnControlsListener(this);
        mPlayer.addOnControlBarVisibilityListener(this);
        mPlayer.addOnDisplayClickListener(this);
        mPlayer.addOnFullscreenListener(this);
        mPlayer.setFullscreenHandler(new FullscreenHandler() {
            @Override
            public void onFullscreenRequested() {
                WritableMap eventEnterFullscreen = Arguments.createMap();
                eventEnterFullscreen.putString("message", "onFullscreen");
                getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                        getId(),
                        "topFullScreen",
                        eventEnterFullscreen);
            }

            @Override
            public void onFullscreenExitRequested() {
                WritableMap eventExitFullscreen = Arguments.createMap();
                eventExitFullscreen.putString("message", "onFullscreenExit");
                getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(
                        getId(),
                        "topFullScreenExit",
                        eventExitFullscreen);
//                mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }

            @Override
            public void onResume() {

            }

            @Override
            public void onPause() {

            }

            @Override
            public void onDestroy() {

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

                        PlayerConfig playerConfig = new PlayerConfig.Builder()
                                .skinConfig(skinConfig)
                                .repeat(false)
                                .controls(true)
                                .autostart(false)
                                .displayTitle(true)
                                .displayDescription(true)
                                .nextUpDisplay(true)
                                .stretching(STRETCHING_UNIFORM)
                                .build();

                        mPlayer = new RNJWPlayer(getNonBuggyContext(getReactContext(), getAppContext()), playerConfig);
                        setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
                        mPlayer.setLayoutParams(new LinearLayout.LayoutParams(
                                LinearLayout.LayoutParams.MATCH_PARENT,
                                LinearLayout.LayoutParams.MATCH_PARENT));
                        addView(mPlayer);

                        setupPlayerView();

                        if (playlistItem.hasKey("autostart")) {
                            mPlayer.getConfig().setAutostart(playlistItem.getBoolean("autostart"));
                        }

                        mPlayer.load(newPlayListItem);
                    } else {
                        mPlayer.play();
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
                    skinConfig = getCustomSkinConfig(playlistItem.getString("playerStyle"));
                } else if (customStyle != null && !customStyle.isEmpty()) {
                    skinConfig = getCustomSkinConfig(customStyle);
                } else {
                    skinConfig = new SkinConfig.Builder().build();
                }

                PlayerConfig playerConfig = new PlayerConfig.Builder()
                        .skinConfig(skinConfig)
                        .repeat(false)
                        .controls(true)
                        .autostart(false)
                        .displayTitle(true)
                        .displayDescription(true)
                        .nextUpDisplay(true)
                        .stretching(STRETCHING_UNIFORM)
                        .build();

                mPlayer = new RNJWPlayer(getNonBuggyContext(getReactContext(), getAppContext()), playerConfig);

                setupPlayerView();

                if (playlist.getMap(0).hasKey("autostart")) {
                    mPlayer.getConfig().setAutostart(playlist.getMap(0).getBoolean("autostart"));
                }

                mPlayer.load(mPlayList);
                mPlayer.play();
            }
        }
    }

    public void setCustomStyle(String name) {
        if (this.mPlayer != null) {
            PlayerConfig config = getCustomConfig(getCustomSkinConfig((name)));
            this.mPlayer.setup(config);
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

    }


    @Override
    public void onBeforeComplete(BeforeCompleteEvent beforeCompleteEvent) {

    }

    @Override
    public void onIdle(IdleEvent idleEvent) {

    }

    @Override
    public void onPlaylist(PlaylistEvent playlistEvent) {

    }

    public void resetPlaylistItem()
    {
        playlistItem = null;
    }

    @Override
    public void onPlaylistItem(PlaylistItemEvent playlistItemEvent) {
        currentPlayingIndex = playlistItemEvent.getIndex();

        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlaylistItem");
        event.putInt("index",playlistItemEvent.getIndex());
        event.putString("playlistItem", playlistItemEvent.getPlaylistItem().toJson().toString());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlaylistItem", event);
    }

    @Override
    public void onPlaylistComplete(PlaylistCompleteEvent playlistCompleteEvent) {

    }

    @Override
    public void onBuffer(BufferEvent bufferEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onBuffer");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topBuffer", event);
    }

    @Override
    public void onPlay(PlayEvent playEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlay");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlay", event);
    }

    @Override
    public void onReady(ReadyEvent readyEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPlayerReady");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topOnPlayerReady", event);
    }

    @Override
    public void onPause(PauseEvent pauseEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onPause");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPause", event);
    }

    @Override
    public void onComplete(CompleteEvent completeEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onComplete");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topComplete", event);
    }

    @Override
    public void onFullscreen(FullscreenEvent fullscreenEvent) {

    }

    @Override
    public void onError(ErrorEvent errorEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onError");
        event.putString("error", errorEvent.getException().toString());
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topPlayerError", event);
    }

    @Override
    public void onSetupError(SetupErrorEvent setupErrorEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onSetupError");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topSetupPlayerError", event);
    }

    @Override
    public void onTime(TimeEvent timeEvent) {
        WritableMap event = Arguments.createMap();
        event.putString("message", "onTime");
        getReactContext().getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topTime", event);
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
    }

}


package com.appgoalz.rnjwplayer;

import android.app.Activity;
import android.content.pm.ActivityInfo;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
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

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nonnull;

import static com.longtailvideo.jwplayer.configuration.PlayerConfig.STRETCHING_UNIFORM;

public class RNJWPlayerViewManager extends SimpleViewManager<RNJWPlayerView> implements VideoPlayerEvents.OnFullscreenListener,
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

  public static final String REACT_CLASS = "RNJWPlayer";

  public static final int COMMAND_PLAY = 101;
  public static final int COMMAND_PAUSE = 102;
  public static final int COMMAND_STOP = 103;
  public static final int COMMAND_TOGGLE_SPEED = 104;
  public static  String type="";

  /**
   * The application window
   */

  Activity mActivity;

  private static PlayerConfig mPlayerConfig = null;
  private ThemedReactContext mContext;
  public static RNJWPlayerView mPlayerView = null;
  List<PlaylistItem> mPlayList = null;

  //Props
  String file = "";
  String image = "";
  String title = "";
  String desc = "";
  String mediaId = "";

  Boolean autostart = true;
  Boolean controls = true;
  Boolean repeat = false;
  Boolean displayTitle = false;
  Boolean displayDesc = false;
  Boolean nextUpDisplay = false;

  ReadableMap playlistItem; // PlaylistItem
  ReadableArray playlist; // List <PlaylistItem>
  Number currentPlayingIndex;

  private static final String TAG = "RNJWPlayerViewManager";

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  @Override
  public RNJWPlayerView createViewInstance(ThemedReactContext context) {

    mContext = context;

    mActivity = mContext.getCurrentActivity();

    mPlayerView = new RNJWPlayerView(mContext.getBaseContext());
    return mPlayerView;
  }

  public void removeListeners() {
    mPlayerView.mPlayer.removeOnReadyListener(this);
    mPlayerView.mPlayer.removeOnPlayListener(this);
    mPlayerView.mPlayer.removeOnPauseListener(this);
    mPlayerView.mPlayer.removeOnCompleteListener(this);
    mPlayerView.mPlayer.removeOnIdleListener(this);
    mPlayerView.mPlayer.removeOnErrorListener(this);
    mPlayerView.mPlayer.removeOnSetupErrorListener(this);
    mPlayerView.mPlayer.removeOnBufferListener(this);
    mPlayerView.mPlayer.removeOnTimeListener(this);
    mPlayerView.mPlayer.removeOnPlaylistListener(this);
    mPlayerView.mPlayer.removeOnPlaylistItemListener(this);
    mPlayerView.mPlayer.removeOnPlaylistCompleteListener(this);
    //mPlayerView.mPlayer.removeOnBeforePlayListener(this);
    //mPlayerView.mPlayer.removeOnBeforeCompleteListener(this);
    mPlayerView.mPlayer.removeOnControlsListener(this);
    mPlayerView.mPlayer.removeOnControlBarVisibilityListener(this);
    mPlayerView.mPlayer.removeOnDisplayClickListener(this);
    mPlayerView.mPlayer.removeOnFullscreenListener(this);
  }

  public void setupPlayerView() {
    mPlayerView.mPlayer.addOnReadyListener(this);
    mPlayerView.mPlayer.addOnPlayListener(this);
    mPlayerView.mPlayer.addOnPauseListener(this);
    mPlayerView.mPlayer.addOnCompleteListener(this);
    mPlayerView.mPlayer.addOnIdleListener(this);
    mPlayerView.mPlayer.addOnErrorListener(this);
    mPlayerView.mPlayer.addOnSetupErrorListener(this);
    mPlayerView.mPlayer.addOnBufferListener(this);
    mPlayerView.mPlayer.addOnTimeListener(this);
    mPlayerView.mPlayer.addOnPlaylistListener(this);
    mPlayerView.mPlayer.addOnPlaylistItemListener(this);
    mPlayerView.mPlayer.addOnPlaylistCompleteListener(this);
    //mPlayerView.mPlayer.addOnBeforePlayListener(this);
    //mPlayerView.mPlayer.addOnBeforeCompleteListener(this);
    mPlayerView.mPlayer.addOnControlsListener(this);
    mPlayerView.mPlayer.addOnControlBarVisibilityListener(this);
    mPlayerView.mPlayer.addOnDisplayClickListener(this);
    mPlayerView.mPlayer.addOnFullscreenListener(this);
    mPlayerView.mPlayer.setFullscreenHandler(new FullscreenHandler() {
      @Override
      public void onFullscreenRequested() {
        WritableMap eventEnterFullscreen = Arguments.createMap();
        eventEnterFullscreen.putString("message", "onFullscreen");
        ReactContext reactContext = (ReactContext) mContext;
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                mPlayerView.getId(),
                "topFullScreen",
                eventEnterFullscreen);
      }

      @Override
      public void onFullscreenExitRequested() {
        WritableMap eventExitFullscreen = Arguments.createMap();
        eventExitFullscreen.putString("message", "onFullscreenExit");
        ReactContext reactContext = (ReactContext) mContext;
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                mPlayerView.getId(),
                "topFullScreenExit",
                eventExitFullscreen);
        mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
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

    mPlayerView.mPlayer.setControls(true);
    mPlayerView.mPlayer.setBackgroundAudio(true); // TODO: - add as prop
  }

  public void setCustomStyle(String name) {
    if (mPlayerView.mPlayer != null) {
      PlayerConfig config = getCustomConfig(getCustomSkinConfig((name)));
      mPlayerView.mPlayer.setup(config);
    }
  }

  @ReactProp(name = "file")
  public void setFile(View view, String prop) {
    if (file!=prop) {
      file = prop;
    }
  }

  @ReactProp(name = "mediaId")
  public void setMediaId(View view, String prop) {
    if (mediaId!=prop) {
      mediaId = prop;
    }
  }

  @ReactProp(name = "image")
  public void setImage(View view, String prop) {
    if(image!=prop) {
      image = prop;
    }
  }

  @ReactProp(name = "title")
  public void setTitle(View view, String prop) {
    if(title!=prop) {
      title = prop;
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(View view, String prop) {
    if(desc!=prop) {
      desc = prop;
    }
  }

  @ReactProp(name = "displayTitle")
  public void setDisplayTitle(View view, Boolean prop) {
    if(displayTitle!=prop) {
      displayTitle = prop;

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.getConfig().setDisplayTitle(displayTitle);
      }
    }
  }

  @ReactProp(name = "displayDesc")
  public void setDisplayDescription(View view, Boolean prop) {
    if(displayDesc!=prop) {
      displayDesc = prop;

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.getConfig().setDisplayDescription(displayDesc);
      }
    }
  }

  @ReactProp(name = "autostart")
  public void setAutostart(View view, Boolean prop) {
    if(autostart!=prop) {
      autostart = prop;

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.getConfig().setAutostart(autostart);
      }
    }
  }

  @ReactProp(name = "controls")
  public void setControls(View view, Boolean prop) {
    if(controls!=prop) {
      controls = prop;

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.getConfig().setControls(controls);
        mPlayerView.mPlayer.setControls(controls);
      }
    }
  }

  @ReactProp(name = "repeat")
  public void setRepeat(View view, Boolean prop) {
    if(repeat!=prop) {
      repeat = prop;

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.getConfig().setRepeat(repeat);
      }
    }
  }

  @ReactProp(name = "colors")
  public void setColors(View view, ReadableMap prop) {
    if (prop != null) {
      if (prop.hasKey("icons")) {
        mPlayerConfig.getSkinConfig().setControlBarIcons("#" + prop.getString("icons"));
      }

      if (prop.hasKey("timeslider")) {
        ReadableMap timeslider = prop.getMap("timeslider");

        if (timeslider.hasKey("progress")) {
          mPlayerConfig.getSkinConfig().setTimeSliderProgress("#" + timeslider.getString("progress"));
        }

        if (timeslider.hasKey("rail")) {
          mPlayerConfig.getSkinConfig().setTimeSliderRail("#" + timeslider.getString("rail"));
        }
      }

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.setup(mPlayerConfig);
      }
    }
  }

  @ReactProp(name = "playerStyle")
  public void setPlayerStyle(View view, String prop) {
    if (prop != null) {
      setCustomStyle(prop); // Todo: - add local var for custom style
    }
  }

  @ReactProp(name = "nextUpDisplay")
  public void setNextUpDisplay(View view, Boolean prop) {
    if(nextUpDisplay!=prop) {
      nextUpDisplay = prop;

      if (mPlayerView.mPlayer != null) {
        mPlayerView.mPlayer.getConfig().setNextUpDisplay(nextUpDisplay);
      }
    }
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

  public SkinConfig getCustomSkinConfig(String name) {
    return new SkinConfig.Builder()
            .name(name)
            .url(String.format("file:///android_asset/%s.css", name))
            .build();
  }

  @ReactProp(name = "playlistItem")
  public void setPlaylistItem(View view, ReadableMap prop) {
    if(playlistItem != prop) {
      playlistItem = prop;

      if (playlistItem != null) {
        if (playlistItem.hasKey("file")) {
          String newFile = playlistItem.getString("file");

          if (mPlayerView.mPlayer == null || mPlayerView.mPlayer.getPlaylistItem() == null) {
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
            } else {
              skinConfig = new SkinConfig.Builder().build();
            }

            mPlayerConfig = new PlayerConfig.Builder()
                    .skinConfig(skinConfig)
                    .repeat(false)
                    .controls(true)
                    .autostart(false)
                    .displayTitle(true)
                    .displayDescription(true)
                    .nextUpDisplay(true)
                    .stretching(STRETCHING_UNIFORM)
                    .build();

            mPlayerView.mPlayer = new RNJWPlayer(mContext.getBaseContext(), mPlayerConfig);
            mPlayerView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
            mPlayerView.mPlayer.setLayoutParams(new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.MATCH_PARENT));
            mPlayerView.addView(mPlayerView.mPlayer);

            setupPlayerView();

            if (playlistItem.hasKey("autostart")) {
              mPlayerView.mPlayer.getConfig().setAutostart(playlistItem.getBoolean("autostart"));
            }

            mPlayerView.mPlayer.load(newPlayListItem);
          } else {
            mPlayerView.mPlayer.play();
          }
        }
      }
    }
  }

  public void reset()
  {
    mPlayerView = null;
    mPlayerConfig = null;

    removeListeners();
  }

  public void resetPlaylistItem()
  {
    playlistItem = null;
  }

  public void resetPlaylist()
  {
    playlist = null;
  }

  @ReactProp(name = "playlist")
  public void setPlaylist(View view, ReadableArray prop) {
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
        } else {
          skinConfig = new SkinConfig.Builder().build();
        }

        mPlayerConfig = new PlayerConfig.Builder()
                .skinConfig(skinConfig)
                .repeat(false)
                .controls(true)
                .autostart(false)
                .displayTitle(true)
                .displayDescription(true)
                .nextUpDisplay(true)
                .stretching(STRETCHING_UNIFORM)
                .build();

        mPlayerView.mPlayer = new RNJWPlayer(mContext.getBaseContext(), mPlayerConfig);

        setupPlayerView();

        if (playlist.getMap(0).hasKey("autostart")) {
          mPlayerView.mPlayer.getConfig().setAutostart(playlist.getMap(0).getBoolean("autostart"));
        }

        mPlayerView.mPlayer.load(mPlayList);
        mPlayerView.mPlayer.play();
      }
    }
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

  @Override
  public void onPlaylistItem(PlaylistItemEvent playlistItemEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onPlaylistItem");
    event.putInt("index",playlistItemEvent.getIndex());

    currentPlayingIndex = playlistItemEvent.getIndex();

    event.putString("playlistItem",playlistItemEvent.getPlaylistItem().toJson().toString());
    Log.i("playlistItem", playlistItemEvent.getPlaylistItem().toJson().toString());

    try {
      JSONObject jObj = new JSONObject(playlistItemEvent.getPlaylistItem().toJson().toString());
      JSONArray array = jObj.getJSONArray("sources");
      jObj = new JSONObject(String.valueOf(array.get(0)));
      type = jObj.getString("type");
      Log.e(TAG, "onPlaylistItem: TYPE : " + type);

    } catch (JSONException e) {
      e.printStackTrace();
    }
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topPlaylistItem",
            event);

  }

  @Override
  public void onPlaylistComplete(PlaylistCompleteEvent playlistCompleteEvent) {

  }

  @Override
  public void onBuffer(BufferEvent bufferEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onBuffer");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topBuffer",
            event);
  }

  @Override
  public void onPlay(PlayEvent playEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onPlay");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topPlay",
            event);
  }

  @Override
  public void onReady(ReadyEvent readyEvent) {
    Log.e(TAG, "onReady triggered");
    WritableMap event = Arguments.createMap();
    event.putString("message", "onPlayerReady");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topOnPlayerReady",
            event);
  }

  @Override
  public void onPause(PauseEvent pauseEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onPause");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topPause",
            event);
  }

  @Override
  public void onComplete(CompleteEvent completeEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onComplete");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topComplete",
            event);
  }

  @Override
  public void onFullscreen(FullscreenEvent fullscreenEvent) {

  }

  @Override
  public void onError(ErrorEvent errorEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onError");
    event.putString("error",errorEvent.getException().toString());
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topPlayerError",
            event);
  }

  @Override
  public void onSetupError(SetupErrorEvent setupErrorEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onSetupError");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topSetupPlayerError",
            event);
  }

  @Override
  public void onTime(TimeEvent timeEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onTime");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topTime",
            event);
  }

  @Override
  public void onControls(ControlsEvent controlsEvent) {

  }

  @Override
  public void onControlBarVisibilityChanged(ControlBarVisibilityEvent controlBarVisibilityEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onControlBarVisible");
    event.putBoolean("controls", controlBarVisibilityEvent.isVisible());
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topControlBarVisible",
            event);
  }

  public Map getExportedCustomBubblingEventTypeConstants() {
    return MapBuilder.builder()
            .put(
                    "topPlayerError",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onPlayerError")))
            .put("topSetupPlayerError",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onSetupPlayerError")))
            .put("topTime",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onTime")))
            .put("topBuffer",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onBuffer")))
            .put("topFullScreen",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onFullScreen")))
            .put("topFullScreenExit",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onFullScreenExit")))
            .put("topPause",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onPause")))
            .put("topPlay",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onPlay")))
            .put("topComplete",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onComplete")))
            .put("topPlaylistItem",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onPlaylistItem")))
            .put("topControlBarVisible",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onControlBarVisible")))
            .put("topOnPlayerReady",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onPlayerReady")))
            .build();
  }

  public static <K, V> Map<K, V> CreateMap(
          K k1, V v1, K k2, V v2, K k3, V v3, K k4, V v4) {
    Map map = new HashMap<K, V>();
    map.put(k1, v1);
    map.put(k2, v2);
    map.put(k3, v3);
    map.put(k4, v4);
    return map;
  }

  @Nullable
  @Override
  public Map<String, Integer> getCommandsMap() {
    return MapBuilder.of(
            "play", COMMAND_PLAY,
            "pause", COMMAND_PAUSE,
            "stop", COMMAND_STOP,
            "toggleSpeed", COMMAND_TOGGLE_SPEED
    );
  }

  @Override
  public void receiveCommand(RNJWPlayerView root, int commandId, @Nullable ReadableArray args) {
    super.receiveCommand(root, commandId, args);

    switch (commandId) {
      case COMMAND_PLAY:
        play(root);
        break;
      case COMMAND_PAUSE:
        pause(root);
        break;
      case COMMAND_STOP:
        stop(root);
        break;
      case COMMAND_TOGGLE_SPEED:
        toggleSpeed(root);
        break;
      default:
        //do nothing!!!!
    }
  }

  public void play(RNJWPlayerView root) {
    root.mPlayer.play();
  }

  public void pause(RNJWPlayerView root) {
    root.mPlayer.pause();
  }

  public void stop(RNJWPlayerView root) {
    root.mPlayer.stop();
  }

  public void toggleSpeed(RNJWPlayerView root) {
    float rate = root.mPlayer.getPlaybackRate();
    if (rate < 2) {
      root.mPlayer.setPlaybackRate(rate += 0.5);
    } else {
      root.mPlayer.setPlaybackRate((float) 0.5);
    }
  }

  @Override
  public void onDropViewInstance(@Nonnull RNJWPlayerView view) {
    super.onDropViewInstance(view);

    this.reset();
  }
}
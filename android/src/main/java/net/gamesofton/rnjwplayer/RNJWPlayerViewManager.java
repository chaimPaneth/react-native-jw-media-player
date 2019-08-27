
package net.gamesofton.rnjwplayer;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.media.AudioManager;
import android.os.Handler;
import android.support.annotation.Nullable;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

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
import java.util.concurrent.TimeUnit;

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
        AdvertisingEvents.OnBeforeCompleteListener,
        AudioManager.OnAudioFocusChangeListener {

  public static final String REACT_CLASS = "RNJWPlayer";

  public static final int COMMAND_PLAY = 101;
  public static final int COMMAND_PAUSE = 102;
  public static final int COMMAND_STOP = 103;
  public static final int COMMAND_TOGGLE_SPEED = 104;
  public static  String type="";

  /**
   * The application window
   */
  Window mWindow;

  Activity mActivity;

  private PlayerConfig mPlayerConfig;
  private ThemedReactContext mContext;
  public static RNJWPlayerView mPlayerView = null;
//  PlaylistItem mPlayListItem = null;
  List<PlaylistItem> mPlayList = null;

  //Props
  String file = "";
  String image = "";
  String title = "";
  String desc = "";
  String mediaId = "";
//  Number time;

  Boolean autostart = true;
  Boolean controls = true;
  Boolean repeat = false;
  Boolean displayTitle = false;
  Boolean displayDesc = false;
  Boolean nextUpDisplay = false;

  ReadableMap playlistItem; // PlaylistItem
  ReadableArray playlist; // List <PlaylistItem>
  String playlistId;
  String comparePlaylistId;
  Number currentPlayingIndex;

  private static final String TAG = "RNJWPlayerViewManager";
  private Handler mHandler;
  public static AudioManager audioManager;


  @Override
  public String getName() {
    // Tell React the name of the module
    // https://facebook.github.io/react-native/docs/native-components-android.html#1-create-the-viewmanager-subclass
    return REACT_CLASS;
  }

  @Override
  public RNJWPlayerView createViewInstance(ThemedReactContext context) {

    mContext = context;

    mActivity = mContext.getCurrentActivity();
    if (mActivity != null) {
      mWindow = mActivity.getWindow();
    }

    mPlayerConfig = new PlayerConfig.Builder()
            .skinConfig(new SkinConfig.Builder().build())
            .repeat(false)
            .controls(true)
            .displayTitle(true)
            .displayDescription(true)
            .nextUpDisplay(true)
            .stretching(STRETCHING_UNIFORM)
            .build();

    setDefaultStyle();

    mPlayerView = new RNJWPlayerView(mContext.getBaseContext(), mPlayerConfig);
    audioManager = (AudioManager) mContext.getSystemService(Context.AUDIO_SERVICE);
    mPlayerView.addOnPlayListener(this);
    mPlayerView.addOnPauseListener(this);
    mPlayerView.addOnCompleteListener(this);
    mPlayerView.addOnIdleListener(this);
    mPlayerView.addOnErrorListener(this);
    mPlayerView.addOnSetupErrorListener(this);
    mPlayerView.addOnBufferListener(this);
    mPlayerView.addOnTimeListener(this);
    mPlayerView.addOnPlaylistListener(this);
    mPlayerView.addOnPlaylistItemListener(this);
    mPlayerView.addOnPlaylistCompleteListener(this);
    //mPlayerView.addOnBeforePlayListener(this);
    //mPlayerView.addOnBeforeCompleteListener(this);
    mPlayerView.addOnControlsListener(this);
    mPlayerView.addOnControlBarVisibilityListener(this);
    mPlayerView.addOnDisplayClickListener(this);
    mPlayerView.addOnFullscreenListener(this);
    mPlayerView.setFullscreenHandler(new FullscreenHandler() {
      @Override
      public void onFullscreenRequested() {
        WritableMap eventEnterFullscreen = Arguments.createMap();
        eventEnterFullscreen.putString("message", "onFullscreen");
        ReactContext reactContext = (ReactContext) mContext;
        mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
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
        mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                mPlayerView.getId(),
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

      }

      @Override
      public void onAllowRotationChanged(boolean b) {
        Log.e(TAG, "onAllowRotationChanged: "+b );
      }

      @Override
      public void updateLayoutParams(ViewGroup.LayoutParams layoutParams) {

      }

      @Override
      public void setUseFullscreenLayoutFlags(boolean b) {

      }
    });

    mPlayerView.setControls(true);

    return mPlayerView;
  }

  public void setDefaultStyle() {
    mPlayerConfig.getSkinConfig().setControlBarIcons("#E7ECEF");
    mPlayerConfig.getSkinConfig().setTimeSliderProgress("#3A5EA6");
    mPlayerConfig.getSkinConfig().setTimeSliderRail("#FFFFFF");
  }

  public void setCustomStyle(String name) {
    SkinConfig skinConfig = new SkinConfig.Builder()
            .name(name)
            .url(String.format("file:///android_asset/%s.css", name))
            .build();

    mPlayerConfig.setSkinConfig(skinConfig);
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

  private void buildPlaylistItem() {
    //mPlayerView.stop();

    PlaylistItem newPlayListItem = new PlaylistItem();

    if (file != null && !file.isEmpty() && (mPlayerView.getPlaylistItem() == null || !file.equals(mPlayerView.getPlaylistItem().getFile()))) {
      newPlayListItem.setFile(file);

      if (title != null && !title.isEmpty()) {
        newPlayListItem.setTitle(title);
      }

      if (desc != null && !desc.isEmpty()) {
        newPlayListItem.setDescription(desc);
      }

      if (image != null && !image.isEmpty()) {
        newPlayListItem.setImage(image);
      }

      if (mediaId != null && !mediaId.isEmpty()) {
        newPlayListItem.setMediaId(mediaId);
      }

      mPlayerView.load(newPlayListItem);
//    if (time != null) {
//      int seekTime = Integer.valueOf(time);
//      if (seekTime > 0) {
//        mPlayerView.seek(seekTime);
//      }
//    }
      mPlayerView.play();

//    mPlayerView.getConfig().setFile(file);
//    mPlayerView.getConfig().setImage(image);
//    mPlayerView.getConfig().setSkinConfig();

//    mPlayerView.getConfig().setAutostart(autostart);
//    mPlayerView.getConfig().setRepeat(repeat);
//    mPlayerView.getConfig().setControls(controls);
//      mPlayerView.setControls(controls);
//    mPlayerView.getConfig().setDisplayTitle(displayTitle);
//    mPlayerView.getConfig().setDisplayDescription(displayDesc);
    }
  }

  @ReactProp(name = "file")
  public void setFile(View view, String prop) {
    if (file!=prop) {
      file = prop;

//      buildPlaylistItem();
//
//      mPlayerView.play();
    }
  }

  @ReactProp(name = "mediaId")
  public void setMediaId(View view, String prop) {
    if (mediaId!=prop) {
      mediaId = prop;

//      buildPlaylistItem();
    }
  }

  @ReactProp(name = "image")
  public void setImage(View view, String prop) {
    if(image!=prop) {
      image = prop;

//      buildPlaylistItem();
    }
  }

  @ReactProp(name = "title")
  public void setTitle(View view, String prop) {
    if(title!=prop) {
      title = prop;

//      buildPlaylistItem();
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(View view, String prop) {
    if(desc!=prop) {
      desc = prop;

//      buildPlaylistItem();
    }
  }

  @ReactProp(name = "displayTitle")
  public void setDisplayTitle(View view, Boolean prop) {
    if(displayTitle!=prop) {
      displayTitle = prop;

      mPlayerView.getConfig().setDisplayTitle(displayTitle);
      //buildPlaylistItem();
    }
  }

  @ReactProp(name = "displayDesc")
  public void setDisplayDescription(View view, Boolean prop) {
    if(displayDesc!=prop) {
      displayDesc = prop;

      mPlayerView.getConfig().setDisplayDescription(displayDesc);
      //buildPlaylistItem();
    }
  }

  @ReactProp(name = "autostart")
  public void setAutostart(View view, Boolean prop) {
    if(autostart!=prop) {
      autostart = prop;

      mPlayerView.getConfig().setAutostart(autostart);
      //buildPlaylistItem();
    }
  }

  @ReactProp(name = "controls")
  public void setControls(View view, Boolean prop) {
    if(controls!=prop) {
      controls = prop;

      mPlayerView.getConfig().setControls(controls);
      mPlayerView.setControls(controls);
    }
  }

  @ReactProp(name = "repeat")
  public void setRepeat(View view, Boolean prop) {
    if(repeat!=prop) {
      repeat = prop;

      mPlayerView.getConfig().setRepeat(repeat);
      //buildPlaylistItem();
    }
  }

//  @ReactProp(name = "time")
//  public void setTime(View view, String prop) {
//    if(time!=prop) {
//      time = prop;
//
//      if (time != null) {
//        int seekTime = Integer.valueOf(time);
//        if (seekTime > 0) {
//          mPlayerView.seek(seekTime);
//        }
//      }
//    }
//  }

  @ReactProp(name = "nextUpDisplay")
  public void setnextUpDisplay(View view, Boolean prop) {
    if(nextUpDisplay!=prop) {
      nextUpDisplay = prop;

      mPlayerView.getConfig().setNextUpDisplay(nextUpDisplay);
      //buildPlaylistItem();
    }
  }

  @ReactProp(name = "playlistId")
  public void setplaylistId(View view, String prop) {
    if (playlistId!=prop) {
      playlistId = prop;
    }
  }

  @ReactProp(name = "playlistItem")
  public void setPlaylistItem(View view, ReadableMap prop) {
    if(playlistItem != prop) {
      playlistItem = prop;

      if (playlistItem != null) {
        if (playlistItem.hasKey("file")) {
          String newFile = playlistItem.getString("file");

          if (mPlayerView.getPlaylistItem() == null) {
//            mPlayerView.stop();

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

            if (playlistItem.hasKey("autostart")) {
              mPlayerView.getConfig().setAutostart(playlistItem.getBoolean("autostart"));
            }

            if (playlistItem.hasKey("playerStyle")) {
              setCustomStyle(playlistItem.getString("playerStyle"));
            }

            mPlayerView.load(newPlayListItem);
          } else {
            mPlayerView.play();
          }
        }
      }
    }
  }

  public void reset()
  {
    mPlayerView = null;
    mPlayerConfig = null;
  }

  public void resetPlaylistItem()
  {
    playlistItem = null;
  }

  public void resetPlaylist()
  {
    playlist = null;
    playlistId = null;
    comparePlaylistId = null;
  }

  @ReactProp(name = "playlist")
  public void setPlayList(View view, ReadableArray prop) {
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

            if (playlistItem.hasKey("autostart")) {
              mPlayerView.getConfig().setAutostart(playlistItem.getBoolean("autostart"));
            }

            PlaylistItem newPlayListItem = new PlaylistItem.Builder()
                    .file(file)
                    .title(title)
                    .description(desc)
                    .image(image)
                    .mediaId(mediaId)
                    .build();

            mPlayList.add(newPlayListItem);
//            buildPlaylistItem();
//            mPlayerView.play();
          }

          j++;
        }

        if (playlist.getMap(0).hasKey("playerStyle")) {
          setCustomStyle(playlist.getMap(0).getString("playerStyle"));
        }

        mPlayerView.load(mPlayList);
        //buildPlaylistItem();
//        mPlayerView.playlistItem(0);
        mPlayerView.play();
      }
    }
  }

  private Runnable mDelayedStopRunnable = new Runnable() {
    @Override
    public void run() {
      mPlayerView.stop();
    }
  };

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
//    WritableMap event = Arguments.createMap();
//    event.putString("message", "onPlaylistItem");
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

//    if (comparePlaylistId != null && playlist != null && playlist.size() > currentPlayingIndex.intValue()) {
//      ReadableMap item = playlist.getMap(currentPlayingIndex.intValue());
//
//      if (item.hasKey("time") && !item.isNull("time") && item.getInt("time") > 0) {
//        int seekTime = item.getInt("time");
//        Log.e(TAG, "setPlayListItem: Value of timer is not null");
//        mPlayerView.seek(seekTime);
//      }
//    }

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

    updateWakeLock(true);
  }

  @Override
  public void onPlay(PlayEvent playEvent) {
    int result = 0;
    if (audioManager != null) {
      result = audioManager.requestAudioFocus(this,
              // Use the music stream.
              AudioManager.STREAM_MUSIC,
              // Request permanent focus.
              AudioManager.AUDIOFOCUS_GAIN);
    }
    if (result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED) {
      Log.e(TAG, "onBeforePlay: " + result);
    }


    WritableMap event = Arguments.createMap();
    event.putString("message", "onPlay");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topPlay",
            event);

    updateWakeLock(true);
  }

  @Override
  public void onReady(ReadyEvent readyEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onPlayerReady");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topOnPlayerReady",
            event);

    updateWakeLock(true);
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

    updateWakeLock(false);
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

    updateWakeLock(false);
  }

  @Override
  public void onFullscreen(FullscreenEvent fullscreenEvent) {
//        WritableMap eventEnterFullscreen = Arguments.createMap();
//        eventEnterFullscreen.putString("message", "onFullscreen");
//        WritableMap eventExitFullscreen = Arguments.createMap();
//        eventExitFullscreen.putString("message", "onFullscreenExit");
//        ReactContext reactContext = (ReactContext) mContext;
//        Log.e(RNJWPlayerViewManager.class.getSimpleName(), "onFullscreen: ORIENTATION : " + mActivity.getResources().getConfiguration().orientation);
//        if (mActivity.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE) {
//            //mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
//            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
//                    mPlayerView.getId(),
//                    "topFullScreenExit",
//                    eventExitFullscreen);
//        } else {
//            //mActivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
//            reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
//                    mPlayerView.getId(),
//                    "topFullScreen",
//                    eventEnterFullscreen);
//        }
//
//        updateWakeLock(false);
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

    updateWakeLock(false);
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

    updateWakeLock(false);
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

    updateWakeLock(true);
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
    root.play();
  }

  public void pause(RNJWPlayerView root) {
    root.pause();
  }

  public void stop(RNJWPlayerView root) {
    root.stop();
  }

  public void toggleSpeed(RNJWPlayerView root) {
    float rate = root.getPlaybackRate();
    if (rate < 2) {
      root.setPlaybackRate(rate += 0.5);
    } else {
      root.setPlaybackRate((float) 0.5);
    }
  }

  @Override
  public void onAudioFocusChange(int i) {
    mHandler = new Handler();
    if (i == AudioManager.AUDIOFOCUS_LOSS) {
      mPlayerView.pause();
      mHandler.postDelayed(mDelayedStopRunnable,
              TimeUnit.SECONDS.toMillis(30));
    } else if (i == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT) {
      mPlayerView.pause();
    } else if (i == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK) {
// Lower the volume, keep playing

    } else if (i == AudioManager.AUDIOFOCUS_GAIN) {
      mPlayerView.play();
    }
  }
}
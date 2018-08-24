
package net.gamesofton.rnjwplayer;

import android.app.Activity;
import android.support.annotation.Nullable;
import android.view.View;
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
import com.longtailvideo.jwplayer.events.AudioTrackChangedEvent;
import com.longtailvideo.jwplayer.events.AudioTracksEvent;
import com.longtailvideo.jwplayer.events.BeforeCompleteEvent;
import com.longtailvideo.jwplayer.events.BeforePlayEvent;
import com.longtailvideo.jwplayer.events.BufferEvent;
import com.longtailvideo.jwplayer.events.CompleteEvent;
import com.longtailvideo.jwplayer.events.ControlsEvent;
import com.longtailvideo.jwplayer.events.ErrorEvent;
import com.longtailvideo.jwplayer.events.FullscreenEvent;
import com.longtailvideo.jwplayer.events.IdleEvent;
import com.longtailvideo.jwplayer.events.PauseEvent;
import com.longtailvideo.jwplayer.events.PlayEvent;
import com.longtailvideo.jwplayer.events.PlaylistCompleteEvent;
import com.longtailvideo.jwplayer.events.PlaylistEvent;
import com.longtailvideo.jwplayer.events.PlaylistItemEvent;
import com.longtailvideo.jwplayer.events.SetupErrorEvent;
import com.longtailvideo.jwplayer.events.TimeEvent;
import com.longtailvideo.jwplayer.events.listeners.AdvertisingEvents;
import com.longtailvideo.jwplayer.events.listeners.VideoPlayerEvents;
import com.longtailvideo.jwplayer.media.playlists.PlaylistItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.longtailvideo.jwplayer.configuration.PlayerConfig.STRETCHING_UNIFORM;

public class RNJWPlayerViewManager extends SimpleViewManager<RNJWPlayerView> implements VideoPlayerEvents.OnFullscreenListener,
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
        AdvertisingEvents.OnBeforePlayListener,
        AdvertisingEvents.OnBeforeCompleteListener {

  public static final String REACT_CLASS = "RNJWPlayer";

  public static final int COMMAND_PLAY = 101;
  public static final int COMMAND_PAUSE = 102;

  /**
  * The application window
  */
  Window mWindow;

  Activity mActivity;

  private PlayerConfig mPlayerConfig;
  private ThemedReactContext mContext;
  RNJWPlayerView mPlayerView = null;
  PlaylistItem mPlayListItem = null;
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

  ReadableMap playListItem; // PlaylistItem
  ReadableArray playList; // List <PlaylistItem>

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

//    SkinConfig skinConfig = new SkinConfig.Builder()
//            .name("ethan")
//            .url("https://ssl.p.jwpcdn.com/iOS/Skins/ethan.css")
//            .build();

    mPlayerConfig = new PlayerConfig.Builder()
            .autostart(true)
            //.skinConfig(skinConfig)
            .stretching(STRETCHING_UNIFORM)
            .build();

    mPlayerView = new RNJWPlayerView(mContext.getBaseContext(), mPlayerConfig);
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
    mPlayerView.addOnBeforePlayListener(this);
    mPlayerView.addOnBeforeCompleteListener(this);
    mPlayerView.addOnControlsListener(this);

    return mPlayerView;
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

    mPlayListItem = new PlaylistItem();

    if (file != null && !file.isEmpty()) {
      mPlayListItem.setFile(file);
    }

    if (title != null && !title.isEmpty()) {
      mPlayListItem.setTitle(title);
    }

    if (desc != null && !desc.isEmpty()) {
      mPlayListItem.setDescription(desc);
    }

    if (image != null && !image.isEmpty()) {
      mPlayListItem.setImage(image);
    }

    if (mediaId != null && !mediaId.isEmpty()) {
      mPlayListItem.setMediaId(mediaId);
    }

    mPlayerView.load(mPlayListItem);

//    mPlayerView.getConfig().setFile(file);
//    mPlayerView.getConfig().setImage(image);
//    mPlayerView.getConfig().setSkinConfig();

//    mPlayerView.getConfig().setAutostart(autostart);
//    mPlayerView.getConfig().setRepeat(repeat);
//    mPlayerView.getConfig().setControls(controls);
//    mPlayerView.getConfig().setDisplayTitle(displayTitle);
//    mPlayerView.getConfig().setDisplayDescription(displayDesc);
  }

  @ReactProp(name = "file")
  public void setFile(View view, String prop) {
    if (file!=prop) {
      file = prop;

      buildPlaylistItem();

      mPlayerView.play();
    }
  }

  @ReactProp(name = "mediaId")
  public void setMediaId(View view, String prop) {
    if (mediaId!=prop) {
      mediaId = prop;

      buildPlaylistItem();
    }
  }

  @ReactProp(name = "image")
  public void setImage(View view, String prop) {
    if(image!=prop) {
      image = prop;

      buildPlaylistItem();
    }
  }

  @ReactProp(name = "title")
  public void setTitle(View view, String prop) {
    if(title!=prop) {
      title = prop;

      buildPlaylistItem();
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(View view, String prop) {
    if(desc!=prop) {
      desc = prop;

      buildPlaylistItem();
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
      //buildPlaylistItem();
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

  @ReactProp(name = "playListItem")
  public void setPlayListItem(View view, ReadableMap prop) {
    if(playListItem!=prop) {
      playListItem = prop;

      if (playListItem != null) {

        if (playListItem.hasKey("file")) {
          file = playListItem.getString("file");
        }

        if (playListItem.hasKey("title")) {
          title = playListItem.getString("title");
        }

        if (playListItem.hasKey("desc")) {
          desc = playListItem.getString("desc");
        }

        if (playListItem.hasKey("image")) {
          image = playListItem.getString("image");
        }

        if (playListItem.hasKey("mediaId")) {
          mediaId = playListItem.getString("mediaId");
        }

        buildPlaylistItem();

        mPlayerView.play();
      }
    }
  }

  @ReactProp(name = "playList")
  public void setPlayList(View view, ReadableArray prop) {
    if(playList!=prop) {
      playList = prop;

      if (playList != null) {
        mPlayerView.stop();

        mPlayList = new ArrayList<>();

        int j = 0;
        while (playList.size() > j) {
          playListItem = playList.getMap(j);

          if (playListItem != null) {

            if (playListItem.hasKey("file")) {
              file = playListItem.getString("file");
            }

            if (playListItem.hasKey("title")) {
              title = playListItem.getString("title");
            }

            if (playListItem.hasKey("desc")) {
              desc = playListItem.getString("desc");
            }

            if (playListItem.hasKey("image")) {
              image = playListItem.getString("image");
            }

            if (playListItem.hasKey("mediaId")) {
              mediaId = playListItem.getString("mediaId");
            }

            mPlayListItem = new PlaylistItem.Builder()
                    .file(file)
                    .title(title)
                    .description(desc)
                    .image(image)
                    .mediaId(mediaId)
                    .build();

            mPlayList.add(mPlayListItem);
          }

          j++;
        }

        mPlayerView.getConfig().setAutostart(autostart);
        mPlayerView.getConfig().setRepeat(repeat);
        mPlayerView.getConfig().setControls(controls);
        mPlayerView.getConfig().setDisplayTitle(displayTitle);
        mPlayerView.getConfig().setDisplayDescription(displayDesc);

        mPlayerView.load(mPlayList);
        mPlayerView.play();
      }
    }
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
    WritableMap event = Arguments.createMap();
    event.putString("message", "onFullscreen");
    ReactContext reactContext = (ReactContext) mContext;
    reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
            mPlayerView.getId(),
            "topFullscreen",
            event);
  }

  @Override
  public void onError(ErrorEvent errorEvent) {
    WritableMap event = Arguments.createMap();
    event.putString("message", "onError");
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
            .build();
  }

  public static <K, V> Map<K, V> CreateMap(
          K k1, V v1, K k2, V v2) {
    Map map = new HashMap<K, V>();
    map.put(k1, v1);
    map.put(k2, v2);
    return map;
  }

  @Nullable
  @Override
  public Map<String, Integer> getCommandsMap() {
    return MapBuilder.of(
            "play", COMMAND_PLAY,
            "pause", COMMAND_PAUSE
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
}
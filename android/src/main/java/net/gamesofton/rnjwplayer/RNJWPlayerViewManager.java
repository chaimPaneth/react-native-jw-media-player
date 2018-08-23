
package net.gamesofton.rnjwplayer;

import android.view.View;

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
import com.longtailvideo.jwplayer.events.BufferEvent;
import com.longtailvideo.jwplayer.events.CompleteEvent;
import com.longtailvideo.jwplayer.events.ErrorEvent;
import com.longtailvideo.jwplayer.events.FullscreenEvent;
import com.longtailvideo.jwplayer.events.PauseEvent;
import com.longtailvideo.jwplayer.events.PlayEvent;
import com.longtailvideo.jwplayer.events.SetupErrorEvent;
import com.longtailvideo.jwplayer.events.TimeEvent;
import com.longtailvideo.jwplayer.events.listeners.VideoPlayerEvents;
import com.longtailvideo.jwplayer.media.playlists.PlaylistItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

import static com.longtailvideo.jwplayer.configuration.PlayerConfig.STRETCHING_UNIFORM;

public class RNJWPlayerViewManager extends SimpleViewManager<RNJWPlayerView> implements VideoPlayerEvents.OnFullscreenListener,
        VideoPlayerEvents.OnPlayListener,
        VideoPlayerEvents.OnPauseListener,
        VideoPlayerEvents.OnCompleteListener,
        VideoPlayerEvents.OnErrorListener,
        VideoPlayerEvents.OnSetupErrorListener,
        VideoPlayerEvents.OnBufferListener,
        VideoPlayerEvents.OnTimeListener {

  public static final String REACT_CLASS = "RNJWPlayer";

  public static final int COMMAND_PLAY = 101;
  public static final int COMMAND_PAUSE = 102;

  private PlayerConfig mPlayerConfig;
  private ThemedReactContext mContext;
  RNJWPlayerView mPlayerView = null;
  PlaylistItem mPlayListItem = null;
  ArrayList<PlaylistItem> mPlayList = null;

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
    mPlayerConfig = new PlayerConfig.Builder()
            .autostart(true)
            .stretching(STRETCHING_UNIFORM)
            .build();

    mPlayerView = new RNJWPlayerView(mContext.getBaseContext(), mPlayerConfig);
    mPlayerView.addOnPlayListener(this);
    mPlayerView.addOnPauseListener(this);
    mPlayerView.addOnCompleteListener(this);
    mPlayerView.addOnErrorListener(this);
    mPlayerView.addOnSetupErrorListener(this);
    mPlayerView.addOnBufferListener(this);
    mPlayerView.addOnTimeListener(this);

    return mPlayerView;
  }

  @ReactProp(name = "file")
  public void setFile(View view, String prop) {
    if (file!=prop) {
      file = prop;

      mPlayerView.getConfig().setFile(file);
      mPlayerView.play();

//      mPlayerView.stop();
//      mPlayListItem = new PlaylistItem.Builder()
//              .file(file)
//              .title(title)
//              .description(desc)
//              .image(image)
//              .build();
//
//      mPlayerView.load(mPlayListItem);
//
//      mPlayerView.play();
    }
  }

  @ReactProp(name = "image")
  public void setImage(View view, String prop) {
    if(image!=prop) {
      image = prop;

      mPlayerView.getConfig().setImage(image);
    }
  }

  @ReactProp(name = "title")
  public void setTitle(View view, String prop) {
    if(title!=prop) {
      title = prop;

      //TODO: - SET TITLE
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(View view, String prop) {
    if(desc!=prop) {
      desc = prop;

      //TODO: - SET DESC
    }
  }

  @ReactProp(name = "displayTitle")
  public void setDisplayTitle(View view, Boolean prop) {
    if(displayTitle!=prop) {
      displayTitle = prop;

      mPlayerView.getConfig().setDisplayTitle(displayTitle);
    }
  }

  @ReactProp(name = "displayDesc")
  public void setDisplayDescription(View view, Boolean prop) {
    if(displayDesc!=prop) {
      displayDesc = prop;

      mPlayerView.getConfig().setDisplayDescription(displayDesc);
    }
  }

  @ReactProp(name = "autostart")
  public void setAutostart(View view, Boolean prop) {
    if(autostart!=prop) {
      autostart = prop;

      mPlayerView.getConfig().setAutostart(autostart);
    }
  }

  @ReactProp(name = "controls")
  public void setControls(View view, Boolean prop) {
    if(controls!=prop) {
      controls = prop;

      mPlayerView.getConfig().setControls(controls);
    }
  }

  @ReactProp(name = "repeat")
  public void setRepeat(View view, Boolean prop) {
    if(repeat!=prop) {
      repeat = prop;

      mPlayerView.getConfig().setRepeat(repeat);
    }
  }

  @ReactProp(name = "playListItem")
  public void setPlayListItem(View view, ReadableMap prop) {
    if(playListItem!=prop) {
      playListItem = prop;

      if (playListItem != null) {
        mPlayerView.stop();

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

        mPlayerView.load(mPlayListItem);
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

        mPlayList = new ArrayList<PlaylistItem>();

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

        mPlayerView.load(mPlayList);
        mPlayerView.play();
      }
    }
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
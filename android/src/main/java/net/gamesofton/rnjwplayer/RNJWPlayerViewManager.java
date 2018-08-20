
package net.gamesofton.rnjwplayer;

import android.view.View;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;
import com.longtailvideo.jwplayer.core.PlayerState;
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
  PlaylistItem pi = null;

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

  @Override
  public String getName() {
    // Tell React the name of the module
    // https://facebook.github.io/react-native/docs/native-components-android.html#1-create-the-viewmanager-subclass
    return REACT_CLASS;
  }

  @Override
  public RNJWPlayerView createViewInstance(ThemedReactContext context) {

    if (mPlayerView == null) {
      mContext = context;
      mPlayerConfig = new PlayerConfig.Builder()
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
    }

    return mPlayerView;
  }

  @ReactProp(name = "file")
  public void setFile(View view, String prop) {
    if (file!=prop) {
      file = prop;

      mPlayerView.getConfig().setFile(file);

      mPlayerView.play();

//      mPlayerView.stop();
//      pi = new PlaylistItem.Builder()
//              .file(file)
//              .title(title)
//              .description(desc)
//              .image(image)
//              .build();
//      mPlayerView.load(pi);

    }
  }

  @ReactProp(name = "image")
  public void setImage(View view, String prop) {
    if(image!=prop) {
      image = prop;

      mPlayerView.getConfig().setImage(image);

//      mPlayerView.stop();
//      pi = new PlaylistItem.Builder()
//              .file(file)
//              .title(title)
//              .description(desc)
//              .image(image)
//              .build();
//
//      mPlayerView.load(pi);
    }
  }

  @ReactProp(name = "title")
  public void setTitle(View view, String prop) {
    if(title!=prop) {
      title = prop;

//      mPlayerView.stop();
//      pi = new PlaylistItem.Builder()
//              .file(file)
//              .title(title)
//              .description(desc)
//              .image(image)
//              .build();
//
//      mPlayerView.load(pi);
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(View view, String prop) {
    if(desc!=prop) {
      desc = prop;

//      mPlayerView.stop();
//      pi = new PlaylistItem.Builder()
//              .file(file)
//              .title(title)
//              .description(desc)
//              .image(image)
//              .build();
//
//      mPlayerView.load(pi);
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

  }

  @Override
  public void onPause(PauseEvent pauseEvent) {

  }

  @Override
  public void onComplete(CompleteEvent completeEvent) {

  }

  @Override
  public void onFullscreen(FullscreenEvent fullscreenEvent) {

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
            .build();
  }

  @Nullable
  @Override
  public Map<String, Integer> getCommandsMap() {
    Map<String, Integer> commandsMap = super.getCommandsMap();

    commandsMap.put("play", COMMAND_PLAY);
    commandsMap.put("pause", COMMAND_PAUSE);

    return commandsMap;
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

  @ReactMethod
  public void state(final int viewId, final Promise promise) {
    if (mPlayerView != null) {
      mContext.runOnUiQueueThread(new Runnable() {
        @Override
        public void run() {
          PlayerState playerState = mPlayerView.getState();
          if (playerState != null) {
            promise.resolve(playerState);
          } else {
            Exception ex = new Exception();
            promise.reject("RNJW Error", "Failed to get state", ex);
          }
        }
      });
    } else {
      Exception ex = new Exception();
      promise.reject("RNJW Error", "Failed to get player", ex);
    }
  }
}
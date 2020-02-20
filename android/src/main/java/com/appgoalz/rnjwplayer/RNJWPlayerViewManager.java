
package com.appgoalz.rnjwplayer;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.common.MapBuilder;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nonnull;

public class RNJWPlayerViewManager extends SimpleViewManager<RNJWPlayerView> {

  public static final String REACT_CLASS = "RNJWPlayer";

  public static final int COMMAND_PLAY = 101;
  public static final int COMMAND_PAUSE = 102;
  public static final int COMMAND_STOP = 103;
  public static final int COMMAND_TOGGLE_SPEED = 104;

  private final ReactApplicationContext mAppContext;

  private static final String TAG = "RNJWPlayerViewManager";

  @Override
  public String getName() {
    return REACT_CLASS;
  }

  public RNJWPlayerViewManager(ReactApplicationContext context) {
    mAppContext = context;
  }

  @Override
  public RNJWPlayerView createViewInstance(ThemedReactContext context) {
    return new RNJWPlayerView(context, mAppContext);
  }

  @ReactProp(name = "file")
  public void setFile(RNJWPlayerView view, String prop) {
    if (view.file!=prop) {
      view.file = prop;
    }
  }

  @ReactProp(name = "mediaId")
  public void setMediaId(RNJWPlayerView view, String prop) {
    if (view.mediaId!=prop) {
      view.mediaId = prop;
    }
  }

  @ReactProp(name = "image")
  public void setImage(RNJWPlayerView view, String prop) {
    if(view.image!=prop) {
      view.image = prop;
    }
  }

  @ReactProp(name = "title")
  public void setTitle(RNJWPlayerView view, String prop) {
    if(view.title!=prop) {
      view.title = prop;
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(RNJWPlayerView view, String prop) {
    if(view.desc!=prop) {
      view.desc = prop;
    }
  }

  @ReactProp(name = "displayTitle")
  public void setDisplayTitle(RNJWPlayerView view, Boolean prop) {
    if(view.displayTitle!=prop) {
      view.displayTitle = prop;

      if (view.mPlayer != null) {
        view.mPlayer.getConfig().setDisplayTitle(view.displayTitle);
      }
    }
  }

  @ReactProp(name = "displayDesc")
  public void setDisplayDescription(RNJWPlayerView view, Boolean prop) {
    if(view.displayDesc!=prop) {
      view.displayDesc = prop;

      if (view.mPlayer != null) {
        view.mPlayer.getConfig().setDisplayDescription(view.displayDesc);
      }
    }
  }

  @ReactProp(name = "autostart")
  public void setAutostart(RNJWPlayerView view, Boolean prop) {
    if(view.autostart!=prop) {
      view.autostart = prop;

      if (view.mPlayer != null) {
        view.mPlayer.getConfig().setAutostart(view.autostart);
      }
    }
  }

  @ReactProp(name = "controls")
  public void setControls(RNJWPlayerView view, Boolean prop) {
    if(view.controls!=prop) {
      view.controls = prop;

      if (view.mPlayer != null) {
        view.mPlayer.getConfig().setControls(view.controls);
        view.mPlayer.setControls(view.controls);
      }
    }
  }

  @ReactProp(name = "repeat")
  public void setRepeat(RNJWPlayerView view, Boolean prop) {
    if(view.repeat!=prop) {
      view.repeat = prop;

      if (view.mPlayer != null) {
        view.mPlayer.getConfig().setRepeat(view.repeat);
      }
    }
  }

  @ReactProp(name = "colors")
  public void setColors(RNJWPlayerView view, ReadableMap prop) {
    if (prop != null) {
      if (prop.hasKey("icons")) {
        view.mPlayer.getConfig().getSkinConfig().setControlBarIcons("#" + prop.getString("icons"));
      }

      if (prop.hasKey("timeslider")) {
        ReadableMap timeslider = prop.getMap("timeslider");

        if (timeslider.hasKey("progress")) {
          view.mPlayer.getConfig().getSkinConfig().setTimeSliderProgress("#" + timeslider.getString("progress"));
        }

        if (timeslider.hasKey("rail")) {
          view.mPlayer.getConfig().getSkinConfig().setTimeSliderRail("#" + timeslider.getString("rail"));
        }
      }

      if (view.mPlayer != null) {
        view.mPlayer.setup(view.mPlayer.getConfig());
      }
    }
  }

  @ReactProp(name = "playerStyle")
  public void setPlayerStyle(RNJWPlayerView view, String prop) {
    if (prop != null) {
      view.customStyle = prop;
    }
  }

  @ReactProp(name = "nextUpDisplay")
  public void setNextUpDisplay(RNJWPlayerView view, Boolean prop) {
    if(view.nextUpDisplay!=prop) {
      view.nextUpDisplay = prop;

      if (view.mPlayer != null) {
        view.mPlayer.getConfig().setNextUpDisplay(view.nextUpDisplay);
      }
    }
  }

  @ReactProp(name = "playlistItem")
  public void setPlaylistItem(RNJWPlayerView view, ReadableMap prop) {
    view.setPlaylistItem(prop);
  }

  @ReactProp(name = "playlist")
  public void setPlaylist(RNJWPlayerView view, ReadableArray prop) {
    view.setPlaylist(prop);
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
            .put("topBeforeComplete",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onBeforeComplete")))
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
            .put("topAdStarted",
                    MapBuilder.of(
                            "phasedRegistrationNames",
                            MapBuilder.of("bubbled", "onAdPlay")))
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
    root.resumeOnFocusGain = false; // Stops the player from refocusing audio after manually pausing
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
    view.destroyPlayer();
    view = null;

    super.onDropViewInstance(view);
  }
}
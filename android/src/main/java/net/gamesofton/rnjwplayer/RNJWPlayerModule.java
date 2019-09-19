
package net.gamesofton.rnjwplayer;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;
import com.longtailvideo.jwplayer.configuration.SkinConfig;
import com.longtailvideo.jwplayer.core.PlayerState;
import com.longtailvideo.jwplayer.media.playlists.PlaylistItem;

import java.util.ArrayList;
import java.util.List;

public class RNJWPlayerModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext mReactContext;

  private static final String TAG = "RNJWPlayerModule";

  public RNJWPlayerModule(ReactApplicationContext reactContext) {
    super(reactContext);

    mReactContext = reactContext;
  }

  private void setCustomStyle(String name) {
    SkinConfig skinConfig = new SkinConfig.Builder()
              .name(name)
              .url(String.format("file:///android_asset/%s.css", name))
              .build();

    PlayerConfig config = RNJWPlayerViewManager.mPlayerView.getConfig();
    config.setSkinConfig(skinConfig);

    RNJWPlayerViewManager.mPlayerView.setup(config);
  }

  @Override
  public String getName() {
    return "RNJWPlayerModule";
  }

  @ReactMethod
  public void play() {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.play();
    }
  }

  @ReactMethod
  public void toggleSpeed() {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      float rate = RNJWPlayerViewManager.mPlayerView.getPlaybackRate();
      if (rate < 2) {
        RNJWPlayerViewManager.mPlayerView.setPlaybackRate(rate += 0.5);
      } else {
        RNJWPlayerViewManager.mPlayerView.setPlaybackRate((float) 0.5);
      }
    }
  }

  @ReactMethod
  public void setSpeed(float speed) {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.setPlaybackRate(speed);
    }
  }

  @ReactMethod
  public void pause() {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.pause();
    }
  }

  @ReactMethod
  public void stop() {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.stop();
    }
  }

  @ReactMethod
  public void loadPlaylistItem(ReadableMap playlistItem) {
    if (playlistItem != null && RNJWPlayerViewManager.mPlayerView != null) {
      if (playlistItem.hasKey("file")) {
        String newFile = playlistItem.getString("file");

        PlaylistItem newPlayListItem = new PlaylistItem();

        newPlayListItem.setFile(newFile);

        if (playlistItem.hasKey("playerStyle")) {
          setCustomStyle(playlistItem.getString("playerStyle"));
        }

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

        Boolean autostart = true;
        Boolean controls = true;

        if (playlistItem.hasKey("autostart")) {
          autostart = playlistItem.getBoolean("autostart");
        }

        if (playlistItem.hasKey("controls")) {
          controls = playlistItem.getBoolean("controls");
        }

        RNJWPlayerViewManager.mPlayerView.getConfig().setAutostart(autostart);
        RNJWPlayerViewManager.mPlayerView.getConfig().setControls(controls);
        RNJWPlayerViewManager.mPlayerView.setControls(controls);

        RNJWPlayerViewManager.mPlayerView.load(newPlayListItem);
      }
    }
  }

  @ReactMethod
  public void seekTo(double time) {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.seek(time);
    }
  }

  @ReactMethod
  public void setPlaylistIndex(int index) {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.setCurrentAudioTrack(index);
    }
  }

  @ReactMethod
  public void setControls(boolean show) {
    if (RNJWPlayerViewManager.mPlayerView != null) {
      RNJWPlayerViewManager.mPlayerView.setControls(show);
      RNJWPlayerViewManager.mPlayerView.getConfig().setControls(show);
    }
  }

  @ReactMethod
  public void loadPlaylist(ReadableArray playlist) {
    if (playlist != null && playlist.size() > 0 && RNJWPlayerViewManager.mPlayerView != null) {

      List<PlaylistItem> mPlayList = new ArrayList<>();
      ReadableMap playlistItem;
      String file = "";
      String image = "";
      String title = "";
      String desc = "";
      String mediaId = "";
      Boolean autostart = true;
      Boolean controls = true;

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
            autostart = playlistItem.getBoolean("autostart");
          }

          if (playlistItem.hasKey("controls")) {
            controls = playlistItem.getBoolean("controls");
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

      if (playlist.getMap(0).hasKey("playerStyle")) {
        setCustomStyle(playlist.getMap(0).getString("playerStyle"));
      }

      RNJWPlayerViewManager.mPlayerView.getConfig().setAutostart(autostart);
      RNJWPlayerViewManager.mPlayerView.getConfig().setControls(controls);
      RNJWPlayerViewManager.mPlayerView.setControls(controls);

      RNJWPlayerViewManager.mPlayerView.load(mPlayList);

      RNJWPlayerViewManager.mPlayerView.play();
    }
  }

  @ReactMethod
  public void position(/*final int reactTag, */final Promise promise) {
    try {
//      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
//      uiManager.addUIBlock(new UIBlock() {
//        public void execute (NativeViewHierarchyManager nvhm) {
//          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);
//          //RNJWPlayerViewManager playerViewManager = (RNJWPlayerViewManager) nvhm.resolveViewManager(reactTag);
//          promise.resolve((Double.valueOf(playerView.getPosition()).intValue()));
//        }
//      });
      promise.resolve((Double.valueOf(RNJWPlayerViewManager.mPlayerView.getPosition()).intValue()));
    } catch (IllegalViewOperationException e) {
      promise.reject("RNJW Error", e);
    }
  }

  @ReactMethod
  public void state(/*final int reactTag, */final Promise promise) {
    try {
//      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
//      uiManager.addUIBlock(new UIBlock() {
//        public void execute (NativeViewHierarchyManager nvhm) {
//          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);
//          //RNJWPlayerViewManager playerViewManager = (RNJWPlayerViewManager) nvhm.resolveViewManager(reactTag);
//
//          PlayerState playerState = playerView.getState();
//          promise.resolve(stateToInt(playerState));
//        }
//      });
      PlayerState playerState = RNJWPlayerViewManager.mPlayerView.getState();
      promise.resolve(stateToInt(playerState));
    } catch (IllegalViewOperationException e) {
      promise.reject("RNJW Error", e);
    }
  }

  private int stateToInt(PlayerState playerState) {
    switch (playerState) {
      case IDLE:
        return 0;
      case BUFFERING:
        return 1;
      case PLAYING:
        return 2;
      case PAUSED:
        return 3;
      case COMPLETE:
        return 4;
      default:
        return 0;
    }
  }
}
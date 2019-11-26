
package com.appgoalz.rnjwplayer;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;
import com.longtailvideo.jwplayer.configuration.SkinConfig;
import com.longtailvideo.jwplayer.core.PlayerState;

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

    PlayerConfig config = RNJWPlayerView.mPlayer.getConfig();
    config.setSkinConfig(skinConfig);

    RNJWPlayerView.mPlayer.setup(config);
  }

  public SkinConfig getCustomSkinConfig(String name) {
    return new SkinConfig.Builder()
            .name(name)
            .url(String.format("file:///android_asset/%s.css", name))
            .build();
  }

  @Override
  public String getName() {
    return "RNJWPlayerModule";
  }

  @ReactMethod
  public void play() {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.play();
    }
  }

  @ReactMethod
  public void toggleSpeed() {
    if (RNJWPlayerView.mPlayer != null) {
      float rate = RNJWPlayerView.mPlayer.getPlaybackRate();
      if (rate < 2) {
        RNJWPlayerView.mPlayer.setPlaybackRate(rate += 0.5);
      } else {
        RNJWPlayerView.mPlayer.setPlaybackRate((float) 0.5);
      }
    }
  }

  @ReactMethod
  public void setSpeed(float speed) {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.setPlaybackRate(speed);
    }
  }

  @ReactMethod
  public void pause() {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.pause();
    }
  }

  @ReactMethod
  public void stop() {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.stop();
    }
  }

  @ReactMethod
  public void seekTo(double time) {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.seek(time);
    }
  }

  @ReactMethod
  public void setPlaylistIndex(int index) {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.setCurrentAudioTrack(index);
    }
  }

  @ReactMethod
  public void setControls(boolean show) {
    if (RNJWPlayerView.mPlayer != null) {
      RNJWPlayerView.mPlayer.setControls(show);
      RNJWPlayerView.mPlayer.getConfig().setControls(show);
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
      promise.resolve((Double.valueOf(RNJWPlayerView.mPlayer.getPosition()).intValue()));
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
      PlayerState playerState = RNJWPlayerView.mPlayer.getState();
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
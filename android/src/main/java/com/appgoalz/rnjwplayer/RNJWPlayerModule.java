
package com.appgoalz.rnjwplayer;

import android.media.AudioManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;
import com.google.android.gms.cast.CastDevice;
import com.jwplayer.pub.api.PlayerState;

public class RNJWPlayerModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext mReactContext;

  private static final String TAG = "RNJWPlayerModule";

  public RNJWPlayerModule(ReactApplicationContext reactContext) {
    super(reactContext);

    mReactContext = reactContext;
  }

  @Override
  public String getName() {
    return TAG;
  }

  @ReactMethod
  public void play(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().play();
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void toggleSpeed(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            double rate = playerView.mPlayerView.getPlayer().getPlaybackRate();
            if (rate < 2) {
              playerView.mPlayerView.getPlayer().setPlaybackRate(rate += 0.5);
            } else {
              playerView.mPlayerView.getPlayer().setPlaybackRate((float) 0.5);
            }
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void setSpeed(final int reactTag, final float speed) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().setPlaybackRate(speed);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void pause(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().pause();
            playerView.userPaused = true;
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void stop(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().stop();
            playerView.userPaused = true;
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void seekTo(final int reactTag, final double time) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().seek(time);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void setPlaylistIndex(final int reactTag, final int index) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().playlistItem(index);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void setControls(final int reactTag, final boolean show) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().setControls(show);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void position(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            promise.resolve((Double.valueOf(playerView.mPlayerView.getPlayer().getPosition()).intValue()));
          } else {
            promise.reject("RNJW Error", "Player is null");
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      promise.reject("RNJW Error", e);
    }
  }

  @ReactMethod
  public void state(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            PlayerState playerState = playerView.mPlayerView.getPlayer().getState();
            promise.resolve(stateToInt(playerState));
          } else {
            promise.reject("RNJW Error", "Player is null");
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      promise.reject("RNJW Error", e);
    }
  }

  @ReactMethod
  public void setFullscreen(final int reactTag, final boolean fullscreen) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.mPlayerView.getPlayer().setFullscreen(fullscreen, fullscreen);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void setVolume(final int reactTag, final int volume) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            int maxValue = playerView.audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
            if (volume <= maxValue) {
              playerView.audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, volume, 0);
            } else {
              playerView.audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxValue, 0);
            }
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void setUpCastController(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.setUpCastController();
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void presentCastDialog(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            playerView.presentCastDialog();
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void connectedDevice(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            if (playerView.connectedDevice() != null) {
              String name = playerView.connectedDevice().getFriendlyName();
              String id = playerView.connectedDevice().getDeviceId();

              WritableMap map = Arguments.createMap();
              map.putString("name", name);
              map.putString("identifier", id);
              promise.resolve(map);
            } else {
              promise.reject("RNJW Casting Error", "No connected device.");
            }
          } else {
            promise.reject("RNJW Error", "Player is null");
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void availableDevices(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            if (playerView.availableDevice() != null) {
              WritableArray deviceArray = Arguments.createArray();

              for (CastDevice device : playerView.availableDevice()) {
                String name = device.getFriendlyName();
                String id = device.getDeviceId();

                WritableMap map = Arguments.createMap();
                map.putString("name", name);
                map.putString("identifier", id);

                deviceArray.pushMap(map);
              }

              promise.resolve(deviceArray);
            } else {
              promise.reject("RNJW Casting Error", "No connected device.");
            }
          } else {
            promise.reject("RNJW Error", "Player is null");
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void castState(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            promise.resolve(playerView.castState());
          } else {
            promise.reject("RNJW Error", "Player is null");
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
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
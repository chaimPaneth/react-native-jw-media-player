
package com.appgoalz.rnjwplayer;

import android.media.AudioManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIBlock;
import com.facebook.react.uimanager.UIManagerModule;
import com.jwplayer.pub.api.JWPlayer;
import com.jwplayer.pub.api.PlayerState;
import com.jwplayer.pub.api.configuration.PlayerConfig;
import com.jwplayer.pub.api.media.audio.AudioTrack;
import com.jwplayer.pub.api.media.playlists.PlaylistItem;

import java.util.ArrayList;
import java.util.List;

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
  public void loadPlaylist(final int reactTag, final ReadableArray playlistItems) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            JWPlayer player = playerView.mPlayerView.getPlayer();

            PlayerConfig oldConfig = player.getConfig();
            PlayerConfig config = new PlayerConfig.Builder()
                    .autostart(oldConfig.getAutostart())
                    .nextUpOffset(oldConfig.getNextUpOffset())
                    .repeat(oldConfig.getRepeat())
                    .relatedConfig(oldConfig.getRelatedConfig())
                    .displayDescription(oldConfig.getDisplayDescription())
                    .displayTitle(oldConfig.getDisplayTitle())
                    .advertisingConfig(oldConfig.getAdvertisingConfig())
                    .stretching(oldConfig.getStretching())
                    .uiConfig(oldConfig.getUiConfig())
                    .playlist(Util.createPlaylist(playlistItems))
                    .allowCrossProtocolRedirects(oldConfig.getAllowCrossProtocolRedirects())
                    .preload(oldConfig.getPreload())
                    .useTextureView(oldConfig.useTextureView())
                    .thumbnailPreview(oldConfig.getThumbnailPreview())
                    .mute(oldConfig.getMute())
                    .build();

            player.setup(config);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
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
  public void togglePIP(final int reactTag) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayerView != null) {
            if (playerView.mPlayerView.getPlayer().isInPictureInPictureMode()) {
              playerView.mPlayerView.getPlayer().exitPictureInPictureMode();
            } else {
              playerView.mPlayerView.getPlayer().enterPictureInPictureMode();
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
  public void getAudioTracks(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayer != null) {
            List<AudioTrack> audioTrackList = playerView.mPlayer.getAudioTracks();
            WritableArray audioTracks = Arguments.createArray();
            for (int i = 0; i < audioTrackList.size(); i++) {
              WritableMap audioTrack = Arguments.createMap();
              AudioTrack track = audioTrackList.get(i);
              audioTrack.putString("name", track.getName());
              audioTrack.putString("language", track.getLanguage());
              audioTrack.putString("groupId", track.getGroupId());
              audioTrack.putBoolean("defaultTrack", track.isDefaultTrack());
              audioTrack.putBoolean("autoSelect", track.isAutoSelect());
              audioTracks.pushMap(audioTrack);
            }
            promise.resolve(audioTracks);
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
  public void getCurrentAudioTrack(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayer != null) {
            promise.resolve(playerView.mPlayer.getCurrentAudioTrack());
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
  public void setCurrentAudioTrack(final int reactTag, final int index) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayer != null) {
            playerView.mPlayer.setCurrentAudioTrack(index);
          }
        }
      });
    } catch (IllegalViewOperationException e) {
      throw e;
    }
  }

  @ReactMethod
  public void setCurrentCaptions(final int reactTag, final int index) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);

          if (playerView != null && playerView.mPlayer != null) {
            playerView.mPlayer.setCurrentCaptions(index);
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
      case ERROR:
        return 5;
      default:
        return -1;
    }
  }
}
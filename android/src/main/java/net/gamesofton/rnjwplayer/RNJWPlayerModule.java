
package net.gamesofton.rnjwplayer;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.uimanager.IllegalViewOperationException;
import com.facebook.react.uimanager.NativeViewHierarchyManager;
import com.facebook.react.uimanager.UIManagerModule;
import com.longtailvideo.jwplayer.core.PlayerState;
import com.facebook.react.uimanager.*;

public class RNJWPlayerModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext mReactContext;

  public RNJWPlayerModule(ReactApplicationContext reactContext) {
    super(reactContext);

    mReactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNJWPlayerModule";
  }

  @ReactMethod
  public void state(final int reactTag, final Promise promise) {
    try {
      UIManagerModule uiManager = mReactContext.getNativeModule(UIManagerModule.class);
      uiManager.addUIBlock(new UIBlock() {
        public void execute (NativeViewHierarchyManager nvhm) {
          RNJWPlayerView playerView = (RNJWPlayerView) nvhm.resolveView(reactTag);
          //RNJWPlayerViewManager playerViewManager = (RNJWPlayerViewManager) nvhm.resolveViewManager(reactTag);

          PlayerState playerState = playerView.getState();
          promise.resolve(playerState);
        }
      });
    } catch (IllegalViewOperationException e) {
      promise.reject("RNJW Error", e);
    }
  }
}
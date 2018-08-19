
package net.gamesofton.rnjwplayer;

import android.view.View;

import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;

import com.facebook.react.uimanager.annotations.ReactProp;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;
import com.longtailvideo.jwplayer.media.playlists.PlaylistItem;

public class RNJWPlayerModule extends SimpleViewManager<AsapJWPlayer> {

  public static final String REACT_CLASS = "RNJWPlayer";

  private PlayerConfig playerConfig;
  private ThemedReactContext mContext;
  AsapJWPlayer playerView = null;
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
  public AsapJWPlayer createViewInstance(ThemedReactContext context) {

    mContext = context;
    playerConfig = new PlayerConfig.Builder()
            .autostart(true)
            .build();

    playerView = new AsapJWPlayer(mContext.getBaseContext(), playerConfig);
    return playerView;
  }

  @ReactProp(name = "file")
  public void setFile(View view, String prop) {
    if (file!=prop) {
      file = prop;
      playerView.stop();
      pi = new PlaylistItem.Builder()
              .file(file)
              .title(title)
              .description(desc)
              .image(image)

              .build();
      playerView.load(pi);

    }
  }

  @ReactProp(name = "image")
  public void setImage(View view, String prop) {
    if(image!=prop) {
      image = prop;
      playerView.stop();
      pi = new PlaylistItem.Builder()
              .file(file)
              .title(title)
              .description(desc)
              .image(image)
              .build();

      playerView.load(pi);
    }
  }

  @ReactProp(name = "title")
  public void setTitle(View view, String prop) {
    if(title!=prop) {
      title = prop;
      playerView.stop();
      pi = new PlaylistItem.Builder()
              .file(file)
              .title(title)
              .description(desc)
              .image(image)
              .build();

      playerView.load(pi);
    }
  }

  @ReactProp(name = "desc")
  public void setDescription(View view, String prop) {
    if(desc!=prop) {
      desc = prop;
      playerView.stop();
      pi = new PlaylistItem.Builder()
              .file(file)
              .title(title)
              .description(desc)
              .image(image)
              .build();

      playerView.load(pi);
    }
  }
}
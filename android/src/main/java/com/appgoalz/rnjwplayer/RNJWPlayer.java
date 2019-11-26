package com.appgoalz.rnjwplayer;


import android.content.Context;
import android.content.res.Configuration;

import com.longtailvideo.jwplayer.JWPlayerView;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;

public class RNJWPlayer extends JWPlayerView {

    public RNJWPlayer(Context var1, PlayerConfig var2) {
        super(var1, var2);
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            this.setFullscreen(true,true);
        } else if (newConfig.orientation==Configuration.ORIENTATION_PORTRAIT) {
            this.setFullscreen(false,false);
        }
    }
}

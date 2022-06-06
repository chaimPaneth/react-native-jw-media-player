package com.appgoalz.rnjwplayer;


import android.content.Context;
import android.content.res.Configuration;
import android.view.KeyEvent;

import com.jwplayer.pub.view.JWPlayerView;

public class RNJWPlayer extends JWPlayerView {
    public Boolean fullScreenOnLandscape = false;
    public Boolean exitFullScreenOnPortrait = false;

    public RNJWPlayer(Context var1) {
        super(var1);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        // Exit fullscreen or perform the action requested
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK && this.getPlayer().getFullscreen()) {
            if (event.getAction() == KeyEvent.ACTION_UP) {
                this.getPlayer().setFullscreen(false,false);
            }
            return true;
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    public void requestLayout() {
        super.requestLayout();

        // The spinner relies on a measure + layout pass happening after it calls requestLayout().
        // Without this, the widget never actually changes the selection and doesn't call the
        // appropriate listeners. Since we override onLayout in our ViewGroups, a layout pass never
        // happens after a call to requestLayout, so we simulate one here.
        post(measureAndLayout);
    }


    private final Runnable measureAndLayout = new Runnable() {
        @Override
        public void run() {
            measure(
                    MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);

        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            if (fullScreenOnLandscape) {
                this.getPlayer().setFullscreen(true,true);
            }
        } else if (newConfig.orientation==Configuration.ORIENTATION_PORTRAIT) {
            if (exitFullScreenOnPortrait) {
                this.getPlayer().setFullscreen(false,false);
            }
        }
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && this.getPlayer().getFullscreen()) {
            this.getPlayer().setFullscreen(false,false);
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }
}
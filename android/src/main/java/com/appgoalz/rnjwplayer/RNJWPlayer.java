package com.appgoalz.rnjwplayer;


import android.content.Context;
import android.content.res.Configuration;
import androidx.annotation.Nullable;
import android.view.KeyEvent;
import android.view.View;
import com.longtailvideo.jwplayer.JWPlayerView;
import com.longtailvideo.jwplayer.configuration.PlayerConfig;

public class RNJWPlayer extends JWPlayerView {

    public RNJWPlayer(Context var1, PlayerConfig var2) {
        super(var1, var2);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        // Exit fullscreen or perform the action requested
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK && this.getFullscreen()) {
            if (event.getAction() == KeyEvent.ACTION_UP) {
                this.setFullscreen(false,false);
                return false;
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
            this.setFullscreen(true,true);
        } else if (newConfig.orientation == Configuration.ORIENTATION_PORTRAIT) {
            this.setFullscreen(false,false);
        }
    }
}

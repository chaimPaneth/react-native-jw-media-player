package com.appgoalz.rnjwplayer;

import android.content.Context;

import com.google.android.gms.cast.CastMediaControlIntent;
import com.google.android.gms.cast.LaunchOptions;
import com.google.android.gms.cast.framework.CastOptions;
import com.google.android.gms.cast.framework.OptionsProvider;
import com.google.android.gms.cast.framework.SessionProvider;

import java.util.List;
import java.util.Locale;


public class CastOptionsProvider implements OptionsProvider {

    /**
     * The Application Id to use, currently the Default Media Receiver.
     */
    private static final String DEFAULT_APPLICATION_ID = CastMediaControlIntent.DEFAULT_MEDIA_RECEIVER_APPLICATION_ID;
//
//    @Override
//    public CastOptions getCastOptions(Context context) {
//
//        final NotificationOptions notificationOptions = new NotificationOptions.Builder()
//                .setActions(Arrays.asList(
//                        MediaIntentReceiver.ACTION_SKIP_NEXT,
//                        MediaIntentReceiver.ACTION_TOGGLE_PLAYBACK,
//                        MediaIntentReceiver.ACTION_STOP_CASTING), new int[]{1, 2})
//                .setTargetActivityClassName(RNJWPlayerView.class.getName())
//                .build();
//
//        final CastMediaOptions mediaOptions = new CastMediaOptions.Builder()
//                .setNotificationOptions(notificationOptions)
//                .build();
//
//        return new CastOptions.Builder()
//                .setReceiverApplicationId(DEFAULT_APPLICATION_ID)
//                .setCastMediaOptions(mediaOptions)
//                .build();
//    }

    @Override
    public List<SessionProvider> getAdditionalSessionProviders(Context appContext) {
        return null;
    }

    @Override
    public CastOptions getCastOptions(Context context) {
        LaunchOptions launchOptions = new LaunchOptions.Builder()
                .setLocale(Locale.US)
                .build();

        return new CastOptions.Builder()
                .setReceiverApplicationId(DEFAULT_APPLICATION_ID)
                .setLaunchOptions(launchOptions)
            .build();
    }
}
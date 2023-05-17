//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.appgoalz.rnjwplayer.misc;

import android.support.v4.media.session.MediaSessionCompat;
import androidx.annotation.Nullable;

public final class b {
    public final MediaSessionCompat a;

    public b(MediaSessionCompat var1) {
        this.a = var1;
    }

    @Nullable
    public final c a() {
        return this.a.getController().getPlaybackState() == null ? null : new c(this.a.getController().getPlaybackState());
    }
}

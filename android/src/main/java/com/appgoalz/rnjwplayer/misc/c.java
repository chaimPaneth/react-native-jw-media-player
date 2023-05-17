//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.appgoalz.rnjwplayer.misc;

import android.support.v4.media.session.PlaybackStateCompat;

public final class c {
    public PlaybackStateCompat a;

    public c(PlaybackStateCompat var1) {
        this.a = var1;
    }

    public static class a {
        public PlaybackStateCompat.Builder a;

        public a(c var1) {
            if (var1 != null && var1.a != null) {
                this.a = new PlaybackStateCompat.Builder(var1.a);
            } else {
                this.a = new PlaybackStateCompat.Builder();
            }
        }
    }
}

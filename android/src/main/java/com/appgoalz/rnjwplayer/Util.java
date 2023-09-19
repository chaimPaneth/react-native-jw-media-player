package com.appgoalz.rnjwplayer;

import static com.google.android.exoplayer2.util.Util.toByteArray;

import android.util.Patterns;
import android.webkit.URLUtil;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.jwplayer.pub.api.media.ads.AdBreak;
import com.jwplayer.pub.api.media.captions.Caption;
import com.jwplayer.pub.api.media.captions.CaptionType;
import com.jwplayer.pub.api.media.playlists.MediaSource;
import com.jwplayer.pub.api.media.playlists.PlaylistItem;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class Util {

    public static byte[] executePost(String url, byte[] data, Map<String, String> requestProperties)
            throws IOException {
        HttpURLConnection urlConnection = null;
        try {
            urlConnection = (HttpURLConnection) new URL(url).openConnection();
            urlConnection.setRequestMethod("POST");
            urlConnection.setDoOutput(data != null);
            urlConnection.setDoInput(true);
            if (requestProperties != null) {
                for (Map.Entry<String, String> requestProperty : requestProperties.entrySet()) {
                    urlConnection.setRequestProperty(requestProperty.getKey(),
                            requestProperty.getValue());
                }
            }
            // Write the request body, if there is one.
            if (data != null) {
                OutputStream out = urlConnection.getOutputStream();
                try {
                    out.write(data);
                } finally {
                    out.close();
                }
            }
            // Read and return the response body.
            InputStream inputStream = urlConnection.getInputStream();
            try {
                return toByteArray(inputStream);
            } finally {
                inputStream.close();
            }
        } finally {
            if (urlConnection != null) {
                urlConnection.disconnect();
            }
        }
    }

    public static boolean isValidURL(String url){
        return URLUtil.isValidUrl(url) && Patterns.WEB_URL.matcher(url).matches();
    }

    public static List<PlaylistItem> createPlaylist(ReadableArray playlistItems) {
        List<PlaylistItem> playlist = new ArrayList<>();
        if (playlistItems == null || playlistItems.size() <= 0)
            return playlist;

        int j = 0;
        while (playlistItems.size() > j) {
            ReadableMap playlistItem = playlistItems.getMap(j);

            PlaylistItem newPlayListItem = getPlaylistItem((playlistItem));
            playlist.add(newPlayListItem);
            j++;
        }
        return playlist;
    }

    public static PlaylistItem getPlaylistItem (ReadableMap playlistItem) {
        PlaylistItem.Builder itemBuilder = new PlaylistItem.Builder();

        if (playlistItem.hasKey("file")) {
            String file = playlistItem.getString("file");
            itemBuilder.file(file);
        }

        if (playlistItem.hasKey("sources")) {
            ArrayList<MediaSource> sources = new ArrayList<>();
            ReadableArray sourcesArray = playlistItem.getArray("sources");
            if (sourcesArray != null) {
                for (int i = 0; i < sourcesArray.size(); i++) {
                    ReadableMap sourceProp = sourcesArray.getMap(i);
                    if (sourceProp.hasKey("file")) {
                        String file = sourceProp.getString("file");
                        String label = sourceProp.getString("label");
                        boolean isDefault = sourceProp.getBoolean("default");
                        MediaSource source = new MediaSource.Builder().file(file).label(label).isDefault(isDefault).build();
                        sources.add(source);
                    }
                }
            }

            itemBuilder.sources(sources);
        }

        if (playlistItem.hasKey("title")) {
            String title = playlistItem.getString("title");
            itemBuilder.title(title);
        }

        if (playlistItem.hasKey("description")) {
            String desc = playlistItem.getString("description");
            itemBuilder.description(desc);
        }

        if (playlistItem.hasKey("image")) {
            String image = playlistItem.getString("image");
            itemBuilder.image(image);
        }

        if (playlistItem.hasKey("mediaId")) {
            String mediaId = playlistItem.getString("mediaId");
            itemBuilder.mediaId(mediaId);
        }

        if (playlistItem.hasKey("startTime")) {
            double startTime = playlistItem.getDouble("startTime");
            itemBuilder.startTime(startTime);
        }

        if (playlistItem.hasKey("tracks")) {
            ArrayList<Caption> tracks = new ArrayList<>();
            ReadableArray track = playlistItem.getArray("tracks");
            if (track != null) {
                for (int i = 0; i < track.size(); i++) {
                    ReadableMap trackProp = track.getMap(i);
                    if (trackProp.hasKey("file")) {
                        String file = trackProp.getString("file");
                        String label = trackProp.getString("label");
                        boolean isDefault = trackProp.getBoolean("default");
                        Caption caption = new Caption.Builder().file(file).label(label).kind(CaptionType.CAPTIONS).isDefault(isDefault).build();
                        tracks.add(caption);
                    }
                }
            }

            itemBuilder.tracks(tracks);
        }

        if (playlistItem.hasKey("authUrl")) {
            itemBuilder.mediaDrmCallback(new WidevineCallback(playlistItem.getString("authUrl")));
        }

        if (playlistItem.hasKey("adSchedule")) {
            ArrayList<AdBreak> adSchedule = new ArrayList<>();
            ReadableArray ad = playlistItem.getArray("adSchedule");

            for (int i = 0; i < ad.size(); i++) {
                ReadableMap adBreakProp = ad.getMap(i);
                String offset = adBreakProp.hasKey("offset") ? adBreakProp.getString("offset") : "pre";
                if (adBreakProp.hasKey("tag")) {
                    AdBreak adBreak = new AdBreak.Builder().offset(offset).tag(adBreakProp.getString("tag")).build();
                    adSchedule.add(adBreak);
                }
            }

            itemBuilder.adSchedule(adSchedule);
        }

        String recommendations;
        if (playlistItem.hasKey("recommendations")) {
            recommendations = playlistItem.getString("recommendations");
            itemBuilder.recommendations(recommendations);
        }

        return itemBuilder.build();
    }
}
package com.appgoalz.rnjwplayer;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.google.ads.interactivemedia.v3.api.FriendlyObstruction;
import com.google.ads.interactivemedia.v3.api.ImaSdkFactory;
import com.google.ads.interactivemedia.v3.api.ImaSdkSettings;
import com.jwplayer.pub.api.configuration.ads.AdRules;
import com.jwplayer.pub.api.configuration.ads.AdvertisingConfig;
import com.jwplayer.pub.api.configuration.ads.VastAdvertisingConfig;
import com.jwplayer.pub.api.configuration.ads.dai.ImaDaiAdvertisingConfig;
import com.jwplayer.pub.api.configuration.ads.ima.ImaAdvertisingConfig;
import com.jwplayer.pub.api.media.ads.AdBreak;
import com.jwplayer.pub.api.media.ads.dai.ImaDaiSettings;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public class RNJWPlayerAds {

    // Get advertising config based on the ad client type
    public static AdvertisingConfig getAdvertisingConfig(ReadableMap ads) {
        if (ads == null) {
            return null;
        }

        String adClientType = ads.getString("adClient");
        switch (adClientType) {
            case "ima":
                try {
                    return configureImaAdvertising(ads);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            case "ima_dai":
                try {
                    return configureImaDaiAdvertising(ads);
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            default: // Defaulting to VAST
                return configureVastAdvertising(ads);
        }
    }

    // Configure IMA Advertising
    private static ImaAdvertisingConfig configureImaAdvertising(ReadableMap ads) throws Exception {
        if (!BuildConfig.USE_IMA) {
            throw new Exception("Error: Google ads services is not installed. Add RNJWPlayerUseGoogleIMA = true to your app/build.gradle ext {}");
        }

        ImaAdvertisingConfig.Builder builder = new ImaAdvertisingConfig.Builder();

        List<AdBreak> adScheduleList = getAdSchedule(ads);
        builder.schedule(adScheduleList);

        if (ads.hasKey("imaSettings")) {
            builder.imaSdkSettings(getImaSettings(Objects.requireNonNull(ads.getMap("imaSettings"))));
        }

        // companionSlots

        return builder.build();
    }

    // Configure IMA DAI Advertising
    private static ImaDaiAdvertisingConfig configureImaDaiAdvertising(ReadableMap ads) throws Exception {
        if (!BuildConfig.USE_IMA) {
            throw new Exception("Error: Google ads services is not installed. Add RNJWPlayerUseGoogleIMA = true to your app/build.gradle ext {}");
        }

        ImaDaiAdvertisingConfig.Builder builder = new ImaDaiAdvertisingConfig.Builder();

        if (ads.hasKey("imaSettings")) {
            builder.imaSdkSettings(getImaSettings(Objects.requireNonNull(ads.getMap("imaSettings"))));
        }

        if (ads.hasKey("imaDaiSettings")) {
            builder.imaDaiSettings(getImaDaiSettings(Objects.requireNonNull(ads.getMap("imaDaiSettings"))));
        }

        return builder.build();
    }

    // You'll need to implement this method based on how you pass ImaDaiSettings from React Native
    private static ImaDaiSettings getImaDaiSettings(ReadableMap imaDaiSettingsMap) {
        String videoId = imaDaiSettingsMap.hasKey("videoId") ? imaDaiSettingsMap.getString("videoId") : null;
        String cmsId = imaDaiSettingsMap.hasKey("cmsId") ? imaDaiSettingsMap.getString("cmsId") : null;
        String assetKey = imaDaiSettingsMap.hasKey("assetKey") ? imaDaiSettingsMap.getString("assetKey") : null;
        String apiKey = imaDaiSettingsMap.hasKey("apiKey") ? imaDaiSettingsMap.getString("apiKey") : null;

        // Extracting adTagParameters from imaDaiSettingsMap if present
        Map<String, String> adTagParameters = null;
        if (imaDaiSettingsMap.hasKey("adTagParameters") && imaDaiSettingsMap.getMap("adTagParameters") != null) {
            adTagParameters = new HashMap<>();
            ReadableMap adTagParamsMap = imaDaiSettingsMap.getMap("adTagParameters");
            for (Map.Entry<String, Object> entry : adTagParamsMap.toHashMap().entrySet()) {
                if (entry.getValue() instanceof String) {
                    adTagParameters.put(entry.getKey(), (String) entry.getValue());
                }
            }
        }

        // Handling streamType
        ImaDaiSettings.StreamType streamType = ImaDaiSettings.StreamType.HLS; // Default to HLS
        if (imaDaiSettingsMap.hasKey("streamType")) {
            String streamTypeStr = imaDaiSettingsMap.getString("streamType");
            if ("DASH".equalsIgnoreCase(streamTypeStr)) {
                streamType = ImaDaiSettings.StreamType.DASH;
            }
        }
        // Create ImaDaiSettings based on the provided values
        ImaDaiSettings imaDaiSettings = (assetKey != null) ?
                new ImaDaiSettings(assetKey, streamType, apiKey) :
                new ImaDaiSettings(videoId, cmsId, streamType, apiKey);

        if (adTagParameters != null) {
            imaDaiSettings.setAdTagParameters(adTagParameters);
        }

        return imaDaiSettings;
    }

    // Configure VAST Advertising
    private static VastAdvertisingConfig configureVastAdvertising(ReadableMap ads) {
        VastAdvertisingConfig.Builder builder = new VastAdvertisingConfig.Builder();

        List<AdBreak> adScheduleList = getAdSchedule(ads);
        builder.schedule(adScheduleList);

        if (ads.hasKey("skipText")) {
            builder.skipText(ads.getString("skipText"));
        }
        if (ads.hasKey("skipMessage")) {
            builder.skipMessage(ads.getString("skipMessage"));
        }
        // ... Add other VAST specific settings from ads ReadableMap

        // Example: Handling VPAID controls
        if (ads.hasKey("vpaidControls")) {
            builder.vpaidControls(ads.getBoolean("vpaidControls"));
        }

        if (ads.hasKey("adRules")) {
            AdRules adRules = getAdRules(Objects.requireNonNull(ads.getMap("adRules")));
            builder.adRules(adRules);
        }

        return builder.build();
    }

    private static List<AdBreak> getAdSchedule(ReadableMap ads) {
        List<AdBreak> adScheduleList = new ArrayList<>();
        ReadableArray adSchedule = ads.getArray("adSchedule");
        for (int i = 0; i < adSchedule.size(); i++) {
            ReadableMap adBreakProp = adSchedule.getMap(i);
            String offset = adBreakProp.hasKey("offset") ? adBreakProp.getString("offset") : "pre";
            if (adBreakProp.hasKey("tag")) {
                AdBreak adBreak = new AdBreak.Builder()
                        .offset(offset)
                        .tag(adBreakProp.getString("tag"))
                        .build();
                adScheduleList.add(adBreak);
            }
        }
        return adScheduleList;
    }

    public static AdRules getAdRules(ReadableMap adRulesMap) {
        AdRules.Builder builder = new AdRules.Builder();

        if (adRulesMap.hasKey("startOn")) {
            Integer startOn = adRulesMap.getInt("startOn");
            builder.startOn(startOn);
        }
        if (adRulesMap.hasKey("frequency")) {
            Integer frequency = adRulesMap.getInt("frequency");
            builder.frequency(frequency);
        }
        if (adRulesMap.hasKey("timeBetweenAds")) {
            Integer timeBetweenAds = adRulesMap.getInt("timeBetweenAds");
            builder.timeBetweenAds(timeBetweenAds);
        }
        if (adRulesMap.hasKey("startOnSeek")) {
            String startOnSeek = adRulesMap.getString("startOnSeek");
            // Mapping the string to the corresponding constant in AdRules
            String mappedStartOnSeek = mapStartOnSeek(startOnSeek);
            builder.startOnSeek(mappedStartOnSeek);
        }

        return builder.build();
    }

    private static String mapStartOnSeek(String startOnSeek) {
        if ("pre".equals(startOnSeek)) {
            return AdRules.RULES_START_ON_SEEK_PRE;
        }
        // Default to "none" if not "pre"
        return AdRules.RULES_START_ON_SEEK_NONE;
    }

//    public static List<FriendlyObstruction> getFriendlyObstructions(ReadableArray obstructionsArray) {
//        List<FriendlyObstruction> obstructions = new ArrayList<>();
//        // Example: Parse and create FriendlyObstruction objects from obstructionsArray
//        return obstructions;
//    }

    public static ImaSdkSettings getImaSettings(ReadableMap imaSettingsMap) {
        ImaSdkSettings settings = ImaSdkFactory.getInstance().createImaSdkSettings();

        if (imaSettingsMap.hasKey("maxRedirects")) {
            settings.setMaxRedirects(imaSettingsMap.getInt("maxRedirects"));
        }
        if (imaSettingsMap.hasKey("language")) {
            settings.setLanguage(imaSettingsMap.getString("language"));
        }
        if (imaSettingsMap.hasKey("ppid")) {
            settings.setPpid(imaSettingsMap.getString("ppid"));
        }
        if (imaSettingsMap.hasKey("playerType")) {
            settings.setPlayerType(imaSettingsMap.getString("playerType"));
        }
        if (imaSettingsMap.hasKey("playerVersion")) {
            settings.setPlayerVersion(imaSettingsMap.getString("playerVersion"));
        }
        if (imaSettingsMap.hasKey("sessionId")) {
            settings.setSessionId(imaSettingsMap.getString("sessionId"));
        }
        if (imaSettingsMap.hasKey("debugMode")) {
            settings.setDebugMode(imaSettingsMap.getBoolean("debugMode"));
        }
        // Add other settings as needed

        return settings;
    }
}

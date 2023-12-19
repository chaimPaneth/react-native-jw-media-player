//
//  RNJWPlayerAds.m
//  RNJWPlayer
//
//  Created by Chaim Paneth on 19/12/2023.
//

#import "RNJWPlayerAds.h"

@implementation RNJWPlayerAds

+ (JWAdvertisingConfig *)configureVASTWithAds:(NSDictionary *)ads error:(JWError **)error {
    JWAdsAdvertisingConfigBuilder* adConfigBuilder = [[JWAdsAdvertisingConfigBuilder alloc] init];
    
    // Configure VAST specific settings here
    // Example: setting ad schedule, tag, etc.
    
    NSArray* scheduleArray = [self getAdSchedule:ads error:error];
    if (scheduleArray.count > 0) {
        [adConfigBuilder schedule:scheduleArray];
    }
    
    id tag = ads[@"tag"];
    if (tag != nil && (tag != (id)[NSNull null])) {
        NSString* encodedString = [tag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL* tagUrl = [NSURL URLWithString:encodedString];
        if (tagUrl != nil) {
            [adConfigBuilder tag:tagUrl];
        }
    }
    
    id adVmap = ads[@"adVmap"];
    if (adVmap != nil && (adVmap != (id)[NSNull null])) {
        NSString* encodedString = [adVmap stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL* adVmapUrl = [NSURL URLWithString:encodedString];
        if (adVmapUrl != nil) {
            [adConfigBuilder vmapURL:adVmapUrl];
        }
    }
    
    id openBrowserOnAdClick = ads[@"openBrowserOnAdClick"];
    if (openBrowserOnAdClick != nil && (openBrowserOnAdClick != (id)[NSNull null])) {
        [adConfigBuilder openBrowserOnAdClick:openBrowserOnAdClick];
    }
    
    NSDictionary *adRulesDict = ads[@"adRules"];
    if (adRulesDict) {
        JWAdRules* adRules = [self getAdRules:adRulesDict error:error];
        [adConfigBuilder adRules:adRules];
    }
    
    NSDictionary *adSettingsDict = ads[@"adSettings"];
    if (adSettingsDict) {
        JWAdSettings* adSettings = [self getAdSettings:adSettingsDict];
        [adConfigBuilder adSettings:adSettings];
    }
    
    return [adConfigBuilder buildAndReturnError:error];
}

+ (JWAdvertisingConfig *)configureIMAWithAds:(NSDictionary *)ads error:(JWError **)error {
    JWImaAdvertisingConfigBuilder* adConfigBuilder = [[JWImaAdvertisingConfigBuilder alloc] init];
    
    // Configure Google IMA specific settings here
    // Example: setting ad schedule, tag, IMA settings, etc.
    
    NSArray* scheduleArray = [self getAdSchedule:ads error:error];
    if (scheduleArray.count > 0) {
        [adConfigBuilder schedule:scheduleArray];
    }
    
    id tag = ads[@"tag"];
    if (tag != nil && (tag != (id)[NSNull null])) {
        NSString* encodedString = [tag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL* tagUrl = [NSURL URLWithString:encodedString];
        if (tagUrl != nil) {
            [adConfigBuilder tag:tagUrl];
        }
    }
    
    id adVmap = ads[@"adVmap"];
    if (adVmap != nil && (adVmap != (id)[NSNull null])) {
        NSString* encodedString = [adVmap stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSURL* adVmapUrl = [NSURL URLWithString:encodedString];
        if (adVmapUrl != nil) {
            [adConfigBuilder vmapURL:adVmapUrl];
        }
    }
    
    NSDictionary *adRulesDict = ads[@"adRules"];
    if (adRulesDict) {
        JWAdRules* adRules = [self getAdRules:adRulesDict error:error];
        [adConfigBuilder adRules:adRules];
    }
    
    NSDictionary *imaSettingsDict = ads[@"imaSettings"];
    if (imaSettingsDict) {
        JWImaSettings* imaSettings = [self getIMASettings:imaSettingsDict];
        [adConfigBuilder imaSettings:imaSettings];
    }
    
    return [adConfigBuilder buildAndReturnError:error];
}

+ (JWAdvertisingConfig *)configureIMADAIWithAds:(NSDictionary *)ads error:(JWError **)error {
    JWImaDaiAdvertisingConfigBuilder* adConfigBuilder = [[JWImaDaiAdvertisingConfigBuilder alloc] init];
    
    // Configure Google IMA DAI specific settings here
    // Example: setting stream configuration, friendly obstructions, etc.
    
    NSDictionary *imaSettingsDict = ads[@"imaSettings"];
    if (imaSettingsDict) {
        JWImaSettings* imaSettings = [self getIMASettings:imaSettingsDict];
        [adConfigBuilder imaSettings:imaSettings];
    }
    
    NSDictionary *googleDAIStreamDict = ads[@"googleDAIStream"];
    if (googleDAIStreamDict) {
        JWGoogleDAIStream* googleDAIStream = [self getGoogleDAIStream:googleDAIStreamDict error:error];
        [adConfigBuilder googleDAIStream:googleDAIStream];
    }
    
    return [adConfigBuilder buildAndReturnError:error];
}

+ (NSArray *)getAdSchedule:(NSDictionary *)ads error:(JWError **)error {
    id schedule = ads[@"adSchedule"];
    if(schedule != nil && (schedule != (id)[NSNull null])) {
        NSArray* scheduleAr = (NSArray*)schedule;
        if (scheduleAr.count > 0) {
            NSMutableArray <JWAdBreak*>* scheduleArray = [[NSMutableArray alloc] init];
            
            for (id item in scheduleAr) {
                NSString *offsetString = [item objectForKey:@"offset"];
                NSString *tag = [item objectForKey:@"tag"];
                NSString* encodedString = [tag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
                NSURL* tagUrl = [NSURL URLWithString:encodedString];
                
                if (tagUrl != nil) {
                    JWAdBreakBuilder* adBreakBuilder = [[JWAdBreakBuilder alloc] init];
                    JWAdOffset* offset = [JWAdOffset fromString:offsetString];
                    
                    [adBreakBuilder offset:offset];
                    [adBreakBuilder tags:@[tagUrl]];
                    
                    JWAdBreak *adBreak = [adBreakBuilder buildAndReturnError:error];
                    
                    [scheduleArray addObject:adBreak];
                }
            }
        
            return scheduleArray;
        }
    }
    
    return @[];
}

+ (JWAdRules *)getAdRules:(NSDictionary *)adRulesDict error:(JWError **)error {
    JWAdRulesBuilder *builder = [[JWAdRulesBuilder alloc] init];

    NSUInteger startOn = [adRulesDict[@"startOn"] unsignedIntegerValue];
    NSUInteger frequency = [adRulesDict[@"frequency"] unsignedIntegerValue];
    NSUInteger timeBetweenAds = [adRulesDict[@"timeBetweenAds"] unsignedIntegerValue];
    JWAdShownOnSeek startOnSeek = [self mapStringToJWAdShownOnSeek:adRulesDict[@"startOnSeek"]];

    [builder jwRulesWithStartOn:startOn frequency:frequency timeBetweenAds:timeBetweenAds startOnSeek:startOnSeek];

    return [builder buildAndReturnError:error];
}

+ (JWAdShownOnSeek)mapStringToJWAdShownOnSeek:(NSString *)seekString {
    if ([seekString isEqualToString:@"pre"]) {
        return JWAdShownOnSeekPre;
    }
    return JWAdShownOnSeekNone;
}

+  (JWAdSettings *)getAdSettings:(NSDictionary *)settingsDict {
    JWAdSettingsBuilder *builder = [[JWAdSettingsBuilder alloc] init];
    
    if (settingsDict[@"allowsBackgroundPlayback"]) {
        BOOL allowsBackgroundPlayback = [settingsDict[@"allowsBackgroundPlayback"] boolValue];
        [builder allowsBackgroundPlayback:allowsBackgroundPlayback];
    }

    // Add other settings as needed

    return [builder build];
}

+ (JWImaSettings *)getIMASettings:(NSDictionary *)imaSettingsDict {
    JWImaSettingsBuilder *builder = [[JWImaSettingsBuilder alloc] init];
    if (imaSettingsDict[@"locale"]) {
        [builder locale:imaSettingsDict[@"locale"]];
    }
    if (imaSettingsDict[@"ppid"]) {
        [builder ppid:imaSettingsDict[@"ppid"]];
    }
    if (imaSettingsDict[@"maxRedirects"]) {
        [builder maxRedirects:[imaSettingsDict[@"maxRedirects"] unsignedIntegerValue]];
    }
    if (imaSettingsDict[@"sessionID"]) {
        [builder sessionID:imaSettingsDict[@"sessionID"]];
    }
    if (imaSettingsDict[@"debugMode"]) {
        [builder debugMode:[imaSettingsDict[@"debugMode"] boolValue]];
    }
    return [builder build];
}

+ (JWGoogleDAIStream *)getGoogleDAIStream:(NSDictionary *)googleDAIStreamDict error:(JWError **)error {
    JWGoogleDAIStreamBuilder *builder = [[JWGoogleDAIStreamBuilder alloc] init];
    if (googleDAIStreamDict[@"videoID"] && googleDAIStreamDict[@"cmsID"]) {
        [builder vodStreamInfoWithVideoID:googleDAIStreamDict[@"videoID"] cmsID:googleDAIStreamDict[@"cmsID"]];
    } else if (googleDAIStreamDict[@"assetKey"]) {
        [builder liveStreamInfoWithAssetKey:googleDAIStreamDict[@"assetKey"]];
    }
    if (googleDAIStreamDict[@"apiKey"]) {
        [builder apiKey:googleDAIStreamDict[@"apiKey"]];
    }
    if (googleDAIStreamDict[@"adTagParameters"]) {
        [builder adTagParameters:googleDAIStreamDict[@"adTagParameters"]];
    }
    return [builder buildAndReturnError:error];
}

//+ (UIView *)findViewWithId:(NSString *)viewId {
//    // needs implementation
//}

//+ (NSArray<JWFriendlyObstruction *> *)createFriendlyObstructionsFromArray:(NSArray *)obstructionsArray {
//    NSMutableArray<JWFriendlyObstruction *> *obstructions = [NSMutableArray array];
//
//    for (NSDictionary *obstructionDict in obstructionsArray) {
//        NSString *viewId = obstructionDict[@"viewId"];
//        UIView *view = [self findViewWithId:viewId]; // Implement this method to find the view by ID
//        JWFriendlyObstructionPurpose purpose = [self mapStringToJWFriendlyObstructionPurpose:obstructionDict[@"purpose"]];
//        NSString *reason = obstructionDict[@"reason"];
//
//        JWFriendlyObstruction *obstruction = [[JWFriendlyObstruction alloc] initWithView:view purpose:purpose reason:reason];
//        [obstructions addObject:obstruction];
//    }
//
//    return obstructions;
//}

//+ (JWFriendlyObstructionPurpose)mapStringToJWFriendlyObstructionPurpose:(NSString *)purposeString {
//    if ([purposeString isEqualToString:@"mediaControls"]) {
//        return JWFriendlyObstructionPurposeMediaControls;
//    } else if ([purposeString isEqualToString:@"closeAd"]) {
//        return JWFriendlyObstructionPurposeCloseAd;
//    } else if ([purposeString isEqualToString:@"notVisible"]) {
//        return JWFriendlyObstructionPurposeNotVisible;
//    }
//    return JWFriendlyObstructionPurposeOther;
//}

//+ (JWCompanionAdSlot *)createCompanionAdSlotFromDictionary:(NSDictionary *)companionAdSlotDict {
//    UIView *view = [self findViewWithId:companionAdSlotDict[@"viewId"]]; // Implement this method to find the UIView
//    CGSize size = CGSizeZero;
//    if (companionAdSlotDict[@"size"]) {
//        size = CGSizeMake([companionAdSlotDict[@"size"][@"width"] floatValue],
//                          [companionAdSlotDict[@"size"][@"height"] floatValue]);
//    }
//    JWCompanionAdSlot *slot = [[JWCompanionAdSlot alloc] initWithView:view size:size];
//    return slot;
//}

@end

